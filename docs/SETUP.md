# Biocare Assets - Setup Guide

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** >= 14.0.0 ([Download](https://nodejs.org/))
- **PostgreSQL** >= 12 ([Download](https://www.postgresql.org/download/))
- **Git** ([Download](https://git-scm.com/))
- **npm** or **yarn**

## 🚀 Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/AymanSaber11/Biocare-Assets.git
cd Biocare-Assets
```

### Step 2: Database Setup

#### 2.1 Create PostgreSQL Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create the database
CREATE DATABASE biocare_assets;

# Exit PostgreSQL
\q
```

#### 2.2 Initialize Database Schema

```bash
# Navigate to backend
cd backend

# Initialize the database schema
psql -U postgres -d biocare_assets -f ../database/schema.sql
```

### Step 3: Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
# Recommended values:
# PORT=5000
# NODE_ENV=development
# DB_HOST=localhost
# DB_PORT=5432
# DB_USER=postgres
# DB_PASSWORD=your_password
# DB_NAME=biocare_assets
# JWT_SECRET=your_secret_key_here
```

#### 3.1 Start Backend Server

```bash
# Development mode (with hot reload)
npm run dev

# Or production mode
npm start
```

The backend will start at `http://localhost:5000`

**API Health Check:** `http://localhost:5000/health`

### Step 4: Frontend Setup

#### 4.1 Navigate to Frontend Directory

```bash
# From project root
cd frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env if needed
# Default configuration should work for local development
```

#### 4.2 Start Frontend Server

```bash
npm run dev
```

The frontend will start at `http://localhost:5173`

## 🔐 Authentication Setup

### Default Admin User

After initializing the database, you'll need to create an admin user. Connect to the database and insert:

```sql
INSERT INTO users (
  first_name, last_name, email, password_hash, role, status
) VALUES (
  'Admin',
  'User',
  'admin@biocare.local',
  '$2a$10$...',  -- bcrypt hash of your password
  'admin',
  'active'
);
```

Or use the API endpoint to register:

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Admin",
    "last_name": "User",
    "email": "admin@biocare.local",
    "password": "SecurePassword123!",
    "role": "admin"
  }'
```

## 📊 Database Schema Overview

### Main Tables:

1. **users** - System users with role-based access
2. **biomedicals** - Healthcare facility information
3. **departments** - Department/unit organization
4. **assets** - Biomedical equipment inventory
5. **pm_schedules** - Preventive maintenance schedules
6. **cm_requests** - Corrective maintenance requests
7. **maintenance_history** - Complete maintenance audit trail
8. **notifications** - Real-time notification system
9. **audit_logs** - User activity tracking

See [DATABASE.md](./docs/DATABASE.md) for detailed schema information.

## 🧪 Testing

### Backend Tests

```bash
cd backend
npm test
npm run test:watch
```

### Frontend Tests

```bash
cd frontend
npm test
npm run test:watch
```

## 📚 Project Structure

```
Biocare-Assets/
├── backend/
│   ├── config/           # Configuration management
│   ├── database/         # Database schema and migrations
│   ├── middleware/       # Express middleware
│   ├── models/           # Data models
│   ├── routes/           # API routes
│   ├── controllers/      # Route controllers
│   ├── services/         # Business logic
│   ├── server.js         # Express server entry point
│   ├── package.json
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── pages/        # Page components
│   │   ├── services/     # API services
│   │   ├── hooks/        # Custom hooks
│   │   ├── context/      # React context
│   │   ├── store/        # State management (Zustand)
│   │   └── App.jsx
│   ├── package.json
│   └── .env.example
├── docs/                 # Documentation
└── README.md
```

## 🔧 Common Issues & Solutions

### Issue: Database Connection Error

**Solution:**
1. Check PostgreSQL is running: `pg_isrunning` or `sudo service postgresql status`
2. Verify connection details in `.env` file
3. Check database exists: `psql -U postgres -l`

### Issue: Port Already in Use

**Solution:**
```bash
# For Linux/Mac:
lsof -i :5000  # Find process using port 5000
kill -9 <PID>  # Kill the process

# For Windows:
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### Issue: Socket.io Connection Fails

**Solution:**
1. Ensure backend is running
2. Check CORS configuration in `backend/server.js`
3. Verify frontend `VITE_WEBSOCKET_URL` in `.env`

## 📡 API Documentation

Full API documentation is available at:
- **Swagger UI:** `http://localhost:5000/api/docs`
- **OpenAPI Spec:** `http://localhost:5000/api/openapi.json`

See [API.md](./docs/API.md) for detailed endpoint documentation.

## 🚀 Deployment

### Deployment Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Generate strong JWT secrets
- [ ] Configure production database
- [ ] Set up HTTPS/SSL
- [ ] Configure CORS for production domain
- [ ] Set up logging and monitoring
- [ ] Configure email service for notifications
- [ ] Run database migrations
- [ ] Build frontend: `npm run build`
- [ ] Deploy using PM2, Docker, or your preferred platform

### Docker Deployment

```bash
# Build Docker images
docker-compose build

# Start services
docker-compose up -d

# Check logs
docker-compose logs -f
```

## 📞 Support

For issues and questions:
1. Check existing [GitHub Issues](https://github.com/AymanSaber11/Biocare-Assets/issues)
2. Create a new issue with detailed information
3. Contact: support@biocare-assets.com

## 📝 Additional Resources

- [Backend Documentation](./docs/API.md)
- [Database Documentation](./docs/DATABASE.md)
- [User Guide](./docs/USER_GUIDE.md)
- [Contributing Guidelines](./CONTRIBUTING.md)

---

**Happy coding! 🚀**
