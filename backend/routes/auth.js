
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
    // Validation
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email and password are required' });
    }
    
    // Split name into first_name and last_name (simple approach)
    const nameParts = name.trim().split(' ');
    const firstName = nameParts[0] || '';
    const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';
    
    console.log(`Registering user: ${firstName} ${lastName}, ${email}`);
    
    // Check if user already exists
    const [existingUsers] = await db.promise().query('SELECT * FROM users WHERE email = ?', [email]);
    
    if (existingUsers.length > 0) {
      return res.status(409).json({ error: 'User with this email already exists' });
    }
    
    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    // Create username from email (before the @ symbol)
    const username = email.split('@')[0];
    
    // Create new user with first_name and last_name and username
    const query = `INSERT INTO users (username, first_name, last_name, email, password, profile_picture, role) 
                  VALUES (?, ?, ?, ?, ?, ?, ?)`;
    
    const defaultProfilePic = `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0D8ABC&color=fff`;
    const role = 'user'; // Default role
    
    const [result] = await db.promise().query(query, [username, firstName, lastName, email, hashedPassword, defaultProfilePic, role]);
    
    // Generate token
    const token = jwt.sign({ id: result.insertId, email, role }, JWT_SECRET, { expiresIn: '7d' });
    
    // Create user object with name field for client compatibility
    const user = {
      id: result.insertId,
      name: `${firstName} ${lastName}`,
      email,
      profilePicture: defaultProfilePic,
      role
    };
    
    res.status(201).json({ 
      id: result.insertId,
      token,
      user,
      message: 'User registered successfully'
    });
  } catch (error) {
    console.error('Error during registration:', error);
    res.status(500).json({ error: 'Error during registration: ' + error.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  const db = req.db;
  const { email, password } = req.body;
  
  try {
    console.log("Login attempt for:", email);
    
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    
    const [users] = await db.promise().query('SELECT * FROM users WHERE email = ?', [email]);
    console.log("Found users:", users.length);
    
    if (users.length === 0) {
      console.log("No user found with email:", email);
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    
    const user = users[0];
    
    // Compare password with hashed password in DB
    const match = await bcrypt.compare(password, user.password);
    console.log("Password match:", match);
    
    if (!match) {
      console.log("Invalid password for user:", email);
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    
    // Generate token with extended expiration
    const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    
    // Create user object with name field for client compatibility
    const userInfo = {
      id: user.id,
      name: user.first_name && user.last_name ? `${user.first_name} ${user.last_name}` : user.email,
      email: user.email,
      profilePicture: user.profile_picture || null,
      role: user.role
    };
    
    console.log("Login successful for:", email);
    res.status(200).json({ 
      message: 'Login successful',
      token,
      user: userInfo
    });
    
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ error: 'Error during login: ' + error.message });
  }
});

// Verify token and refresh user session
router.get('/verify', async (req, res) => {
  const token = req.headers['authorization']?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const db = req.db;
    
    // Get fresh user data
    const [users] = await db.promise().query('SELECT id, first_name, last_name, email, profile_picture, role FROM users WHERE id = ?', [decoded.id]);
    
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const user = users[0];
    
    // Generate a new token to extend the session
    const newToken = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    // Create user object with name field for client compatibility
    const userInfo = {
      id: user.id,
      name: user.first_name && user.last_name ? `${user.first_name} ${user.last_name}` : user.email,
      email: user.email,
      profilePicture: user.profile_picture,
      role: user.role
    };
    
    res.status(200).json({
      valid: true,
      token: newToken,
      user: userInfo
    });
  } catch (error) {
    res.status(401).json({ valid: false, error: 'Invalid token' });
  }
});

// Logout endpoint (invalidate token)
router.post('/logout', async (req, res) => {
  res.status(200).json({ message: 'Logout successful' });
});

// Get user profile
router.get('/profile', verifyToken, async (req, res) => {
  const db = req.db;
  const userId = req.user.id;
  
  try {
    const [users] = await db.promise().query('SELECT id, first_name, last_name, email, profile_picture, role FROM users WHERE id = ?', [userId]);
    
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const user = users[0];
    
    // Create user object with name field for client compatibility
    const userInfo = {
      id: user.id,
      name: user.first_name && user.last_name ? `${user.first_name} ${user.last_name}` : user.email,
      email: user.email,
      profilePicture: user.profile_picture,
      role: user.role
    };
    
    res.status(200).json(userInfo);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Error fetching profile: ' + error.message });
  }
});

// Update user profile
router.put('/profile', verifyToken, async (req, res) => {
  const db = req.db;
  const userId = req.user.id;
  const { name, email, profilePicture } = req.body;
  
  try {
    // First, let's modify the users table to ensure profile_picture can handle larger data
    // This only needs to be run once, but we'll check first if we need to alter the table
    const [columns] = await db.promise().query("SHOW COLUMNS FROM users LIKE 'profile_picture'");
    
    // If the profile_picture field is not MEDIUMTEXT, alter it
    if (columns.length > 0 && columns[0].Type !== 'MEDIUMTEXT') {
      await db.promise().query("ALTER TABLE users MODIFY profile_picture MEDIUMTEXT");
      console.log("Modified profile_picture column to MEDIUMTEXT");
    }
    
    // Build the query based on provided fields
    let query = 'UPDATE users SET ';
    const values = [];
    const updates = [];
    
    // If name provided, split into first_name and last_name
    if (name) {
      const nameParts = name.trim().split(' ');
      const firstName = nameParts[0];
      const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';
      
      updates.push('first_name = ?');
      values.push(firstName);
      
      updates.push('last_name = ?');
      values.push(lastName);
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
    const [users] = await db.promise().query('SELECT id, first_name, last_name, email, profile_picture, role FROM users WHERE id = ?', [userId]);
    
    const user = users[0];
    
    // Create user object with name field for client compatibility
    const userInfo = {
      id: user.id,
      name: user.first_name && user.last_name ? `${user.first_name} ${user.last_name}` : user.email,
      email: user.email,
      profilePicture: user.profile_picture,
      role: user.role
    };
    
    res.status(200).json({
      message: 'Profile updated successfully',
      user: userInfo
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Error updating profile: ' + error.message });
  }
});

export default router;
