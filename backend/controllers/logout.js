const express = require('express');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { identifyUser } = require('../utils/middleware');

const prisma = new PrismaClient();
const logoutRouter = express.Router();

logoutRouter.post('/', identifyUser, async (req, res, next) => {
  try {
    const { token } = req;
    const decoded = jwt.decode(token);
    console.log('Decoded token:', decoded); // Debug
    if (!decoded || !decoded.exp) {
      return res.status(400).json({ error: 'Invalid token' });
    }


    await prisma.blacklistedToken.create({
      data: {
        token,
        expiresAt: new Date(decoded.exp * 1000), // Convert seconds to milliseconds
      },
    });

    res.status(200).json({ message: 'Successfully logged out' });
  } catch (error) {
    console.error('Logout error:', error);
    if (error.code === 'P2002') {
      return res.status(400).json({ error: 'Token already blacklisted' });
    }
    next(error);
  }
});

module.exports = logoutRouter;