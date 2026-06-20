-- =========================================================
-- 3 perfiles reales del sistema courier:
--   1. recepcionista   -> solo lectura, atiende consultas de clientes
--   2. repartidor      -> operador, INSERT/UPDATE solo en su propia ruta
--   3. admin_logistics -> control total del esquema logistics
-- =========================================================

-- Rol de solo lectura: atiende clientes en sucursal, sin tocar datos
CREATE ROLE recepcionista WITH
  NOLOGIN
  NOCREATEDB
  NOCREATEROLE
  NOSUPERUSER
  NOREPLICATION;

-- Rol operador: repartidor que registra movimientos de SU ruta
CREATE ROLE repartidor WITH
  NOLOGIN
  NOCREATEDB
  NOCREATEROLE
  NOSUPERUSER
  NOREPLICATION;

-- Rol administrador del esquema logistics (no superusuario)
CREATE ROLE admin_logistics WITH
  NOLOGIN
  NOCREATEDB
  NOCREATEROLE
  NOSUPERUSER
  NOREPLICATION;

-- Limitar uso de TEMP en la base de datos para los 3 roles
-- (ninguno necesita crear tablas temporales para su funcion)
REVOKE TEMP ON DATABASE tracker FROM recepcionista, repartidor, admin_logistics;

-- admin_logistics tiene control total de SU esquema (crear/alterar
-- objetos dentro de logistics), pero no es SUPERUSER ni puede
-- tocar otros esquemas ni crear roles nuevos.
GRANT CREATE ON SCHEMA logistics TO admin_logistics;

-- Usuarios LOGIN reales que se conectaran usando estos roles.
-- Cada repartidor del negocio necesita su propio usuario LOGIN
-- para que CURRENT_USER funcione en las politicas RLS (P1d).
CREATE ROLE usr_recepcion_heredia WITH LOGIN PASSWORD 'recepcion123' IN ROLE recepcionista;
CREATE ROLE usr_admin_logistics WITH LOGIN PASSWORD 'admin123' IN ROLE admin_logistics;

CREATE ROLE repartidor_marco WITH LOGIN PASSWORD 'marco123' IN ROLE repartidor;
CREATE ROLE repartidor_tatiana WITH LOGIN PASSWORD 'tatiana123' IN ROLE repartidor;
