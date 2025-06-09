const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { identifyUser, rbacMiddleware, isOnLeave, isOnWork } = require('../utils/middleware');
const logger = require('../utils/logger');

const prisma = new PrismaClient();
const attendanceRouter = express.Router();

// POST /api/attendance/check-in - Record check-in (all authenticated users)
attendanceRouter.post('/check-in', identifyUser, async (req, res, next) => {
  try {
    const now = new Date();
    const dateStr = now.toISOString().split('T')[0]; // Get date in YYYY-MM-DD format
    const dateForQuery = new Date(dateStr); // Create a Date object for the start of the day

    // Create new attendance record
    const attendance = await prisma.attendance.create({
      data: {
        userId: req.user.id,
        date: dateForQuery,
        checkIn: now,
        attendance: 'PRESENT',
      },
      include: { user: { select: { email: true, profile: { select: { fullName: true } } } } },
    });

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
    const now = new Date();
    const dateStr = now.toISOString().split('T')[0];
    const dateForQuery = new Date(dateStr);

    // Find the most recent attendance record for today without a check-out
    const activeAttendance = await prisma.attendance.findFirst({
      where: {
        userId: req.user.id,
        date: dateForQuery,
        checkOut: null,
      },
      orderBy: {
        checkIn: 'desc',
      },
    });

    if (!activeAttendance) {
      return res.status(400).json({ error: 'No active check-in found for today' });
    }

    // Update attendance record with check-out time
    const attendance = await prisma.attendance.update({
      where: { id: activeAttendance.id },
      data: { checkOut: now },
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

attendanceRouter.get('/stats', identifyUser, async (req, res, next) => {
  try {
    const { startDate, endDate } = req.query;

    const end = endDate ? new Date(endDate) : new Date();
    const start = startDate ? new Date(startDate) : new Date(end.getTime() - 30 * 24 * 60 * 60 * 1000);

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({ error: 'Invalid date format' });
    }
    if (start > end) {
      return res.status(400).json({ error: 'startDate must be before endDate' });
    }

    const users = await prisma.user.findMany();

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
    let totalCheckedIn = 0;
    let totalCheckedOut = 0;

    const currentDate = new Date(start);
    while (currentDate <= end) {
      const dateStr = currentDate.toISOString().split('T')[0];
      const recordsForDay = attendanceRecords.filter(r => r.date.toISOString().split('T')[0] === dateStr);

      for (const user of users) {
        const userRecord = recordsForDay.find(r => r.userId === user.id);

        if (userRecord) {
          // ✅ Count check-ins and check-outs regardless of attendance status
          if (userRecord.checkIn) totalCheckedIn++;
          if (userRecord.checkOut) totalCheckedOut++;

          // Still count attendance (optional, if you need it)
          if (userRecord.attendance === 'PRESENT') {
            totalPresent++;
          } else if (userRecord.attendance === 'ABSENT') {
            totalAbsent++;
          }
        } else {
          const onLeave = await isOnLeave(user.id, dateStr);
          if (!onLeave) totalAbsent++;
        }
      }

      currentDate.setDate(currentDate.getDate() + 1);
    }

    res.json({
      totalPresent,
      totalAbsent,
      totalCheckedIn,  // ✅ Now counts every checkIn, regardless of attendance status
      totalCheckedOut, // ✅ Same here
    });
  } catch (error) {
    logger.error('Attendance stats error:', error);
    res.status(500).json({ error: 'Failed to fetch attendance stats' });
  } finally {
    await prisma.$disconnect();
  }
});

attendanceRouter.delete('/clear', async (req, res) => {
  const { token } = req.headers;
  const { userId } = req.body;
  try {
    const user = await prisma.user.findUnique({
      where: {
        id: userId,
      },
    });

    if (!user) {
      throw new Error('User not found');
    }

    const attendance = await prisma.attendance.deleteMany({
      where: {
        userId: userId,
      },
    });

    res.status(200).json({
      attendance,
    });
  } catch (error) {
    logger.error('Attendance clear error:', error);
    res.status(500).json({ error: 'Failed to clear attendance' });
  } finally {
    await prisma.$disconnect();
  }
});

attendanceRouter.delete('/:id', identifyUser, async (req, res) => {
  try {
    const { id } = req.params;
    
    const attendance = await prisma.attendance.delete({
      where: {
        id: parseInt(id),
      },
    });

    res.status(200).json({
      message: 'Attendance record deleted successfully',
      attendance,
    });
  } catch (error) {
    logger.error('Attendance delete error:', error);
    res.status(500).json({ error: 'Failed to delete attendance record' });
  } finally {
    await prisma.$disconnect();
  }
});

module.exports = attendanceRouter;