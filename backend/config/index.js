import dotenv from 'dotenv';

dotenv.config();

const config = {
  // Server Configuration
  port: parseInt(process.env.PORT) || 5000,
  nodeEnv: process.env.NODE_ENV || 'development',
  appName: 'Biocare Assets CMMS',
  appVersion: '1.0.0',

  // Database Configuration
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'biocare_assets',
    poolMin: parseInt(process.env.DB_POOL_MIN) || 2,
    poolMax: parseInt(process.env.DB_POOL_MAX) || 10,
  },

  // JWT Configuration
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key-change-this',
    expiresIn: process.env.JWT_EXPIRE || '7d',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'your-refresh-secret',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRE || '30d',
  },

  // CORS Configuration
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:5173',
    methods: (process.env.CORS_METHODS || 'GET,POST,PUT,DELETE,PATCH').split(','),
    credentials: process.env.CORS_CREDENTIALS === 'true',
  },

  // Socket.io Configuration
  socketio: {
    url: process.env.WEBSOCKET_URL || 'http://localhost:5000',
    corsOrigin: process.env.WEBSOCKET_CORS_ORIGIN || 'http://localhost:5173',
  },

  // Email Configuration
  email: {
    smtp: {
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT) || 587,
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
    from: process.env.SMTP_FROM || 'noreply@biocare-assets.com',
  },

  // Logging Configuration
  logging: {
    level: process.env.LOG_LEVEL || 'debug',
    format: process.env.LOG_FORMAT || 'json',
  },

  // File Upload Configuration
  upload: {
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE) || 5242880, // 5MB
    path: process.env.UPLOAD_PATH || './uploads',
    allowedTypes: (process.env.ALLOWED_FILE_TYPES || 'pdf,jpg,jpeg,png,doc,docx').split(','),
  },

  // Rate Limiting
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000, // 15 minutes
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  },

  // API Documentation
  swagger: {
    url: process.env.SWAGGER_URL || '/api/docs',
  },

  // Timezone
  timezone: process.env.TIMEZONE || 'UTC',

  // Feature Flags
  features: {
    enableNotifications: true,
    enableAuditLog: true,
    enableFileUpload: true,
    enableEmailNotifications: process.env.SMTP_USER ? true : false,
  },

  // API Configuration
  api: {
    prefix: '/api/v1',
    timeout: 30000,
  },
};

// Validation
if (config.nodeEnv === 'production') {
  if (!process.env.JWT_SECRET || process.env.JWT_SECRET === 'your-secret-key-change-this') {
    throw new Error('JWT_SECRET must be set in production');
  }
  if (!process.env.DB_PASSWORD) {
    throw new Error('DB_PASSWORD must be set in production');
  }
}

export default config;
