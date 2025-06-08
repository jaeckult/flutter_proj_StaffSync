const express = require('express');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const holidayRouter = express.Router()
holidayRouter.get('/', async (req, res) => {
    try {
        const holidayEntries = await prisma.holiday.findMany();
        res.status(200).json(holidayEntries);
    }
    catch(e){
        console.error(e);
        res.status(404).json("Holiday Entry not Found!")

    }

})
holidayRouter.post('/', async (req, res) => {
    try {
        const {
      title,
      startDate,
      endDate,
      description,
      createdById
    } = req.body;
    if (!title || !startDate || !endDate) {
      return res.status(400).json({ error: 'Title, startDate, and endDate are required.' });
    }

    const holiday = await prisma.holiday.create({
      data: {
        title,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        description,
        createdById
      }
    });

    res.status(201).json(holiday);

    }
    catch(e){
        console.error(e);
        res.status(500).json({ error: 'Internal server error' });

    }

})
 module.exports = holidayRouter;