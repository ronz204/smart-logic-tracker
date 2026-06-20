-- =========================================================
-- Matriz rol x tabla (resumen, ver tabla completa en el docx):
--   recepcionista    | customers      | SELECT
--   recepcionista    | packages       | SELECT
--   recepcionista    | branches       | SELECT
--   repartidor       | package_history| SELECT, INSERT, UPDATE
--   repartidor       | packages       | SELECT, UPDATE
--   repartidor       | routes         | SELECT
--   admin_logistics  | (todas)        | SELECT, INSERT, UPDATE, DELETE
-- =========================================================

SET search_path TO logistics;

-- Uso base del esquema: sin esto ningun rol puede ver las tablas
GRANT USAGE ON SCHEMA logistics TO recepcionista, repartidor, admin_logistics;

-- ---------------------------------------------------------
-- recepcionista: solo lectura en tablas no sensibles
-- Atiende consultas de clientes sobre estado de envios.
-- ---------------------------------------------------------
GRANT SELECT ON logistics.customers TO recepcionista;
GRANT SELECT ON logistics.packages TO recepcionista;
GRANT SELECT ON logistics.branches TO recepcionista;

-- ---------------------------------------------------------
-- repartidor: operador, INSERT/UPDATE en su area de trabajo
-- Registra movimientos de paquetes y actualiza su estado.
-- No puede ver ni tocar customers (datos de cuenta/pago).
-- ---------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON logistics.package_history TO repartidor;
GRANT SELECT, UPDATE ON logistics.packages TO repartidor;
GRANT SELECT ON logistics.routes TO repartidor;
GRANT SELECT ON logistics.branches TO repartidor;

-- ---------------------------------------------------------
-- admin_logistics: control total del esquema propio
-- Mantenimiento de catalogos, soporte y correccion de datos.
-- ---------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA logistics TO admin_logistics;

-- ---------------------------------------------------------
-- REVOKE explicito: ningun rol de negocio puede borrar clientes
-- ni paquetes directamente, eso queda solo para admin_logistics.
-- ---------------------------------------------------------
REVOKE DELETE ON logistics.customers FROM recepcionista, repartidor;
REVOKE DELETE ON logistics.packages FROM recepcionista, repartidor;