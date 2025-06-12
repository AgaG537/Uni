const express = require('express');
const router = express.Router();
const { login, googleSignIn } = require('../controllers/authController');

router.post('/login', login);
router.post('/google', googleSignIn);

module.exports = router;