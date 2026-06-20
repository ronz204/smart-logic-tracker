-- =========================================================
-- Tabla elegida: logistics.packages
-- Columnas sensibles: declared_value, recipient_phone, recipient_address
-- (valor asegurado y contacto exacto del destinatario)
-- =========================================================

SET search_path TO logistics;

-- Primero quitamos el SELECT amplio que dimos en 01b sobre toda
-- la tabla packages para recepcionista, y lo reemplazamos por
-- SELECT solo en las columnas no sensibles.
REVOKE SELECT ON logistics.packages FROM recepcionista;

GRANT SELECT (
  id,
  customer_id,
  route_id,
  recipient_name,
  weight_kg,
  status,
  created_at
) ON logistics.packages TO recepcionista;

-- declared_value, recipient_phone y recipient_address quedan
-- fuera del GRANT: recepcionista no las puede leer.