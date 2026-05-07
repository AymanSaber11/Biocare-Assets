-- Create Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Drop existing tables if they exist (for development)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS maintenance_history CASCADE;
DROP TABLE IF EXISTS cm_requests CASCADE;
DROP TABLE IF EXISTS pm_schedules CASCADE;
DROP TABLE IF EXISTS assets CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS biomedicals CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create ENUM types
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'technician', 'enduser');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE asset_status AS ENUM ('active', 'inactive', 'under_maintenance', 'decommissioned');
CREATE TYPE asset_criticality AS ENUM ('critical', 'high', 'medium', 'low');
CREATE TYPE pm_frequency AS ENUM ('daily', 'weekly', 'biweekly', 'monthly', 'quarterly', 'semiannual', 'annual', 'custom');
CREATE TYPE pm_status AS ENUM ('scheduled', 'active', 'inactive', 'completed');
CREATE TYPE cm_priority AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE cm_status AS ENUM ('open', 'assigned', 'in_progress', 'on_hold', 'completed', 'closed');
CREATE TYPE maintenance_type AS ENUM ('preventive', 'corrective', 'emergency');
CREATE TYPE notification_type AS ENUM ('maintenance_due', 'request_created', 'request_assigned', 'request_updated', 'equipment_alert', 'schedule_notification');
CREATE TYPE notification_status AS ENUM ('unread', 'read');

-- Users Table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role user_role NOT NULL DEFAULT 'enduser',
  status user_status NOT NULL DEFAULT 'active',
  biomedical_id UUID,
  department_id UUID,
  last_login TIMESTAMP,
  last_activity TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_biomedical_id ON users(biomedical_id);

-- Biomedicals Table
CREATE TABLE biomedicals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL UNIQUE,
  address VARCHAR(500),
  city VARCHAR(100),
  state VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(255),
  website VARCHAR(255),
  license_number VARCHAR(100),
  accreditation VARCHAR(255),
  status user_status DEFAULT 'active',
  logo_url VARCHAR(500),
  settings JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID
);

CREATE INDEX idx_biomedicals_status ON biomedicals(status);
CREATE INDEX idx_biomedicals_city ON biomedicals(city);

-- Departments Table
CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  biomedical_id UUID NOT NULL REFERENCES biomedicals(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  head_id UUID REFERENCES users(id),
  status user_status DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID,
  UNIQUE(biomedical_id, name)
);

CREATE INDEX idx_departments_biomedical_id ON departments(biomedical_id);
CREATE INDEX idx_departments_head_id ON departments(head_id);

-- Assets Table
CREATE TABLE assets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  biomedical_id UUID NOT NULL REFERENCES biomedicals(id) ON DELETE CASCADE,
  department_id UUID REFERENCES departments(id),
  asset_code VARCHAR(100) NOT NULL,
  asset_name VARCHAR(255) NOT NULL,
  description TEXT,
  manufacturer VARCHAR(255),
  model VARCHAR(255),
  serial_number VARCHAR(255),
  asset_type VARCHAR(100),
  purchase_date DATE,
  purchase_cost DECIMAL(12, 2),
  warranty_expiry DATE,
  location VARCHAR(255),
  status asset_status DEFAULT 'active',
  criticality asset_criticality DEFAULT 'medium',
  supplier_name VARCHAR(255),
  supplier_phone VARCHAR(20),
  technical_specs JSONB,
  last_maintenance_date TIMESTAMP,
  next_maintenance_date TIMESTAMP,
  maintenance_interval_days INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID
);

CREATE INDEX idx_assets_biomedical_id ON assets(biomedical_id);
CREATE INDEX idx_assets_department_id ON assets(department_id);
CREATE INDEX idx_assets_status ON assets(status);
CREATE INDEX idx_assets_criticality ON assets(criticality);
CREATE INDEX idx_assets_asset_code ON assets(asset_code);
CREATE INDEX idx_assets_serial_number ON assets(serial_number);
CREATE INDEX idx_assets_manufacturer ON assets USING GIN (manufacturer gin_trgm_ops);
CREATE INDEX idx_assets_model ON assets USING GIN (model gin_trgm_ops);
CREATE INDEX idx_assets_asset_name ON assets USING GIN (asset_name gin_trgm_ops);

-- PM Schedules Table
CREATE TABLE pm_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
  biomedical_id UUID NOT NULL REFERENCES biomedicals(id),
  frequency pm_frequency NOT NULL DEFAULT 'monthly',
  interval_days INTEGER,
  assigned_to UUID REFERENCES users(id),
  scheduled_date DATE NOT NULL,
  last_completed_date TIMESTAMP,
  next_scheduled_date DATE,
  status pm_status DEFAULT 'scheduled',
  estimated_duration_minutes INTEGER,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID
);

CREATE INDEX idx_pm_schedules_asset_id ON pm_schedules(asset_id);
CREATE INDEX idx_pm_schedules_assigned_to ON pm_schedules(assigned_to);
CREATE INDEX idx_pm_schedules_status ON pm_schedules(status);
CREATE INDEX idx_pm_schedules_next_scheduled_date ON pm_schedules(next_scheduled_date);

