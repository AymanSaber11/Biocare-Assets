import pkg from 'pg';
import config from './index.js';

const { Pool } = pkg;

const pool = new Pool({
  host: config.database.host,
  port: config.database.port,
  user: config.database.user,
  password: config.database.password,
  database: config.database.database,
  min: config.database.poolMin,
  max: config.database.poolMax,
});

// Event listeners
pool.on('connect', () => {
  console.log('✓ Database connected');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

pool.on('remove', () => {
  console.log('✓ Client removed from pool');
});

// Test connection
pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('Database connection test failed:', err);
  } else {
    console.log('✓ Database connection test successful');
  }
});

export default pool;
