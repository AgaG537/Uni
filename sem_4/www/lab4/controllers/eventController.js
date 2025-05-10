// controllers/eventController.js
const Event = require('../models/Event');

exports.createEvent = async (req, res, next) => {
  try {
    const { date } = req.body;

    if (!date || isNaN(Date.parse(date))) {
      return res.status(400).json({ message: 'Invalid or missing date' });
    }

    const event = new Event({ ...req.body, creator: req.user.id });
    await event.save();
    res.status(201).json(event);
  } catch (err) {
    next(err);
  }
};


exports.getEvents = async (req, res, next) => {
  try {
    const { page = 1, limit = 10, sortBy = 'date', creator } = req.query;
    const filter = creator ? { creator } : {};
    const events = await Event.find(filter)
      .sort({ [sortBy]: 1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    res.json(events);
  } catch (err) {
    next(err);
  }
};

exports.deleteEvent = async (req, res, next) => {
  try {
    const deleted = await Event.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ message: 'Event not found' });
    }
    res.sendStatus(204);
  } catch (err) {
    next(err);
  }
};