-- CM Requests Table
CREATE TABLE cm_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
  biomedical_id UUID NOT NULL REFERENCES biomedicals(id),
  request_number VARCHAR(50) UNIQUE NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  priority cm_priority DEFAULT 'medium',
  status cm_status DEFAULT 'open',
  requested_by UUID NOT NULL REFERENCES users(id),
  assigned_to UUID REFERENCES users(id),
  estimated_cost DECIMAL(12, 2),
  actual_cost DECIMAL(12, 2),
  downtime_minutes INTEGER,
  resolution_notes TEXT,
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  assigned_at TIMESTAMP,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cm_requests_asset_id ON cm_requests(asset_id);
CREATE INDEX idx_cm_requests_assigned_to ON cm_requests(assigned_to);
CREATE INDEX idx_cm_requests_status ON cm_requests(status);
CREATE INDEX idx_cm_requests_priority ON cm_requests(priority);
CREATE INDEX idx_cm_requests_requested_by ON cm_requests(requested_by);
CREATE INDEX idx_cm_requests_biomedical_id ON cm_requests(biomedical_id);

-- Maintenance History Table
CREATE TABLE maintenance_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
  biomedical_id UUID NOT NULL REFERENCES biomedicals(id),
  maintenance_type maintenance_type NOT NULL,
  description TEXT,
  technician_id UUID REFERENCES users(id),
  cost DECIMAL(12, 2),
  duration_minutes INTEGER,
  performed_at TIMESTAMP NOT NULL,
  notes TEXT,
  parts_used TEXT,
  spare_parts JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID
);

CREATE INDEX idx_maintenance_history_asset_id ON maintenance_history(asset_id);
CREATE INDEX idx_maintenance_history_technician_id ON maintenance_history(technician_id);
CREATE INDEX idx_maintenance_history_maintenance_type ON maintenance_history(maintenance_type);
CREATE INDEX idx_maintenance_history_performed_at ON maintenance_history(performed_at);

-- Notifications Table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  biomedical_id UUID NOT NULL REFERENCES biomedicals(id),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  notification_type notification_type NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  asset_id UUID REFERENCES assets(id),
  cm_request_id UUID REFERENCES cm_requests(id),
  pm_schedule_id UUID REFERENCES pm_schedules(id),
  status notification_status DEFAULT 'unread',
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_notification_type ON notifications(notification_type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_biomedical_id ON notifications(biomedical_id);

-- Audit Logs Table
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  biomedical_id UUID REFERENCES biomedicals(id),
  user_id UUID REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  resource_type VARCHAR(100) NOT NULL,
  resource_id UUID,
  changes JSONB,
  ip_address INET,
  user_agent VARCHAR(500),
  status VARCHAR(50),
  error_message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_resource_type ON audit_logs(resource_type);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_biomedical_id ON audit_logs(biomedical_id);

-- Add Foreign Key for users.biomedical_id and users.department_id
ALTER TABLE users ADD CONSTRAINT fk_users_biomedical_id
  FOREIGN KEY (biomedical_id) REFERENCES biomedicals(id) ON DELETE SET NULL;

ALTER TABLE users ADD CONSTRAINT fk_users_department_id
  FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL;

-- Create Views
-- Overdue Maintenance View
CREATE VIEW v_overdue_maintenance AS
SELECT 
  ps.id,
  ps.asset_id,
  a.asset_name,
  a.asset_code,
  ps.next_scheduled_date,
  CURRENT_DATE - ps.next_scheduled_date AS days_overdue,
  ps.assigned_to,
  u.first_name || ' ' || u.last_name AS assigned_technician,
  ps.status
FROM pm_schedules ps
JOIN assets a ON ps.asset_id = a.id
LEFT JOIN users u ON ps.assigned_to = u.id
WHERE ps.next_scheduled_date < CURRENT_DATE AND ps.status != 'completed';

-- Asset Status Summary View
CREATE VIEW v_asset_status_summary AS
SELECT 
  b.id AS biomedical_id,
  b.name AS biomedical_name,
  COUNT(*) AS total_assets,
  COUNT(CASE WHEN a.status = 'active' THEN 1 END) AS active_assets,
  COUNT(CASE WHEN a.status = 'inactive' THEN 1 END) AS inactive_assets,
  COUNT(CASE WHEN a.status = 'under_maintenance' THEN 1 END) AS under_maintenance,
  COUNT(CASE WHEN a.status = 'decommissioned' THEN 1 END) AS decommissioned
FROM biomedicals b
LEFT JOIN assets a ON b.id = a.biomedical_id
GROUP BY b.id, b.name;

-- Technician Workload View
CREATE VIEW v_technician_workload AS
SELECT 
  u.id,
  u.first_name || ' ' || u.last_name AS technician_name,
  COUNT(DISTINCT ps.id) AS pending_pm_tasks,
  COUNT(DISTINCT cm.id) AS pending_cm_tasks,
  COUNT(DISTINCT ps.id) + COUNT(DISTINCT cm.id) AS total_tasks
FROM users u
LEFT JOIN pm_schedules ps ON u.id = ps.assigned_to AND ps.status IN ('scheduled', 'active')
LEFT JOIN cm_requests cm ON u.id = cm.assigned_to AND cm.status IN ('open', 'assigned', 'in_progress')
WHERE u.role IN ('technician', 'manager')
GROUP BY u.id, u.first_name, u.last_name;

-- Create Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_biomedicals_updated_at BEFORE UPDATE ON biomedicals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_assets_updated_at BEFORE UPDATE ON assets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pm_schedules_updated_at BEFORE UPDATE ON pm_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cm_requests_updated_at BEFORE UPDATE ON cm_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Commit successful
COMMIT;
