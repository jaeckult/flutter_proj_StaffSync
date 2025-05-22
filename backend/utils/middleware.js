const logger = require('./logger')
const jwt = require('jsonwebtoken')
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const requestLogger = (request, response, next) => {
  logger.info('Method:', request.method)
  logger.info('Path:  ', request.path)
  logger.info('Body:  ', request.body)
  logger.info('---')
  next()
}

const unknownEndpoint = (request, response) => {
  response.status(404).send({ error: 'unknown endpoint' })
}

const getTokenFrom = (request, response, next) => {
  const auth = request.get('authorization');
  logger.info('Authorization header:', auth); // Debug
  if (auth && auth.toLowerCase().startsWith('bearer ')) {
    request.token = auth.slice(7);
    logger.info('Extracted token:', request.token); // Debug
  } else {
    logger.info('No valid Bearer token found');
  }
  next();
};

const identifyUser = async (req, res, next) => {
  const token = req.token; 

  if (!token) {
    return res.status(401).json({ error: 'Unauthorized - No token provided' });
  }
  const blacklistedToken = await prisma.blacklistedToken.findUnique({
    where: { token },
  });
  if (blacklistedToken) {
    return res.status(401).json({ error: 'Token has been invalidated' });
  }

  try {
    const decoded = jwt.verify(token, process.env.SECRET);
    const userId = decoded.id; 

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return res.status(401).json({ error: 'Unauthorized - Invalid user' });
    }

    req.user = {
      id: user.id,
      username: user.username,
      role: user.role, 
    };
    next();
  } catch (error) {
    console.error('Error verifying token:', error);
    return res.status(403).json({ error: 'Forbidden - Invalid token' });
  } finally {
    await prisma.$disconnect();
  }
};

const errorHandler = (error, request, response, next) => {
  logger.error(error)

  if (error.name === 'CastError') {
    return response.status(400).send({ error: 'malformatted id' })
  } else if (error.name === 'ValidationError') {
    return response.status(400).json({ error: error.message })
  }else if(error.name === 'PasswordErr'){
    return response.status(400).json({ error: error.message })
  }else if (error.name === 'MongoServerError' && error.code === 11000) {
    return response.status(400).json({ error: 'Username Taken' });
  }else if (error.name === 'JsonWebTokenError'){
    return( response.status(401).json({
      error: 'inivalid token'
    }))
  }
  next(error)
};

const rbacMiddleware = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !req.user.role) {
      return res.status(401).json({ error: 'Unauthorized - User not authenticated' });
    }

    const userRole = req.user.role;

    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({ error: `Forbidden - ${userRole} role not authorized` });
    }

    next();
  };
};

// Helper function to calculate leave duration in days
const calculateLeaveDuration = (startDate, endDate) => {
  const start = new Date(startDate);
  const end = new Date(endDate);
  const diffTime = Math.abs(end - start);
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1; // Include both start and end dates
};

const isOnLeave = async (userId, date) => {
  const leaveRequests = await prisma.leaveRequest.findMany({
    where: {
      userId,
      status: 'APPROVED',
      startDate: { lte: new Date(date) },
      endDate: { gte: new Date(date) },
    },
  });
  return leaveRequests.length > 0;
};
const isOnWork = async (userId, date) =>  {
  const working = await prisma.user.findMany({
    where:{
      userId,
      attendance: 'PRESENT',
    },
  });
  return working.length>0;
}

module.exports = {
  requestLogger,
  getTokenFrom,
  unknownEndpoint,
  identifyUser,
  errorHandler,
  rbacMiddleware,
  calculateLeaveDuration,
  isOnLeave,
  isOnWork
}