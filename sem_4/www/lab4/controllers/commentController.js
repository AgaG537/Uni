const Comment = require('../models/Comment');

exports.createComment = async (req, res, next) => {
  try {
    const { content, event } = req.body;
    if (!content || !event) {
      return res.status(400).json({ message: 'Content and event ID are required.' });
    }
    const comment = new Comment({ ...req.body, author: req.user.id });
    await comment.save();
    res.status(201).json(comment);
  } catch (err) {
    next(err);
  }
};

exports.getCommentsForEvent = async (req, res, next) => {
  try {
    const comments = await Comment.find({ event: req.params.eventId })
      .populate('event')
      .populate('author');
    res.json(comments);
  } catch (err) {
    next(err);
  }
};

exports.deleteComment = async (req, res, next) => {
  try {
    const deleted = await Comment.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ message: 'Comment not found' });
    }
    res.sendStatus(204);
  } catch (err) {
    next(err);
  }
};
