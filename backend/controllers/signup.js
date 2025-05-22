const express = require('express');
const signupRouter = express.Router();
const bcrypt = require('bcrypt');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { identifyUser } = require('../utils/middleware');

signupRouter.post('/', async (req, res) => {
  const {
    username,
    password,
    email,
    fullName,
    gender,
    employmentType,
    designation,
    dateOfBirth,
    role
  } = req.body;
  console.log(req.body)

  // Validate required fields
  if (!username || !password || !email || !fullName || !gender || !employmentType || !designation || !dateOfBirth) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  if (password.length < 6) {
    return res.status(400).json({ error: 'Password must be at least 6 characters long' });
  }

  try {
    // Check for existing user
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { username },
          { email }
        ]
      }
    });

    if (existingUser) {
      return res.status(400).json({
        error: existingUser.username === username ? 'Username already taken' : 'Email already exists'
      });
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user, profile, and initial leave balances in a transaction
    const newUser = await prisma.$transaction(async (prisma) => {
      // Create the user
      const user = await prisma.user.create({
        data: {
          username,
          email,
          password: passwordHash,
          role: role || 'EMPLOYEE', // Default to 'EMPLOYEE' if role is not provided
          points: 100, // Initial points allocation
          profile: {
            create: {
              fullName,
              gender,
              employmentType,
              designation,
              dateOfBirth: new Date(dateOfBirth),
            }
          }
        }
      });

      // Create initial leave balances for each leave type
      const leaveTypes = ['SICK', 'VACATION', 'PERSONAL'];
      for (const type of leaveTypes) {
        await prisma.leaveBalance.create({
          data: {
            userId: user.id,
            type,
            balance: 20, // Initial balance of 20 days per leave type
          },
        });
      }

      return user;
    });

    res.status(201).json({
      username: newUser.username,
      email: newUser.email,
      role: newUser.role,
      points: newUser.points
    });
  } catch (error) {
    console.error('Error during signup:', error);
    res.status(500).json({ error: 'Internal server error during signup' });
  } finally {
    await prisma.$disconnect();
  }
});

module.exports = signupRouter;