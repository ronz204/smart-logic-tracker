-- =========================================================
-- schemas.sql
-- Esquema propio, ENUMs y tablas del dominio courier
-- =========================================================

-- Esquema propio
CREATE SCHEMA IF NOT EXISTS logistics;

SET search_path TO logistics;

-- Extension para gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =========================================================
-- ENUMs
-- =========================================================

-- Tipo de vehiculo del repartidor
CREATE TYPE logistics.vehicle_type_enum AS ENUM (
  'motorcycle',
  'car',
  'pickup',
  'truck'
);

-- Turno de una ruta
CREATE TYPE logistics.shift_enum AS ENUM (
  'morning',
  'afternoon',
  'night'
);

-- Estado de una ruta completa
CREATE TYPE logistics.route_status_enum AS ENUM (
  'planned',
  'in_progress',
  'finished',
  'cancelled'
);

-- Estado de un paquete (reutilizado en packages y package_history)
CREATE TYPE logistics.package_status_enum AS ENUM (
  'pending',
  'picked_up',
  'in_transit',
  'delivered',
  'returned'
);

-- =========================================================
-- Tablas
-- =========================================================

-- Clientes que envian paquetes (tienen cuenta en el sistema)
CREATE TABLE logistics.customers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name       VARCHAR(120) NOT NULL,
  email           VARCHAR(150) NOT NULL UNIQUE,
  phone           VARCHAR(20) NOT NULL,
  payment_method  JSONB,
  registered_at   TIMESTAMP NOT NULL DEFAULT now(),
  is_active       BOOLEAN NOT NULL DEFAULT true
);

-- Empleados fijos que entregan los paquetes
CREATE TABLE logistics.couriers (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name     VARCHAR(120) NOT NULL,
  national_id   VARCHAR(20) NOT NULL UNIQUE,
  phone         VARCHAR(20) NOT NULL,
  vehicle_type  logistics.vehicle_type_enum NOT NULL,
  db_username   VARCHAR(60) NOT NULL UNIQUE,
  is_active     BOOLEAN NOT NULL DEFAULT true
);

-- Puntos fisicos de la empresa (origen/paradas de rutas)
CREATE TABLE logistics.branches (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name              VARCHAR(100) NOT NULL,
  province          VARCHAR(50) NOT NULL,
  address           VARCHAR(200) NOT NULL,
  package_capacity  INTEGER NOT NULL CHECK (package_capacity > 0)
);

-- Recorrido planificado asignado a un repartidor
CREATE TABLE logistics.routes (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  courier_id         UUID NOT NULL REFERENCES logistics.couriers(id) ON DELETE RESTRICT,
  origin_branch_id   UUID NOT NULL REFERENCES logistics.branches(id) ON DELETE RESTRICT,
  route_date         DATE NOT NULL,
  shift              logistics.shift_enum NOT NULL,
  status             logistics.route_status_enum NOT NULL DEFAULT 'planned'
);

-- El envio en si: remitente, destinatario y estado
CREATE TABLE logistics.packages (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id        UUID NOT NULL REFERENCES logistics.customers(id) ON DELETE CASCADE,
  route_id           UUID REFERENCES logistics.routes(id) ON DELETE SET NULL,
  recipient_name     VARCHAR(120) NOT NULL,
  recipient_phone    VARCHAR(20) NOT NULL,
  recipient_address  VARCHAR(200) NOT NULL,
  weight_kg          NUMERIC(6,2) NOT NULL CHECK (weight_kg > 0),
  declared_value     NUMERIC(10,2),
  status             logistics.package_status_enum NOT NULL DEFAULT 'pending',
  created_at         TIMESTAMP NOT NULL DEFAULT now()
);

-- Bitacora de movimientos de cada paquete (candidata para RLS)
CREATE TABLE logistics.package_history (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  package_id       UUID NOT NULL REFERENCES logistics.packages(id) ON DELETE CASCADE,
  courier_id       UUID NOT NULL REFERENCES logistics.couriers(id) ON DELETE RESTRICT,
  recorded_status  logistics.package_status_enum NOT NULL,
  location         JSONB NOT NULL,
  recorded_at      TIMESTAMP NOT NULL DEFAULT now()
);