# Overview — Sistema de Envío de Paquetes (Courier)

## ¿Qué es este sistema?

Una plataforma de logística tipo **courier**: clientes registrados crean **envíos** de paquetes hacia un destinatario (que no necesita cuenta en el sistema). Cada paquete viaja dentro de una **ruta** asignada a un **repartidor**, pasando por una o varias **sucursales** antes de llegar a destino. El sistema registra el **historial de movimientos** de cada paquete (recolectado, en tránsito, entregado, etc.) con fecha y ubicación.

## Por qué este dominio funciona para el quiz

| Necesidad del quiz | Cómo la cubre este dominio |
|---|---|
| ≥ 5 000 filas realistas | Los `packages` y su `package_history` crecen fácil con `generate_series()` (miles de envíos diarios es realista). |
| Roles claros (lectura / operador / admin) | Recepcionista (lectura), repartidor (operador, solo su ruta), admin del sistema. |
| Columna sensible para GRANT por columna | `declared_value` y datos de pago en `packages` / `customers`. |
| RLS con sentido de negocio | Un repartidor solo debe ver los paquetes de **su** ruta asignada, no los de toda la empresa. |
| JSONB con uso real | El recorrido de un paquete (lat/lng + timestamp en cada parada) no encaja bien en columnas fijas. |
| ENUM con sentido | Estados del paquete (`pending`, `in_transit`, `delivered`, etc.) tienen un conjunto cerrado y conocido de valores. |

## Las 6 tablas del modelo

1. **customers** — quién envía los paquetes (tiene cuenta en el sistema).
2. **couriers** — empleados que entregan los paquetes.
3. **branches** — puntos físicos de la empresa (origen, paradas, destino).
4. **routes** — un recorrido planificado, asignado a un repartidor, para una fecha/turno.
5. **packages** — el envío en sí: remitente, destinatario, contenido, estado actual, ruta asignada.
6. **package_history** — bitácora de movimientos de cada paquete (incluye el JSONB de coordenadas).

## Decisiones de diseño ya tomadas

- **Repartidores son empleados fijos**, no freelance. Simplifica el modelo (no hay pagos por entrega, contratos, etc.) y calza directo con el rol "operador" del quiz: un repartidor hace `INSERT`/`UPDATE` sobre el historial de **sus** paquetes asignados.
- **El destinatario NO es una tabla aparte.** Es solo un conjunto de columnas dentro de `packages` (nombre, teléfono, dirección de entrega). No tiene cuenta ni login. Esto evita sobre-modelar algo que en la realidad de un courier es solo "datos de contacto para la entrega", y de paso nos da columnas sensibles naturales (teléfono, dirección) para la pregunta de GRANT por columna.
- **El remitente SÍ es un cliente registrado** en la tabla `customers`, porque es quien tiene cuenta, historial de envíos y método de pago.

## Cómo se conectan las tablas (vista rápida)

```
customers ──┐
            │ (envía)
            ▼
       packages ──────► routes ──────► couriers
            │               │
            │               └──────► branches (origen/destino de la ruta)
            ▼
   package_history (JSONB con coordenadas + timestamp)
```

## Próximos documentos

- `database.md` → diccionario de datos completo: cada tabla, cada columna, tipo, constraints y descripción de negocio. Es la base directa para el DDL real en PostgreSQL y para la sección 2a del quiz.