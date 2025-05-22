const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { identifyUser, rbacMiddleware, isOnLeave, isOnWork } = require('../utils/middleware');
const logger = require('../utils/logger');

const prisma = new PrismaClient();
const attendanceRouter = express.Router();

// POST /api/attendance/check-in - Record check-in (all authenticated users)
attendanceRouter.post('/check-in', identifyUser, async (req, res, next) => {
  try {
    // Check for active check-in (no check-out)
    const activeAttendance = await prisma.attendance.findFirst({
      where: {
        userId: req.user.id,
        checkOut: null,
      },
    });

    if (activeAttendance) {
      return res.status(400).json({ error: 'You must check out before checking in again' });
    }

    const now = new Date();
    const dateStr = now.toISOString().split('T')[0]; // Get date in YYYY-MM-DD format
    const dateForQuery = new Date(dateStr); // Create a Date object for the start of the day

    // Check if an attendance record already exists for the day
    let attendance = await prisma.attendance.findFirst({
      where: {
        userId: req.user.id,
        date: dateForQuery,
      },
    });

    if (attendance) {
      // Update existing record with check-in
      attendance = await prisma.attendance.update({
        where: { id: attendance.id },
        data: {
          checkIn: now,
          attendance: 'PRESENT', // Set to PRESENT since user checked in
        },
        include: { user: { select: { email: true, profile: { select: { fullName: true } } } } },
      });
    } else {
      // Create new attendance record
      attendance = await prisma.attendance.create({
        data: {
          userId: req.user.id,
          date: dateForQuery,
          checkIn: now,
          attendance: 'PRESENT', // Set to PRESENT since user checked in
        },
        include: { user: { select: { email: true, profile: { select: { fullName: true } } } } },
      });
    }

    res.status(201).json({
      message: 'Checked in successfully',
      attendance: {
        id: attendance.id,
        checkIn: attendance.checkIn,
        attendance: attendance.attendance,
      },
    });
  } catch (error) {
    logger.error('Check-in error:', error);
    next(error);
  } finally {
    await prisma.$disconnect();
  }
});

// POST /api/attendance/check-out - Record check-out (all authenticated users)
attendanceRouter.post('/check-out', identifyUser, async (req, res, next) => {
  try {
    const activeAttendance = await prisma.attendance.findFirst({
      where: {
        userId: req.user.id,
        checkOut: null,
      },
      include: { user: { select: { email: true, profile: { select: { fullName: true } } } } },
    });

    if (!activeAttendance) {
      return res.status(400).json({ error: 'No active check-in found' });
    }

    // Update attendance record
    const attendance = await prisma.attendance.update({
      where: { id: activeAttendance.id },
      data: { checkOut: new Date() },
      select: {
        id: true,
        checkIn: true,
        checkOut: true,
        attendance: true,
      },
    });

    res.status(200).json({
      message: 'Checked out successfully',
      attendance,
    });
  } catch (error) {
    logger.error('Check-out error:', error);
    if (error.code === 'P2025') {
      return res.status(400).json({ error: 'No active check-in found' });
    }
    next(error);
  } finally {
    await prisma.$disconnect();
  }
});

// GET /api/attendance - List attendance history
attendanceRouter.get('/', identifyUser, async (req, res, next) => {
  try {
    const { userId } = req.query;

    // Managers can view others' attendance, employees can only view their own
    let whereClause = { userId: req.user.id };
    if (userId) {
      whereClause = { userId: parseInt(userId) };
    }

    const attendanceRecords = await prisma.attendance.findMany({
      where: whereClause,
      orderBy: { date: 'desc' },
      select: {
        id: true,
        date: true,
        checkIn: true,
        checkOut: true,
        attendance: true,
        createdAt: true,
        user: { select: { username: true, profile: { select: { fullName: true } } } },
      },
    });

    res.status(200).json(attendanceRecords);
  } catch (error) {
    logger.error('Attendance fetch error:', error);
    next(error);
  } finally {
    await prisma.$disconnect();
  }
});


// GET /api/attendance/stats - Get attendance stats for all users (managers only)
attendanceRouter.get('/stats', identifyUser, async (req, res, next) => {
  try {
    const { startDate, endDate } = req.query;

    // Default to last 30 days if no range provided
    const end = endDate ? new Date(endDate) : new Date();
    const start = startDate ? new Date(startDate) : new Date(end.getTime() - 30 * 24 * 60 * 60 * 1000);

    // Validate date range
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({ error: 'Invalid date format' });
    }
    if (start > end) {
      return res.status(400).json({ error: 'startDate must be before endDate' });
    }

    // Fetch all users
    const users = await prisma.user.findMany();

    // Fetch all attendance records in the date range
    const attendanceRecords = await prisma.attendance.findMany({
      where: {
        date: {
          gte: new Date(start.toISOString().split('T')[0]),
          lte: new Date(end.toISOString().split('T')[0]),
        },
      },
    });

    let totalPresent = 0;
    let totalAbsent = 0;

    // Iterate through each day in the range
    const currentDate = new Date(start);
    while (currentDate <= end) {
      const dateStr = currentDate.toISOString().split('T')[0];
      const recordsForDay = attendanceRecords.filter(r => r.date.toISOString().split('T')[0] === dateStr);

      // Count present and absent for the day
      for (const user of users) {
        const userRecord = recordsForDay.find(r => r.userId === user.id);

        if (userRecord) {
          if (userRecord.attendance === 'PRESENT') {
            totalPresent++;
          } else if (userRecord.attendance === 'ABSENT') {
            totalAbsent++;
          }
          // If attendance is null (on leave), we skip counting as present or absent
        } else {
          // No record exists, check if on leave
          const onLeave = await isOnLeave(user.id, dateStr);
          if (!onLeave) {
            totalAbsent++; // No record and not on leave = absent
          }
        }
      }

      // Move to the next day
      currentDate.setDate(currentDate.getDate() + 1);
    }

    res.json({
      totalPresent,  // Total number of "present employee days"
      totalAbsent,   // Total number of "absent employee days"
    });
  } catch (error) {
    logger.error('Attendance stats error:', error);
    res.status(500).json({ error: 'Failed to fetch attendance stats' });
  } finally {
    await prisma.$disconnect();
  }
});

module.exports = attendanceRouter;