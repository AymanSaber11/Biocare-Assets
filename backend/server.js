import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import 'express-async-errors';
import config from './config/index.js';

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: config.cors.origin,
    methods: config.cors.methods,
    credentials: config.cors.credentials,
  },
});

// Security Middleware
app.use(helmet());
app.use(compression());
app.use(cors(config.cors));

// Request logging
app.use(morgan('combined'));

// Rate limiting
const limiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.maxRequests,
  message: 'Too many requests from this IP, please try again later.',
});
app.use(limiter);

// Body parsing
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ limit: '10kb', extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date(),
    uptime: process.uptime(),
    environment: config.nodeEnv,
  });
});

// API Routes (to be implemented)
app.get('/api/v1', (req, res) => {
  res.status(200).json({
    message: 'Biocare Assets CMMS API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/v1/auth',
      assets: '/api/v1/assets',
      maintenance: '/api/v1/maintenance',
      notifications: '/api/v1/notifications',
      admin: '/api/v1/admin',
    },
  });
});

// Socket.io connection
io.on('connection', (socket) => {
  console.log(`Client connected: ${socket.id}`);

  // Handle events
  socket.on('join-room', (biomedicalId) => {
    socket.join(`biomedical-${biomedicalId}`);
    console.log(`Client joined room: biomedical-${biomedicalId}`);
  });

  socket.on('leave-room', (biomedicalId) => {
    socket.leave(`biomedical-${biomedicalId}`);
    console.log(`Client left room: biomedical-${biomedicalId}`);
  });

  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
  });

  socket.on('error', (error) => {
    console.error(`Socket error: ${error}`);
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: `Route ${req.originalUrl} not found`,
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);

  const status = err.status || err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  res.status(status).json({
    status: 'error',
    message,
    ...(config.nodeEnv === 'development' && { stack: err.stack }),
  });
});

// Start server
const PORT = config.port;

httpServer.listen(PORT, () => {
  console.log(`\n🚀 ${config.appName} Server is running on port ${PORT}`);
  console.log(`📝 Environment: ${config.nodeEnv}`);
  console.log(`🌐 CORS Origin: ${config.cors.origin}`);
  console.log(`📡 WebSocket URL: ${config.socketio.url}\n`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('\n✋ SIGTERM received. Shutting down gracefully...');
  httpServer.close(() => {
    console.log('✓ Server closed');
    process.exit(0);
  });
});

export { app, httpServer, io };
