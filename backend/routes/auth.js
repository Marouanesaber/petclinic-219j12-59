
import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key';

// Middleware to verify JWT token
const verifyToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }

  try {
    const verified = jwt.verify(token, JWT_SECRET);
    req.user = verified;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Register a new user
router.post('/register', async (req, res) => {
  const db = req.db;
  const { name, email, password } = req.body;
  
  try {
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email and password are required' });
    }
    
    // Check if user already exists
    const [existingUsers] = await db.promise().query('SELECT * FROM users WHERE email = ?', [email]);
    
    if (existingUsers.length > 0) {
      return res.status(409).json({ error: 'User with this email already exists' });
    }
    
    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    // Create new user
    const query = `INSERT INTO users (name, email, password, profile_picture, role) 
                  VALUES (?, ?, ?, ?, ?)`;
    
    const defaultProfilePic = `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0D8ABC&color=fff`;
    const role = 'user'; // Default role
    
    const [result] = await db.promise().query(query, [name, email, hashedPassword, defaultProfilePic, role]);
    
    // Generate token
    const token = jwt.sign({ id: result.insertId, email, role }, JWT_SECRET, { expiresIn: '1h' });
    
    res.status(201).json({ 
      id: result.insertId,
      token,
      message: 'User registered successfully'
    });
  } catch (error) {
    console.error('Error during registration:', error);
    res.status(500).json({ error: 'Error during registration' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const db = req.db;
  const { email, password } = req.body;
  
  try {
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    
    const [users] = await db.promise().query('SELECT * FROM users WHERE email = ?', [email]);
    
    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    
    const user = users[0];
    
    // Compare password with hashed password in DB
    const match = await bcrypt.compare(password, user.password);
    
    if (!match) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    
    // Generate token
    const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '1h' });
    
    // Return user info (excluding password)
    const userInfo = {
      id: user.id,
      name: user.name,
      email: user.email,
      profilePicture: user.profile_picture,
      role: user.role
    };
    
    res.status(200).json({ 
      message: 'Login successful',
      token,
      user: userInfo
    });
    
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ error: 'Error during login' });
  }
});

// Get user profile
router.get('/profile', verifyToken, async (req, res) => {
  const db = req.db;
  const userId = req.user.id;
  
  try {
    const [users] = await db.promise().query('SELECT id, name, email, profile_picture, role FROM users WHERE id = ?', [userId]);
    
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.status(200).json(users[0]);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Error fetching profile' });
  }
});

// Update user profile
router.put('/profile', verifyToken, async (req, res) => {
  const db = req.db;
  const userId = req.user.id;
  const { name, email, profilePicture } = req.body;
  
  try {
    // Build the query based on provided fields
    let query = 'UPDATE users SET ';
    const values = [];
    const updates = [];
    
    if (name) {
      updates.push('name = ?');
      values.push(name);
    }
    
    if (email) {
      updates.push('email = ?');
      values.push(email);
    }
    
    if (profilePicture) {
      updates.push('profile_picture = ?');
      values.push(profilePicture);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }
    
    query += updates.join(', ') + ' WHERE id = ?';
    values.push(userId);
    
    const [result] = await db.promise().query(query, values);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Get updated user profile
    const [users] = await db.promise().query('SELECT id, name, email, profile_picture, role FROM users WHERE id = ?', [userId]);
    
    res.status(200).json({
      message: 'Profile updated successfully',
      user: users[0]
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Error updating profile' });
  }
});

export default router;
