const express = require('express');
const profileRouter = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { identifyUser } = require('../utils/middleware');
const bcrypt = require('bcrypt');
const { error } = require('../utils/logger');
const { errorHandler } = require('../utils/middleware');


// profileRouter.get('/', identifyUser, async(req, res)=>{
//   try{

//   }
// })

profileRouter.patch('/:id', identifyUser, async (req, res, next) => {
    try {
      const { id } = req.params;
      const { fullName, gender, employmentType, designation, dateOfBirth } = req.body;
      const userId = req.user.id;
      const profileId = parseInt(id, 10);


      if (isNaN(profileId)) {
        return res.status(400).json({ error: 'Invalid profile ID' });
      }
        
      // Validate input
      if (!fullName && !gender && !employmentType && !designation && !dateOfBirth) {
        return res.status(400).json({ error: 'At least one field must be provided for update' });
      }
      const updateData = {};
      if (fullName) {
        if (typeof fullName !== 'string' || fullName.trim().length === 0) {
          return res.status(400).json({ error: 'Full name must be a non-empty string' });
        }
        updateData.fullName = fullName.trim();
      }
      if (gender) {
        if (!['MALE', 'FEMALE', 'OTHER'].includes(gender)) {
          return res.status(400).json({ error: 'Invalid gender: Must be MALE, FEMALE, or OTHER' });
        }
        updateData.gender = gender;
      }
      if (employmentType) {
        if (!['PERMANENT', 'CONTRACTUAL', 'INTERNSHIP'].includes(employmentType)) {
          return res.status(400).json({ error: 'Invalid employment type: Must be PERMANENT, CONTRACTUAL, or INTERNSHIP' });
        }
        updateData.employmentType = employmentType;
      }
      if (designation) {
        if (typeof designation !== 'string' || designation.trim().length === 0) {
          return res.status(400).json({ error: 'Designation must be a non-empty string' });
        }
        updateData.designation = designation.trim();
      }
      if (dateOfBirth) {
        const dob = new Date(dateOfBirth);
        if (isNaN(dob.getTime()) || dob > new Date()) {
          return res.status(400).json({ error: 'Invalid or future date of birth' });
        }
        const minAgeDate = new Date();
        minAgeDate.setFullYear(minAgeDate.getFullYear() - 16);
        if (dob > minAgeDate) {
          return res.status(400).json({ error: 'User must be at least 16 years old' });
        }
        updateData.dateOfBirth = dob;
      }
  
      // Check profile exists and authorization
      const profile = await prisma.profile.findUnique({
        where: { id: profileId, deletedAt: null },
        select: { userId: true, user: { select: { email: true } } },
      });
      if (!profile) {
        return res.status(404).json({ error: 'Profile not found' });
      }
      if (profile.userId !== userId) {
        return res.status(403).json({ error: 'Unauthorized: You can only update your own profile' });
      }
  
      // Update profile
      const updatedProfile = await prisma.profile.update({
        where: { id: profileId },
        data: updateData,
        select: {
          id: true,
          fullName: true,
          gender: true,
          employmentType: true,
          designation: true,
          dateOfBirth: true,
          createdAt: true,
          updatedAt: true,
          userId: true,
        },
      });
  
      // Send email notification
      try {
        await passwordChangeAlertMail({
          email: profile.user.email,
          name: updatedProfile.fullName || profile.user.email,
          message: 'Your profile has been updated successfully.',
        });
      } catch (emailError) {
        console.warn('Failed to send profile update email:', emailError);
      }
  
      res.status(200).json(updatedProfile);
    } catch (error) {
      console.error('Update profile error:', error);
      if (error.code === 'P2025') {
        return res.status(404).json({ error: 'Profile not found' });
      }
      next(error);
    }
  });
  module.exports = profileRouter;