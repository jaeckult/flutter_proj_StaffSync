const express = require('express');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { identifyUser } = require('../utils/middleware');
const notificationRouter = express.Router();

const prisma = new PrismaClient();

notificationRouter.get('/', identifyUser, async (req, res) => {
  try {
    const userId = req.user.id;
    const notifications = await prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' }
    });

    res.json(notifications);
  } catch (err) {
    console.error('Error fetching notifications:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});
notificationRouter.delete('/', identifyUser, async(req, res) => {
    const userId = req.user.id;
    try {
        const user_notification = await prisma.notification.deleteMany({
        where: {userId}
    })
    res.status(204).json({ message: 'Notifications deleted successfully' });

    }
    catch (e) {
        console.error(e);
        
    }
    


});

module.exports = notificationRouter;
