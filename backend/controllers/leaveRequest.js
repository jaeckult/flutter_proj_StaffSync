const express = require('express');
const leaveRequestRouter = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { identifyUser, rbacMiddleware, calculateLeaveDuration, isOnLeave, isOnWork } = require('../utils/middleware');

// Create a leave request
leaveRequestRouter.post('/', identifyUser, async (req, res) => {
  console.log(req.body);
  
  const { type, startDate, endDate, reason } = req.body;
  const userId = req.user.id;

  try {
    // Validate input
    if (!type || !startDate || !endDate || !reason) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const leaveDuration = calculateLeaveDuration(startDate, endDate);
    const pointsDeduction = leaveDuration; // 1 point per day

    const leaveRequest = await prisma.leaveRequest.create({
      data: {
        userId,
        type,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        reason,
        pointsDeduction,
      },
    });

    res.status(201).json(leaveRequest);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to create leave request' });
  }
});

// Update a leave request (e.g., approve, reject, cancel)
leaveRequestRouter.patch('/:id', identifyUser, rbacMiddleware(['MANAGER']), async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  const userId = req.user.id;
  const now = new Date();

  try {
    const leaveRequest = await prisma.leaveRequest.findUnique({
      where: { id: parseInt(id) },
      include: { user: true },
    });

    if (!leaveRequest) {
      return res.status(404).json({ error: 'Leave request not found' });
    }

    // Update the leave request, points, and leave balance in a transaction
    const result = await prisma.$transaction(async (prisma) => {
      let message = `Leave request updated to ${status}`;

      // If approving, update points and leave balance
      if (status === 'APPROVED') {
        const leaveDuration = calculateLeaveDuration(leaveRequest.startDate, leaveRequest.endDate);

        // Deduct points
        const updatedUser = await prisma.user.update({
          where: { id: leaveRequest.userId },
          data: {
            points: {
              decrement: leaveRequest.pointsDeduction,
            },
          },
        });

        if (updatedUser.points < 0) {
          throw new Error('Insufficient points');
        }

        // Update leave balance
        const leaveBalance = await prisma.leaveBalance.findFirst({
          where: {
            userId: leaveRequest.userId,
            type: leaveRequest.type,
          },
        });

        if (leaveBalance) {
          await prisma.leaveBalance.update({
            where: { id: leaveBalance.id },
            data: {
              balance: {
                decrement: leaveDuration,
              },
            },
          });
        } else {
          await prisma.leaveBalance.create({
            data: {
              userId: leaveRequest.userId,
              type: leaveRequest.type,
              balance: 20 - leaveDuration, // Assuming default balance is 20
            },
          });
        }

        message = 'Leave request approved, points and balance updated';
      }

      // Update the leave request status, approvedBy, and approvedAt
      const updatedLeaveRequest = await prisma.leaveRequest.update({
        where: { id: parseInt(id) },
        data: {
          status,
          approvedById: userId, // Use req.user.id instead of req.userId
          approvedAt: now,
        },
      });

      return { updatedLeaveRequest, message };
    });

    res.json({
      message: result.message,
      leaveRequest: result.updatedLeaveRequest,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message || 'Failed to update leave request' });
  }
});

// Get leave request stats for the dashboard
leaveRequestRouter.get('/stats', identifyUser, async (req, res) => {
  console.log(req.body);
  
  const userId = req.user.id;

  try {
    // Fetch leave balance (sum across all types or per type)
    const leaveBalances = await prisma.leaveBalance.findMany({
      where: { userId },
    });
    const totalLeaveBalance = leaveBalances.reduce((sum, balance) => sum + balance.balance, 0);

    // Fetch counts for approved, pending, and cancelled leave requests
    const approvedCount = await prisma.leaveRequest.count({
      where: { userId, status: 'APPROVED' },
    });
    const pendingCount = await prisma.leaveRequest.count({
      where: { userId, status: 'PENDING' },
    });
    const cancelledCount = await prisma.leaveRequest.count({
      where: { userId, status: 'CANCELLED' },
    });

    res.json({
      leaveBalance: totalLeaveBalance,
      leaveApproved: approvedCount,
      leavePending: pendingCount,
      leaveCancelled: cancelledCount,
    });
    
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch leave stats' });
  }
});

// Get all leave requests for the user
leaveRequestRouter.get('/', identifyUser, async (req, res) => {
  const userId = req.user.id;

  try {
    const leaveRequests = await prisma.leaveRequest.findMany({
      where: { userId },
    });
    res.json(leaveRequests);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch leave requests' });
  }
});

module.exports = leaveRequestRouter;