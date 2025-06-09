const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const userController = require('../controllers/userController');

router.post('/register', userController.registerUser);
router.post('/register-admin', auth(['admin']), userController.registerAdmin);
router.get('/', auth(['admin']), userController.getAllUsers);
router.delete('/:id', auth(['admin']), userController.deleteUser);

module.exports = router;