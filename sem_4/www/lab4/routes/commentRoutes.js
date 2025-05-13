const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const controller = require('../controllers/commentController');

router.post('/', auth(), controller.createComment);
router.get('/event/:eventId', controller.getCommentsForEvent);
router.delete('/:id', auth(), controller.deleteComment);

module.exports = router;
