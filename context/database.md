# Database — Diccionario de Datos

> Esquema propuesto: `courier` (no usar `public`, según condición #1 del quiz).
> Todas las PK son `UUID DEFAULT gen_random_uuid()`.

---

## 1. customers

Quiénes envían paquetes. Son los usuarios con cuenta en el sistema (no confundir con el destinatario, que solo son datos de contacto dentro de `packages`).

| Columna | Tipo | Constraints | Descripción / regla de negocio |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador único del cliente. |
| `full_name` | VARCHAR(120) | NOT NULL | Nombre del cliente que envía paquetes. |
| `email` | VARCHAR(150) | NOT NULL, UNIQUE | Correo de la cuenta; se usa para login y notificaciones. |
| `phone` | VARCHAR(20) | NOT NULL | Teléfono de contacto del cliente. |
| `payment_method` | JSONB | NULL | Datos del método de pago guardado (tipo, últimos 4 dígitos, etc.). **Dato sensible** — candidato a quedar fuera del GRANT por columna del rol de solo lectura. |
| `registered_at` | TIMESTAMP | NOT NULL, DEFAULT now() | Cuándo se creó la cuenta. |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true | Si la cuenta está habilitada para crear envíos. |

---

## 2. couriers

Empleados fijos de la empresa que recogen y entregan los paquetes asignados a sus rutas.

| Columna | Tipo | Constraints | Descripción / regla de negocio |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador único del repartidor. |
| `full_name` | VARCHAR(120) | NOT NULL | Nombre del empleado. |
| `national_id` | VARCHAR(20) | NOT NULL, UNIQUE | Identificación oficial del empleado. **Dato sensible.** |
| `phone` | VARCHAR(20) | NOT NULL | Contacto del repartidor durante su ruta. |
| `vehicle_type` | vehicle_type_enum | NOT NULL | Tipo de vehículo que usa: limita qué tan grandes o pesados pueden ser los paquetes de su ruta. |
| `db_username` | VARCHAR(60) | NOT NULL, UNIQUE | Nombre de usuario de PostgreSQL asociado a este repartidor; es la columna que usan las políticas RLS para filtrar "sus" paquetes (vía `CURRENT_USER`). |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true | Si el repartidor está actualmente trabajando. |

**ENUM `vehicle_type_enum`:** `'motorcycle'`, `'car'`, `'pickup'`, `'truck'`.
*Por qué ENUM y no VARCHAR + CHECK:* el conjunto de vehículos es fijo, conocido de antemano y casi no cambia — un ENUM lo deja explícito en el catálogo de tipos y PostgreSQL lo valida sin necesidad de mantener una expresión CHECK aparte.

---

## 3. branches

Puntos físicos de la empresa: bodegas, centros de distribución o puntos de entrega.

| Columna | Tipo | Constraints | Descripción / regla de negocio |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador único de la sucursal. |
| `name` | VARCHAR(100) | NOT NULL | Nombre identificador (ej. "Sucursal Heredia Centro"). |
| `province` | VARCHAR(50) | NOT NULL | Provincia donde está ubicada (contexto Costa Rica). |
| `address` | VARCHAR(200) | NOT NULL | Dirección física exacta. |
| `package_capacity` | INTEGER | NOT NULL, CHECK (package_capacity > 0) | Cantidad máxima de paquetes que puede almacenar a la vez. **Constraint CHECK de regla de negocio.** |

---

## 4. routes

Un recorrido planificado: un repartidor, una fecha/turno, y una sucursal de origen.

| Columna | Tipo | Constraints | Descripción / regla de negocio |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador único de la ruta. |
| `courier_id` | UUID | FK → couriers(id), NOT NULL, ON DELETE RESTRICT | Repartidor asignado a esta ruta. No se puede borrar un repartidor con rutas activas. |
| `origin_branch_id` | UUID | FK → branches(id), NOT NULL, ON DELETE RESTRICT | Sucursal desde donde sale la ruta. |
| `route_date` | DATE | NOT NULL | Día en que se ejecuta la ruta. |
| `shift` | shift_enum | NOT NULL | Franja horaria de la ruta. |
| `status` | route_status_enum | NOT NULL, DEFAULT 'planned' | Estado actual de la ruta completa. |

**ENUM `shift_enum`:** `'morning'`, `'afternoon'`, `'night'`.
**ENUM `route_status_enum`:** `'planned'`, `'in_progress'`, `'finished'`, `'cancelled'`.

---

## 5. packages

El envío en sí. Conecta al cliente que lo manda, los datos del destinatario (sin cuenta propia), y la ruta que lo transporta.

| Columna | Tipo | Constraints | Descripción / regla de negocio |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador único del paquete. |
| `customer_id` | UUID | FK → customers(id), NOT NULL, ON DELETE CASCADE | Cliente que envía el paquete. Si se elimina el cliente, se elimina su historial de envíos. |
| `route_id` | UUID | FK → routes(id), NULL, ON DELETE SET NULL | Ruta asignada para transportarlo. Puede quedar sin ruta (NULL) si aún no se asigna o si la ruta se cancela. |
| `recipient_name` | VARCHAR(120) | NOT NULL | Nombre de quien recibe el paquete (no tiene cuenta en el sistema). |
| `recipient_phone` | VARCHAR(20) | NOT NULL | Teléfono de contacto del destinatario. **Dato sensible.** |
| `recipient_address` | VARCHAR(200) | NOT NULL | Dirección exacta de entrega. **Dato sensible.** |
| `weight_kg` | NUMERIC(6,2) | NOT NULL, CHECK (weight_kg > 0) | Peso del paquete en kilogramos. **Constraint CHECK de regla de negocio.** |
| `declared_value` | NUMERIC(10,2) | NULL | Valor declarado del contenido para fines de seguro. **Dato sensible** — es el ejemplo principal para la pregunta de GRANT por columna (P1c). |
| `status` | package_status_enum | NOT NULL, DEFAULT 'pending' | Estado actual del paquete. |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT now() | Cuándo se registró el envío. |

**ENUM `package_status_enum`:** `'pending'`, `'picked_up'`, `'in_transit'`, `'delivered'`, `'returned'`.
*Por qué ENUM y no VARCHAR + CHECK:* el ciclo de vida del paquete es un conjunto cerrado y ordenado de estados; un ENUM además documenta ese flujo directamente en el catálogo de PostgreSQL.

*Por qué `declared_value` y los datos del destinatario son la base de la pregunta 1c:* un recepcionista (rol solo lectura) necesita ver casi toda la fila de `packages` para atender consultas de clientes, pero no tiene por qué ver el valor asegurado del contenido ni el teléfono/dirección exacta del destinatario — son datos que solo necesita el repartidor en ruta.

---

## 6. package_history

Bitácora de movimientos de cada paquete. Es la tabla candidata natural para **RLS** (P1d): un repartidor solo debería poder insertar/ver movimientos de paquetes que van en su ruta actual.

| Columna | Tipo | Constraints | Descripción / regla de negocio |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador único del registro de historial. |
| `package_id` | UUID | FK → packages(id), NOT NULL, ON DELETE CASCADE | Paquete al que pertenece este movimiento. Si se borra el paquete, se borra su historial. |
| `courier_id` | UUID | FK → couriers(id), NOT NULL, ON DELETE RESTRICT | Repartidor que registró el movimiento; es la columna que usan las políticas RLS (`CURRENT_USER` se compara contra `couriers.db_username` vía este FK). |
| `recorded_status` | package_status_enum | NOT NULL | Estado del paquete en el momento de este movimiento (reutiliza el mismo ENUM de `packages`). |
| `location` | JSONB | NOT NULL | Coordenadas y metadatos de la parada: `{"lat": 9.99, "lng": -84.11, "approx_address": "..."}`. |
| `recorded_at` | TIMESTAMP | NOT NULL, DEFAULT now() | Fecha y hora exacta del movimiento. |

*Por qué JSONB y no columnas relacionales normales:* cada parada tiene una estructura variable de metadatos (coordenadas, precisión del GPS, nota del repartidor) que no vale la pena partir en columnas fijas — el dato natural es un objeto, no una fila relacional. Se consultará principalmente con el operador `->>` para extraer `lat`/`lng` en reportes, y un índice **GIN** sobre la columna acelera búsquedas como "todas las paradas dentro de cierta zona" usando `@>`.

*Por qué esta tabla y no `packages` para el RLS:* `packages` puede necesitar verse por varios roles a la vez (recepción, admin), pero `package_history` es donde un repartidor *escribe* activamente — tiene sentido de negocio real que cada repartidor solo vea y registre movimientos de paquetes en su propia ruta, no el historial completo de la empresa.

---

## Resumen de relaciones (FKs)

| Tabla origen | Columna FK | Tabla destino | ON DELETE |
|---|---|---|---|
| `routes` | `courier_id` | `couriers` | RESTRICT |
| `routes` | `origin_branch_id` | `branches` | RESTRICT |
| `packages` | `customer_id` | `customers` | CASCADE |
| `packages` | `route_id` | `routes` | SET NULL |
| `package_history` | `package_id` | `packages` | CASCADE |
| `package_history` | `courier_id` | `couriers` | RESTRICT |

Cumple la condición de "≥ 3 FK con ON DELETE explícito" usando los 3 tipos disponibles (RESTRICT, CASCADE, SET NULL), lo que da variedad real para justificar cada decisión.