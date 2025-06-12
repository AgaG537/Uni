const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { OAuth2Client } = require('google-auth-library');

const CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const client = new OAuth2Client(CLIENT_ID);

exports.login = async (req, res, next) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });

    if (!user) return res.status(401).json({ message: 'Invalid credentials' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { 
        expiresIn: '1d',
        algorithm: 'HS256'
      }
    );

    // Set cookie (for web browser clients)
    res.cookie('token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'Strict',
      maxAge: 24 * 60 * 60 * 1000 // 1 day
    });

    // Also return the token for API clients like Flutter
    res.status(200).json({ 
      message: 'Logged in successfully',
      token: token,
      user: { id: user._id, username: user.username, role: user.role }
    });
  } catch (err) {
    next(err);
  }
};

// Google Sign-In handler
exports.googleSignIn = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ error: 'idToken is required' });
    }

    // Verify the Google ID token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: CLIENT_ID,
    });
    const payload = ticket.getPayload();

    if (!payload || !payload.email_verified) {
      return res.status(401).json({ error: 'Google token not valid or email not verified' });
    }

    const email = payload.email;

    let user = await User.findOne({ username: email });
    let role = 'user';

    if (!user) {
      // Auto-create a user if they don't exist
      const hashedPassword = await bcrypt.hash(email + Date.now(), 10);
      const newUser = new User({
        username: email,
        password: hashedPassword,
        role: 'user',
      });
      user = await newUser.save();
    } else {
        role = user.role;
    }

    // Issue your own JWT
    const appToken = jwt.sign(
      { id: user._id, role },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    // Set cookie (for web browser clients)
    res.cookie('token', appToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'Strict',
      maxAge: 24 * 60 * 60 * 1000 // 1 day
    });

    return res.status(200).json({
      message: 'Logged in successfully with Google',
      token: appToken,
      user: { id: user._id, username: user.username, role: role }
    });
  } catch (err) {
    console.error('Error in /auth/google:', err);
    return res.status(500).json({ error: 'Google login failed' });
  }
};