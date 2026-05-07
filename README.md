# Biocare-Assets: Biomedical CMMS

A comprehensive **Computerized Maintenance Management System (CMMS)** designed specifically for biomedical equipment management in healthcare facilities.

## 🎯 Key Features

### 1. **Asset Inventory Management**
- Complete equipment tracking with manufacturer, model, and serial number
- Department and location assignment
- Asset status monitoring (Active, Inactive, Under Maintenance, Decommissioned)
- Advanced search and filtering capabilities
- Equipment specification storage

### 2. **Preventive Maintenance (PPM) Scheduling**
- Automated PM schedule generation
- Multiple frequency options (Daily, Weekly, Monthly, Quarterly, Semi-annual, Annual, Custom)
- Maintenance history tracking
- Schedule status management
- Calendar view integration

### 3. **Corrective Maintenance (CM) Requests**
- End-user friendly interface for creating maintenance requests
- Priority levels (Low, Medium, High, Critical)
- Status tracking (Open, In Progress, On Hold, Completed, Closed)
- Technician assignment
- Attachment support for issue documentation
- Notes and comments system

### 4. **Real-time Notifications**
- In-app notification system using Socket.io
- Multi-user notification delivery
- Notification categories (Maintenance Due, Request Created, Request Assigned, etc.)
- Read/unread status tracking
- Notification history

### 5. **Advanced Search & Filtering**
- Search by manufacturer, model, serial number
- Filter by department, location, asset status
- Database indexes for optimal performance
- Bulk export capabilities

### 6. **Multi-User & Multi-Facility Support**
- Role-based access control (Admin, Manager, Technician, End-User)
- User management per biomedical facility
- Department-level permissions
- Audit logging for compliance
- User activity tracking

## 📊 Technology Stack

| Component | Technology |
|-----------|-----------|
| **Backend** | Node.js + Express.js |
| **Frontend** | React.js |
| **Database** | PostgreSQL |
| **Real-time Communication** | Socket.io |
| **Authentication** | JWT + bcrypt |
| **API Documentation** | Swagger/OpenAPI |
| **Security** | Helmet, CORS, Rate Limiting |

## 🗄️ Database Schema

### Core Tables:
- **users** - User accounts with authentication
- **biomedicals** - Healthcare facility information
- **departments** - Department/unit organization
- **assets** - Equipment inventory
- **pm_schedules** - Preventive maintenance schedules
- **cm_requests** - Corrective maintenance requests
- **maintenance_history** - Complete audit trail
- **notifications** - Real-time notification system
- **audit_logs** - User activity tracking

## 📁 Project Structure

```
Biocare-Assets/
├── backend/
│   ├── config/
│   │   ├── index.js
│   │   ├── database.js
│   │   └── environment.js
│   ├── database/
│   │   └── schema.sql
│   ├── models/
│   │   ├── User.js
│   │   ├── Asset.js
│   │   ├── PMSchedule.js
│   │   ├── CMRequest.js
│   │   └── Notification.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── assets.js
│   │   ├── maintenance.js
│   │   ├── notifications.js
│   │   └── admin.js
│   ├── middleware/
│   │   ├── auth.js
│   │   ├── errorHandler.js
│   │   └── validation.js
│   ├── controllers/
│   │   ├── assetController.js
│   │   ├── maintenanceController.js
│   │   ├── notificationController.js
│   │   └── authController.js
│   ├── server.js
│   ├── package.json
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── hooks/
│   │   ├── context/
│   │   └── App.jsx
│   ├── package.json
│   └── vite.config.js
├── docs/
│   ├── API.md
│   ├── DATABASE.md
│   ├── SETUP.md
│   └── USER_GUIDE.md
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- Node.js >= 14.0
- PostgreSQL >= 12
- npm or yarn

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/AymanSaber11/Biocare-Assets.git
cd Biocare-Assets
```

2. **Backend Setup**
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration
npm run migrate  # Initialize database
npm start
```

3. **Frontend Setup**
```bash
cd frontend
npm install
npm run dev
```

4. **Access the Application**
- Frontend: http://localhost:5173
- Backend API: http://localhost:5000
- API Documentation: http://localhost:5000/api/docs

## 🔐 Authentication & Authorization

### User Roles:
- **Admin** - Full system access, user management
- **Manager** - Facility/department management, report generation
- **Technician** - Maintenance task execution, request management
- **End-User** - Create CM requests, view equipment status

### Security Features:
- JWT-based authentication
- bcrypt password hashing
- CORS protection
- Rate limiting
- SQL injection prevention
- Input validation

## 📋 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `POST /api/auth/refresh` - Refresh JWT token

### Assets
- `GET /api/assets` - List all assets
- `POST /api/assets` - Create new asset
- `GET /api/assets/:id` - Get asset details
- `PUT /api/assets/:id` - Update asset
- `DELETE /api/assets/:id` - Delete asset
- `GET /api/assets/search` - Advanced search

### Maintenance
- `GET /api/maintenance/pm-schedules` - List PM schedules
- `POST /api/maintenance/pm-schedules` - Create PM schedule
- `GET /api/maintenance/cm-requests` - List CM requests
- `POST /api/maintenance/cm-requests` - Create CM request
- `PUT /api/maintenance/cm-requests/:id` - Update CM request
- `GET /api/maintenance/history/:assetId` - Get maintenance history

### Notifications
- `GET /api/notifications` - Get user notifications
- `POST /api/notifications/:id/read` - Mark as read
- `DELETE /api/notifications/:id` - Delete notification

## 🔄 Real-time Features

### Socket.io Events:
- `maintenance:scheduled` - New PM schedule created
- `maintenance:due` - Maintenance due reminder
- `request:created` - New CM request created
- `request:assigned` - Request assigned to technician
- `request:updated` - Request status updated
- `equipment:alert` - Equipment alert notification

## 📊 Reporting & Analytics

- Maintenance cost analysis
- Equipment downtime tracking
- Technician performance metrics
- PM compliance rates
- Asset utilization reports
- Preventive vs. corrective maintenance ratio

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
npm test

# E2E tests
npm run test:e2e
```

## 📚 Documentation

- [API Documentation](./docs/API.md)
- [Database Schema](./docs/DATABASE.md)
- [Setup Guide](./docs/SETUP.md)
- [User Guide](./docs/USER_GUIDE.md)

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m 'Add new feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Support

For support, email: support@biocare-assets.com
Or open an issue on GitHub: https://github.com/AymanSaber11/Biocare-Assets/issues

## 🎓 Learn More

- [Express.js Documentation](https://expressjs.com/)
- [React Documentation](https://react.dev/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Socket.io Documentation](https://socket.io/docs/)

---

**Made with ❤️ for healthcare professionals**
