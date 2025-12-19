-- 001_init.sql
-- Speedy core schema (MVP)

BEGIN;

-- Extensions (safe to run multiple times)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Salons (multi-tenant foundation; even if you run one salon now)
CREATE TABLE IF NOT EXISTS salons (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  phone text,
  email text,
  address text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Users (customers + staff via role)
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  salon_id uuid REFERENCES salons(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('customer', 'staff', 'admin')),
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text UNIQUE,
  phone text,
  password_hash text, -- optional for now; can be null until auth is implemented
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_salon_id ON users(salon_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Services (e.g., manicure, pedicure, lashes)
CREATE TABLE IF NOT EXISTS services (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  salon_id uuid REFERENCES salons(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  duration_minutes integer NOT NULL CHECK (duration_minutes > 0),
  price_cents integer NOT NULL CHECK (price_cents >= 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_services_salon_id ON services(salon_id);

-- Staff profile (ties staff user to capabilities)
CREATE TABLE IF NOT EXISTS staff (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  salon_id uuid REFERENCES salons(id) ON DELETE CASCADE,
  user_id uuid UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  bio text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_staff_salon_id ON staff(salon_id);

-- Staff -> Services mapping (who can do what)
CREATE TABLE IF NOT EXISTS staff_services (
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  service_id uuid REFERENCES services(id) ON DELETE CASCADE,
  PRIMARY KEY (staff_id, service_id)
);

-- Weekly availability (simple MVP model)
-- day_of_week: 0=Sunday ... 6=Saturday
CREATE TABLE IF NOT EXISTS staff_availability (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  day_of_week integer NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time time NOT NULL,
  end_time time NOT NULL,
  CHECK (end_time > start_time)
);

CREATE INDEX IF NOT EXISTS idx_staff_avail_staff_id ON staff_availability(staff_id);

-- Appointments
CREATE TABLE IF NOT EXISTS appointments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  salon_id uuid REFERENCES salons(id) ON DELETE CASCADE,
  customer_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  staff_id uuid REFERENCES staff(id) ON DELETE SET NULL,
  service_id uuid REFERENCES services(id) ON DELETE SET NULL,

  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  status text NOT NULL CHECK (status IN ('booked', 'cancelled', 'completed', 'no_show')),
  notes text,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CHECK (end_at > start_at)
);

CREATE INDEX IF NOT EXISTS idx_appt_salon_start ON appointments(salon_id, start_at);
CREATE INDEX IF NOT EXISTS idx_appt_staff_start ON appointments(staff_id, start_at);
CREATE INDEX IF NOT EXISTS idx_appt_customer_start ON appointments(customer_user_id, start_at);

COMMIT;
-- End of 001_init.sql