// Configuration file for database connection
// This will be used to set up the database connection

const config = {
  // Database Configuration for Render PostgreSQL
  database: {
    driver: 'postgresql',
    // You need to get these values from your Render PostgreSQL database
    host: process.env.DB_HOST || 'dpg-cp1234567890-a.oregon-postgres.render.com',
    user: process.env.DB_USER || 'crm_database_elhl_user',
    password: process.env.DB_PASSWORD || 'your_actual_password',
    database: process.env.DB_NAME || 'crm_database_elhl',
    port: process.env.DB_PORT || 5432,
    ssl: { rejectUnauthorized: false }
  },
  
  // Server Configuration
  server: {
    port: process.env.PORT || 5000,
    renderUrl: 'https://crmbackend-fahc.onrender.com'
  }
};

module.exports = config;
