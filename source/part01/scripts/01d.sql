-- =========================================================
-- Tabla elegida: logistics.package_history
-- Cada repartidor solo ve y registra movimientos de paquetes
-- que van en SU ruta, no el historial completo de la empresa.
-- =========================================================

SET search_path TO logistics;

ALTER TABLE logistics.package_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE logistics.package_history FORCE ROW LEVEL SECURITY;

-- Politica de lectura: un repartidor ve solo sus propios movimientos.
-- admin_logistics no tiene politica propia, pero FORCE RLS tambien
-- lo limita salvo que sea owner de la tabla; por eso el owner sigue
-- siendo quien crea la tabla (admin del esquema a nivel de servidor).
CREATE POLICY package_history_select_own
  ON logistics.package_history
  FOR SELECT
  TO repartidor
  USING (
    courier_id = (
      SELECT id FROM logistics.couriers
      WHERE db_username = CURRENT_USER
    )
  );

-- Politica de escritura: un repartidor solo puede insertar
-- movimientos marcados con su propio courier_id.
CREATE POLICY package_history_insert_own
  ON logistics.package_history
  FOR INSERT
  TO repartidor
  WITH CHECK (
    courier_id = (
      SELECT id FROM logistics.couriers
      WHERE db_username = CURRENT_USER
    )
  );

-- recepcionista y admin_logistics no usan estas politicas porque
-- no tienen privilegios GRANT sobre package_history (01b);
-- FORCE RLS solo aplica a quienes ya tienen permiso de acceso.

-- ---------------------------------------------------------
-- Prueba con 2 usuarios distintos (ejecutar en 2 Query Tools)
-- ---------------------------------------------------------

-- Query Tool 1, conectado como repartidor_marco:
SET ROLE repartidor_marco;
SELECT * FROM logistics.package_history;
RESET ROLE;

-- Query Tool 2, conectado como repartidor_tatiana:
SET ROLE repartidor_tatiana;
SELECT * FROM logistics.package_history;
RESET ROLE;

-- Cada SELECT debe devolver unicamente las filas cuyo courier_id
-- corresponde al db_username del usuario activo.