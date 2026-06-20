# Explain — P2: Diccionario de Datos y Diseño

## 2a. Diccionario de datos completo

> Tabla lista para copiar al documento del quiz. Esquema: `logistics`. Todas las PK son `UUID DEFAULT gen_random_uuid()`.

### customers

| Tabla | Columna | Tipo de dato | Constraint(s) | Descripción / Regla de negocio |
|---|---|---|---|---|
| customers | id | UUID | PK, DEFAULT gen_random_uuid() | Identificador único del cliente. |
| customers | full_name | VARCHAR(120) | NOT NULL | Nombre del cliente que envía paquetes. |
| customers | email | VARCHAR(150) | NOT NULL, UNIQUE | Correo de la cuenta; se usa para login y notificaciones. |
| customers | phone | VARCHAR(20) | NOT NULL | Teléfono de contacto del cliente. |
| customers | payment_method | JSONB | NULL | Datos del método de pago guardado (tipo, últimos 4 dígitos, etc.). Dato sensible. |
| customers | registered_at | TIMESTAMP | NOT NULL, DEFAULT now() | Cuándo se creó la cuenta. |
| customers | is_active | BOOLEAN | NOT NULL, DEFAULT true | Si la cuenta está habilitada para crear envíos. |

### couriers

| Tabla | Columna | Tipo de dato | Constraint(s) | Descripción / Regla de negocio |
|---|---|---|---|---|
| couriers | id | UUID | PK, DEFAULT gen_random_uuid() | Identificador único del repartidor. |
| couriers | full_name | VARCHAR(120) | NOT NULL | Nombre del empleado. |
| couriers | national_id | VARCHAR(20) | NOT NULL, UNIQUE | Identificación oficial del empleado. Dato sensible. |
| couriers | phone | VARCHAR(20) | NOT NULL | Contacto del repartidor durante su ruta. |
| couriers | vehicle_type | vehicle_type_enum | NOT NULL | Tipo de vehículo: limita qué tan grandes o pesados pueden ser los paquetes de su ruta. |
| couriers | db_username | VARCHAR(60) | NOT NULL, UNIQUE | Usuario de PostgreSQL asociado; columna que usan las políticas RLS vía `CURRENT_USER`. |
| couriers | is_active | BOOLEAN | NOT NULL, DEFAULT true | Si el repartidor está actualmente trabajando. |

### branches

| Tabla | Columna | Tipo de dato | Constraint(s) | Descripción / Regla de negocio |
|---|---|---|---|---|
| branches | id | UUID | PK, DEFAULT gen_random_uuid() | Identificador único de la sucursal. |
| branches | name | VARCHAR(100) | NOT NULL | Nombre identificador (ej. "Sucursal Heredia Centro"). |
| branches | province | VARCHAR(50) | NOT NULL | Provincia donde está ubicada. |
| branches | address | VARCHAR(200) | NOT NULL | Dirección física exacta. |
| branches | package_capacity | INTEGER | NOT NULL, CHECK (package_capacity > 0) | Cantidad máxima de paquetes que puede almacenar a la vez. |

### routes

| Tabla | Columna | Tipo de dato | Constraint(s) | Descripción / Regla de negocio |
|---|---|---|---|---|
| routes | id | UUID | PK, DEFAULT gen_random_uuid() | Identificador único de la ruta. |
| routes | courier_id | UUID | FK -> couriers(id), NOT NULL, ON DELETE RESTRICT | Repartidor asignado a esta ruta. No se puede borrar un repartidor con rutas activas. |
| routes | origin_branch_id | UUID | FK -> branches(id), NOT NULL, ON DELETE RESTRICT | Sucursal desde donde sale la ruta. |
| routes | route_date | DATE | NOT NULL | Día en que se ejecuta la ruta. |
| routes | shift | shift_enum | NOT NULL | Franja horaria de la ruta. |
| routes | status | route_status_enum | NOT NULL, DEFAULT 'planned' | Estado actual de la ruta completa. |

### packages

| Tabla | Columna | Tipo de dato | Constraint(s) | Descripción / Regla de negocio |
|---|---|---|---|---|
| packages | id | UUID | PK, DEFAULT gen_random_uuid() | Identificador único del paquete. |
| packages | customer_id | UUID | FK -> customers(id), NOT NULL, ON DELETE CASCADE | Cliente que envía el paquete. Si se elimina el cliente, se elimina su historial de envíos. |
| packages | route_id | UUID | FK -> routes(id), NULL, ON DELETE SET NULL | Ruta asignada para transportarlo. Puede quedar sin ruta si aún no se asigna o si la ruta se cancela. |
| packages | recipient_name | VARCHAR(120) | NOT NULL | Nombre de quien recibe el paquete (no tiene cuenta en el sistema). |
| packages | recipient_phone | VARCHAR(20) | NOT NULL | Teléfono de contacto del destinatario. Dato sensible. |
| packages | recipient_address | VARCHAR(200) | NOT NULL | Dirección exacta de entrega. Dato sensible. |
| packages | weight_kg | NUMERIC(6,2) | NOT NULL, CHECK (weight_kg > 0) | Peso del paquete en kilogramos. |
| packages | declared_value | NUMERIC(10,2) | NULL | Valor declarado del contenido para fines de seguro. Dato sensible, base de P1c. |
| packages | status | package_status_enum | NOT NULL, DEFAULT 'pending' | Estado actual del paquete. |
| packages | created_at | TIMESTAMP | NOT NULL, DEFAULT now() | Cuándo se registró el envío. |

