const express = require('express');
const profileRouter = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { identifyUser } = require('../utils/middleware');
// const { passwordChangeAlertMail } = require('../utils/mail'); // Make sure this is correct

// PATCH /profile/:id — Update profile
profileRouter.patch('/:id', identifyUser, async (req, res, next) => {
  try {
    const profileId = parseInt(req.params.id, 10);
    const userId = req.user.id;

    if (isNaN(profileId)) {
      return res.status(400).json({ error: 'Invalid profile ID' });
    }

    const {
      fullName,
      email,
      employmentType,
      designation,
      gender,
      dateOfBirth,
      profilePicture,
    } = req.body;

    // Validate at least one field is provided
    if (!fullName && !email && !employmentType && !designation && !gender && !dateOfBirth) {
      return res.status(400).json({ error: 'At least one field must be provided for update' });
    }

    const updateData = {};

    // Field validations
    if (fullName) {
      if (typeof fullName !== 'string' || fullName.trim().length === 0) {
        return res.status(400).json({ error: 'Full name must be a non-empty string' });
      }
      updateData.fullName = fullName.trim();
    }

    if (employmentType) {
      const validTypes = ['PERMANENT', 'CONTRACTUAL', 'INTERNSHIP'];
      if (!validTypes.includes(employmentType)) {
        return res.status(400).json({ error: 'Invalid employment type' });
      }
      updateData.employmentType = employmentType;
    }

    if (designation) {
      if (typeof designation !== 'string' || designation.trim().length === 0) {
        return res.status(400).json({ error: 'Designation must be a non-empty string' });
      }
      updateData.designation = designation.trim();
    }

    if (gender) {
      const validGenders = ['MALE', 'FEMALE', 'OTHER'];
      if (!validGenders.includes(gender)) {
        return res.status(400).json({ error: 'Invalid gender' });
      }
      updateData.gender = gender;
    }

    if (dateOfBirth) {
      const date = new Date(dateOfBirth);
      if (isNaN(date.getTime())) {
        return res.status(400).json({ error: 'Invalid date of birth' });
      }
      updateData.dateOfBirth = date;
    }

    // Fetch profile and check authorization
    const profile = await prisma.profile.findUnique({
      where: { id: profileId, deletedAt: null },
      select: {
        userId: true,
        user: { select: { email: true, id: true } }
      }
    });

    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    if (profile.userId !== userId) {
      return res.status(403).json({ error: 'Unauthorized to update this profile' });
    }

    // If email is being updated, update it in the user table
    if (email) {
      if (typeof email !== 'string' || email.trim().length === 0) {
        return res.status(400).json({ error: 'Email must be a non-empty string' });
      }

      await prisma.user.update({
        where: { id: profile.user.id },
        data: { email: email.trim() }
      });
    }

    // Update profile fields
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
        profilePicture: true,
        userId: true,
        user: { select: { email: true } }
      }
    });

    // Send profile update email
    try {
      await passwordChangeAlertMail({
        email: updatedProfile.user.email,
        name: updatedProfile.fullName || updatedProfile.user.email,
        message: 'Your profile has been updated successfully.'
      });
    } catch (emailError) {
      console.warn('Failed to send update email:', emailError.message);
    }

    res.status(200).json(updatedProfile);

  } catch (error) {
    console.error('Profile update error:', error);
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Profile not found' });
    }
    next(error);
  }
});

module.exports = profileRouter;
