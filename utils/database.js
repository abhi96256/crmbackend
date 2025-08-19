const pool = require('../config/db.js');

// Determine which database driver to use
const usePostgreSQL = process.env.DB_DRIVER === 'postgresql';

// Retry configuration
const MAX_RETRIES = 3;
const RETRY_DELAY = 1000;

// Helper function to wait
const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Helper function to retry operations
const retryOperation = async (operation, retries = MAX_RETRIES) => {
  try {
    return await operation();
  } catch (error) {
    if (retries > 0 && (error.code === 'ECONNRESET' || error.code === 'ENOTFOUND' || error.message.includes('Connection terminated'))) {
      console.log(`Database connection error, retrying... (${retries} attempts left)`);
      await wait(RETRY_DELAY);
      return retryOperation(operation, retries - 1);
    }
    throw error;
  }
};

// Unified database interface
const db = {
  // Execute queries with parameters
  async execute(query, params = []) {
    return retryOperation(async () => {
      try {
        if (usePostgreSQL) {
          // PostgreSQL uses pool.query()
          const result = await pool.query(query, params);
          return [result.rows, result.fields];
        } else {
          // MySQL uses pool.execute()
          return await pool.execute(query, params);
        }
      } catch (error) {
        console.error('Database execute error:', error);
        throw error;
      }
    });
  },

  // Execute queries without parameters
  async query(query) {
    return retryOperation(async () => {
      try {
        if (usePostgreSQL) {
          const result = await pool.query(query);
          return [result.rows, result.fields];
        } else {
          return await pool.query(query);
        }
      } catch (error) {
        console.error('Database query error:', error);
        throw error;
      }
    });
  },

  // Get a connection (for transactions)
  async getConnection() {
    return retryOperation(async () => {
      try {
        if (usePostgreSQL) {
          return await pool.connect();
        } else {
          return await pool.getConnection();
        }
      } catch (error) {
        console.error('Database getConnection error:', error);
        throw error;
      }
    });
  },

  // Release a connection
  async releaseConnection(connection) {
    try {
      if (usePostgreSQL) {
        connection.release();
      } else {
        connection.release();
      }
    } catch (error) {
      console.error('Database releaseConnection error:', error);
    }
  },

  // Begin transaction
  async beginTransaction(connection) {
    try {
      if (usePostgreSQL) {
        await connection.query('BEGIN');
      } else {
        await connection.beginTransaction();
      }
    } catch (error) {
      console.error('Database beginTransaction error:', error);
      throw error;
    }
  },

  // Commit transaction
  async commitTransaction(connection) {
    try {
      if (usePostgreSQL) {
        await connection.query('COMMIT');
      } else {
        await connection.commit();
      }
    } catch (error) {
      console.error('Database commitTransaction error:', error);
      throw error;
    }
  },

  // Rollback transaction
  async rollbackTransaction(connection) {
    try {
      if (usePostgreSQL) {
        await connection.query('ROLLBACK');
      } else {
        await connection.rollback();
      }
    } catch (error) {
      console.error('Database rollbackTransaction error:', error);
      throw error;
    }
  },

  // Test connection health
  async testConnection() {
    try {
      if (usePostgreSQL) {
        const result = await pool.query('SELECT NOW()');
        return { status: 'healthy', timestamp: result.rows[0].now };
      } else {
        const [rows] = await pool.execute('SELECT 1 as test');
        return { status: 'healthy', timestamp: new Date() };
      }
    } catch (error) {
      return { status: 'unhealthy', error: error.message };
    }
  }
};

module.exports = { db, default: db };
