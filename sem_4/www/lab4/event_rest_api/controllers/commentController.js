// const Comment = require('../models/Comment');

// exports.createComment = async (req, res, next) => {
//   try {
//     const { content, event } = req.body;
//     if (!content || !event) {
//       return res.status(400).json({ message: 'Content and event ID are required.' });
//     }
//     const comment = new Comment({ ...req.body, author: req.user.id });
//     await comment.save();
//     res.status(201).json(comment);
//   } catch (err) {
//     next(err);
//   }
// };

// exports.getCommentsForEvent = async (req, res, next) => {
//   try {
//     const comments = await Comment.find({ event: req.params.eventId })
//       .populate('event')
//       .populate('author');
//     res.json(comments);
//   } catch (err) {
//     next(err);
//   }
// };

// exports.deleteComment = async (req, res, next) => {
//   try {
//     const deleted = await Comment.findByIdAndDelete(req.params.id);
//     if (!deleted) {
//       return res.status(404).json({ message: 'Comment not found' });
//     }
//     res.sendStatus(204);
//   } catch (err) {
//     next(err);
//   }
// };


const Comment = require('../models/Comment');
// Nie potrzebujemy już importować modelu User, ponieważ rola i id użytkownika
// są już dostępne w req.user z middleware'u auth.js

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
      .populate('event') // Populujemy tylko title eventu, jeśli potrzebne
      .populate('author'); // Populujemy tylko username autora, aby nie wysyłać wrażliwych danych
    res.json(comments);
  } catch (err) {
    next(err);
  }
};

exports.deleteComment = async (req, res, next) => {
  try {
    const comment = await Comment.findById(req.params.id);

    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    // req.user.id oraz req.user.role są już dostępne dzięki Twojemu middleware'owi auth.js

    // Sprawdzanie uprawnień:
    // Użytkownik jest adminem LUB użytkownik jest autorem komentarza
    if (req.user.role === 'admin' || comment.author.toString() === req.user.id) {
      // Jeśli uprawnienia są wystarczające, usuwamy komentarz
      await Comment.findByIdAndDelete(req.params.id);
      return res.sendStatus(204); // Zwraca 204 No Content, sygnalizując sukces usunięcia
    } else {
      // Użytkownik nie jest adminem i nie jest autorem komentarza
      return res.status(403).json({ message: 'You are not authorized to delete this comment.' });
    }
  } catch (err) {
    // Obsługa błędu, np. gdy ID jest w złym formacie (CastError)
    if (err.name === 'CastError') {
      return res.status(400).json({ message: 'Invalid comment ID format.' });
    }
    next(err); // Przekazanie innych błędów do globalnego handlera błędów
  }
};