### package_history

| Tabla | Columna | Tipo de dato | Constraint(s) | Descripción / Regla de negocio |
|---|---|---|---|---|
| package_history | id | UUID | PK, DEFAULT gen_random_uuid() | Identificador único del registro de historial. |
| package_history | package_id | UUID | FK -> packages(id), NOT NULL, ON DELETE CASCADE | Paquete al que pertenece este movimiento. Si se borra el paquete, se borra su historial. |
| package_history | courier_id | UUID | FK -> couriers(id), NOT NULL, ON DELETE RESTRICT | Repartidor que registró el movimiento; columna que usan las políticas RLS (P1d). |
| package_history | recorded_status | package_status_enum | NOT NULL | Estado del paquete en el momento de este movimiento. |
| package_history | location | JSONB | NOT NULL | Coordenadas y metadatos de la parada: `{"lat", "lng", "approx_address"}`. |
| package_history | recorded_at | TIMESTAMP | NOT NULL, DEFAULT now() | Fecha y hora exacta del movimiento. |

---

## 2b. Justificación de decisiones de diseño

### 2b-i. Justificación de ENUMs

Modelamos cuatro columnas con ENUM: `couriers.vehicle_type` (`vehicle_type_enum`), `routes.shift` (`shift_enum`), `routes.status` (`route_status_enum`) y `packages.status`/`package_history.recorded_status` (ambas reutilizan `package_status_enum`). Elegimos ENUM sobre VARCHAR + CHECK porque en los cuatro casos el conjunto de valores es cerrado, conocido desde el diseño y casi nunca cambia (no vamos a inventar un quinto tipo de vehículo de un día para otro), y un ENUM documenta ese conjunto directamente en el catálogo de PostgreSQL (`Types` en pgAdmin) en lugar de esconderlo dentro de la expresión de un CHECK que hay que abrir para leer. Consideramos usar ENUM para `branches.province`, ya que en teoría también es un conjunto cerrado (las provincias de Costa Rica son siete y no cambian), pero decidimos dejarla como VARCHAR: agregar una sucursal en un país distinto en el futuro implicaría una migración de tipo ENUM (`ALTER TYPE ... ADD VALUE`), mientras que con VARCHAR ese cambio es trivial y sin downtime; al ser un dato puramente descriptivo y no parte de ninguna lógica de negocio (no se usa en ningún CHECK, RLS o transición de estados), el costo de flexibilizarlo es menor que el beneficio de la validación estricta de un ENUM.

### 2b-ii. Justificación de JSONB

Guardamos en `package_history.location` las coordenadas y metadatos de cada parada de un paquete: latitud, longitud y una dirección aproximada (`{"lat": 9.99, "lng": -84.11, "approx_address": "..."}`). Estos datos no encajaban bien en columnas relacionales fijas porque la estructura de cada parada puede variar: a veces hay una dirección aproximada legible, otras veces solo coordenadas GPS crudas, y a futuro podríamos querer agregar un campo de precisión del GPS o una nota del repartidor sin tener que correr una migración de esquema cada vez. Partir esto en columnas separadas (`lat`, `lng`, `approx_address`, `gps_accuracy`, ...) habría obligado a anticipar de entrada todos los metadatos posibles, cuando en realidad el dato natural de una parada es un objeto, no una fila rígida. En las consultas usaremos principalmente el operador `->>` para extraer `lat` y `lng` como texto en reportes y cálculos (por ejemplo, `location->>'lat'`), y ocasionalmente `@>` para preguntas como "¿hay alguna parada cuyo metadata contenga esta clave/valor exacto?". Un índice GIN sobre `location` acelera justamente ese tipo de búsquedas por contención (`@>`), porque indexa internamente las claves y valores del JSON en lugar de obligar a un escaneo secuencial que decodifique cada documento JSONB fila por fila.

### 2b-iii. Justificación de normalización

Tomamos `packages` y `routes` para mostrar 3FN. En `packages`, cada columna no clave depende únicamente de `id` (la PK): `weight_kg`, `declared_value`, `status` y los datos del destinatario solo tienen sentido para *ese* paquete específico, no dependen de `customer_id` ni de `route_id` ni entre sí — no hay, por ejemplo, una dependencia transitiva donde `recipient_address` dependiera de `route_id` y este de `id` (si así fuera, mover un paquete a otra ruta cambiaría su dirección de entrega, lo cual no tiene sentido de negocio). En `routes`, `route_date`, `shift` y `status` dependen solo de `id`, no de `courier_id`: el repartidor no determina la fecha ni el turno, son atributos independientes de la ruta misma. Durante el diseño sí detectamos y corregimos una dependencia parcial: en una primera versión consideramos guardar `courier_name` directamente en `routes` para evitar un JOIN al mostrar reportes, pero eso era una dependencia transitiva real (`courier_name` depende de `courier_id`, que depende de `routes.id`, no directamente de la PK de `routes`), y además duplicaba datos que ya viven en `couriers.full_name` — si un repartidor cambiara su nombre legal, habría que actualizarlo en todas sus rutas históricas. Lo corregimos dejando `routes.courier_id` como la única referencia y resolviendo el nombre vía JOIN cuando se necesita.