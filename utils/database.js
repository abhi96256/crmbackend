import pool from '../config/db.js';

// Determine which database driver to use
const usePostgreSQL = process.env.DB_DRIVER === 'postgresql';

// Unified database interface
export const db = {
  // Execute queries with parameters
  async execute(query, params = []) {
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
  },

  // Execute queries without parameters
  async query(query) {
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
  },

  // Get a connection (for transactions)
  async getConnection() {
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
  }
};

export default db;
