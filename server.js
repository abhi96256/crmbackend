const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const pool = require('./config/db.js');
const authRoutes = require('./routes/auth.js');
const leadRoutes = require('./routes/leads.js');
const userRoutes = require('./routes/users.js');
const pipelineRoutes = require('./routes/pipeline.js');
const tasksRoutes = require('./routes/tasks.js');
const mailRoutes = require('./routes/mail.js');
const activityLogRoutes = require('./routes/activityLogs.js');
const adminRoutes = require('./routes/admin.js');
const linkedinRoutes = require('./routes/linkedin.js');
const invoiceRoutes = require('./routes/invoices.js');
const groupRoutes = require('./routes/groups.js');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
  origin: true, // Allow all origins temporarily for testing
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Origin', 'Accept', 'X-Requested-With'],
  preflightContinue: false,
  optionsSuccessStatus: 204
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Test database connection
const testDatabaseConnection = async () => {
  try {
    // Check if we're using PostgreSQL or MySQL
    if (process.env.DB_DRIVER === 'postgresql') {
      const client = await pool.connect();
      console.log('✅ Connected to PostgreSQL Database:', process.env.DB_NAME);
      client.release();
    } else {
      const connection = await pool.getConnection();
      console.log('✅ Connected to MySQL Database');
      connection.release();
    }
  } catch (err) {
    console.error('❌ Database connection error:', err.message);
    if (process.env.DB_DRIVER === 'postgresql') {
      console.log('💡 Please check your PostgreSQL configuration on Render');
    } else {
      console.log('💡 Please make sure MySQL is running and database exists');
    }
  }
};

// Test connection on startup
testDatabaseConnection();

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/leads', leadRoutes);
app.use('/api/users', userRoutes);
app.use('/api/pipeline', pipelineRoutes);
app.use('/api/tasks', tasksRoutes);
app.use('/api/mail', mailRoutes);
app.use('/api/activity-logs', activityLogRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/linkedin', linkedinRoutes);
app.use('/api/invoices', invoiceRoutes);
app.use('/api/groups', groupRoutes);

// Health check route
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Enhanced health check route
app.get('/api/health', async (req, res) => {
  try {
    // Test database connection
    const { db } = require('./utils/database.js');
    const dbHealth = await db.testConnection();
    
    res.json({
      status: 'OK',
      message: 'Server and database are running',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development',
      database: dbHealth
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      message: 'Server error during health check',
      timestamp: new Date().toISOString(),
      error: error.message
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
}); 