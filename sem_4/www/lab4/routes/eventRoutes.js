const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const controller = require('../controllers/eventController');

router.post('/', auth(), controller.createEvent);
router.get('/', controller.getEvents);
router.delete('/:id', auth(), controller.deleteEvent);

module.exports = router;
