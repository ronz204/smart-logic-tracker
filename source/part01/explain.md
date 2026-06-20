# Explain — P1: Roles, Privilegios y Row Level Security

> Orden de ejecucion: `schemas.sql` -> `seeders.sql` -> `01a.sql` -> `01b.sql` -> `01c.sql` -> `01d.sql`

---

## 1a. Identificación y creación de roles

| Rol | Característica | Justificación para el sistema courier |
|---|---|---|
| `recepcionista` | NOLOGIN, sin CREATE, sin TEMP. Solo SELECT en tablas no sensibles. | Atiende clientes en sucursal y responde "¿dónde está mi paquete?". Necesita consultar `customers`, `packages` y `branches`, pero nunca modifica nada ni necesita ver valores asegurados o datos exactos del destinatario. |
| `repartidor` | NOLOGIN, INSERT/UPDATE en su área. No DROP ni GRANT. | Es quien físicamente recoge y entrega paquetes: registra cada parada en `package_history` y actualiza el estado en `packages`. No necesita ver `customers` (datos de cuenta y pago no son su responsabilidad). |
| `admin_logistics` | NOLOGIN, control total del esquema `logistics`. No SUPERUSER. | Encargado de soporte y mantenimiento de datos: corrige errores, gestiona catálogos (`branches`, `couriers`) y puede insertar/actualizar/borrar en cualquier tabla del esquema. Separarlo de SUPERUSER evita que pueda tocar otros esquemas del servidor o crear roles nuevos — su poder está limitado a `logistics`, no a la instancia completa de PostgreSQL. |

Los usuarios LOGIN (`usr_recepcion_heredia`, `usr_admin_logistics`, `repartidor_marco`, `repartidor_tatiana`) son las cuentas reales que se conectan; los roles de arriba son los "perfiles" que agrupan privilegios. `repartidor_marco` y `repartidor_tatiana` coinciden exactamente con `couriers.db_username` en los seeders, porque ese vínculo es lo que permite que las políticas RLS de 1d funcionen con `CURRENT_USER`.

---

## 1b. Matriz de privilegios

| Rol | Tabla / Objeto | SELECT | INSERT | UPDATE | DELETE | Justificación |
|---|---|---|---|---|---|---|
| `recepcionista` | `customers` | ✔ | ☐ | ☐ | ☐ | Necesita ver datos del cliente para atender consultas, no modificarlos. |
| `recepcionista` | `packages` | ✔ (columnas no sensibles, ver 1c) | ☐ | ☐ | ☐ | Responde sobre el estado del envío sin ver valor asegurado ni contacto exacto del destinatario. |
| `recepcionista` | `branches` | ✔ | ☐ | ☐ | ☐ | Informa en qué sucursal está un paquete o desde cuál sale una ruta. |
| `repartidor` | `package_history` | ✔ | ✔ | ✔ | ☐ | Registra cada movimiento de los paquetes en su propia ruta (ver RLS en 1d). |
| `repartidor` | `packages` | ✔ | ☐ | ✔ | ☐ | Actualiza el estado del paquete (`picked_up`, `delivered`, etc.) a medida que avanza su ruta. |
| `repartidor` | `routes` | ✔ | ☐ | ☐ | ☐ | Consulta los datos de su propia ruta (fecha, turno, sucursal de origen). |
| `admin_logistics` | todas las tablas | ✔ | ✔ | ✔ | ✔ | Mantenimiento y corrección de datos en todo el esquema; es el único rol con DELETE en tablas como `customers` o `packages`. |

El `REVOKE DELETE` explícito sobre `customers` y `packages` para `recepcionista` y `repartidor` es defensivo: aunque nunca se les otorgó DELETE, lo dejamos explícito en el script para que la intención quede documentada y no dependa solo de "nunca se otorgó".

---

## 1c. GRANT a nivel de columna

**Tabla elegida:** `logistics.packages`
**Columnas sensibles identificadas:** `declared_value` (valor asegurado del contenido), `recipient_phone` y `recipient_address` (contacto exacto de entrega).

### ¿Por qué es más preciso que GRANT SELECT en la tabla completa?

Un `GRANT SELECT` a nivel de tabla es una decisión binaria: o `recepcionista` ve toda la fila o no ve nada. Eso obliga a elegir entre dos malas opciones: exponer el valor asegurado y la dirección exacta del destinatario a cualquiera que conteste el teléfono en sucursal, o quitarle a recepcionista la capacidad de confirmar siquiera el estado del envío. El `GRANT SELECT (columnas)` resuelve esto con precisión quirúrgica: recepcionista puede confirmar que el paquete existe, a quién va dirigido por nombre, cuánto pesa y en qué estado está — todo lo que necesita para atender una llamada — sin tener acceso a datos que no le corresponden por su función. Además, este control vive en el catálogo de PostgreSQL (`information_schema.column_privileges`) y se aplica automáticamente sin necesidad de vistas adicionales ni lógica en la aplicación.

---

## 1d. Row Level Security

**Tabla elegida:** `logistics.package_history`
**Justificación del negocio:** cada repartidor solo debería ver y registrar los movimientos de paquetes que van en **su propia ruta**, no el historial completo de la empresa. Un repartidor de Heredia no tiene ninguna razón de negocio para ver las entregas que está haciendo un repartidor en Limón, y permitírselo sería una fuga de información operativa (rutas, direcciones, tiempos de otros repartidores) sin ningún beneficio.

El mecanismo: `couriers.db_username` guarda el nombre de usuario de PostgreSQL de cada repartidor. Las políticas comparan `CURRENT_USER` contra esa columna a través de `package_history.courier_id`, así que cada repartidor solo puede leer (`FOR SELECT`) e insertar (`FOR INSERT ... WITH CHECK`) filas donde el `courier_id` corresponde a su propio usuario.

### ¿Por qué RLS es superior a filtrar en la aplicación en este caso?

Filtrar en la aplicación significa confiar en que **cada** consulta que toque `package_history` —ahora y en el futuro, en cualquier endpoint, reporte o script ad-hoc que alguien escriba— incluya correctamente la cláusula `WHERE courier_id = ...`. Basta que un desarrollador olvide ese filtro en un solo reporte nuevo, o que alguien use el Query Tool directamente para depurar un problema, para que un repartidor termine viendo el historial completo de la empresa. RLS mueve esa regla de negocio a la base de datos misma: no importa qué herramienta, ORM o consulta ad-hoc se use, PostgreSQL aplica el filtro siempre, a nivel de fila, de forma transparente e imposible de "olvidar". El `FORCE ROW LEVEL SECURITY` además asegura que ni siquiera el propietario de la tabla quede exento por accidente.

### Prueba con 2 usuarios

`repartidor_marco` ve únicamente las filas con `courier_id` igual al de Marco Jiménez (4 movimientos en los seeders); `repartidor_tatiana` ve únicamente las suyas (4 movimientos distintos). Ningún usuario ve las filas del otro, aunque ambos están conectados a la misma tabla con el mismo `SELECT * FROM package_history`.