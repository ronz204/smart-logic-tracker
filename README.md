# 📦 Smart Logic Tracker

¡Hola! Este proyecto es un sistema de seguimiento de paquetes para una empresa de mensajería. Usa **PostgreSQL** con Docker.

## 🚀 Levantar el proyecto en 5 pasos

### 1️⃣ Requisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows)
- [Beekeeper Studio](https://www.beekeeperstudio.io/) o cualquier cliente SQL
- Git (opcional)

### 2️⃣ Iniciar la base de datos
```bash
docker-compose up -d
```
Esto levanta PostgreSQL en el puerto `5432`

### 3️⃣ Conectarse con Beekeeper
| Campo           | Valor                    |
|-----------------|--------------------------|
| Host            | `localhost`              |
| Puerto          | `5432`                   |
| Usuario         | `tracker`                |
| Contraseña      | `p4ssw0rd`               |
| Base de datos   | `tracker`                |

### 4️⃣ Ejecutar los scripts en este orden
Abre cada archivo en Beekeeper y ejecutalo:

| Orden | Archivo       | ¿Qué hace?                         |
|-------|---------------|-------------------------------------|
| 1️⃣    | `schemas.sql` | Crea tablas, tipos y esquemas      |
| 2️⃣    | `seeders.sql` | Carga datos de prueba (15 filas)   |
| 3️⃣    | `01a.sql`     | Crea los 3 roles del sistema       |
| 4️⃣    | `01b.sql`     | Asigna permisos básicos            |
| 5️⃣    | `01c.sql`     | Protege columnas sensibles         |
| 6️⃣    | `01d.sql`     | Activa RLS para repartidores       |

### 5️⃣ Probar que todo funciona
Ejecuta esta consulta para ver los paquetes:
```sql
SET search_path TO logistics;
SELECT * FROM packages;
```

## 🔑 Usuarios de prueba
| Usuario            | Contraseña   | Rol             |
|--------------------|--------------|-----------------|
| `usr_recepcion_heredia` | `recepcion123` | Recepcionista |
| `usr_admin_logistics`   | `admin123`     | Admin          |
| `repartidor_marco`      | `marco123`     | Repartidor     |
| `repartidor_tatiana`    | `tatiana123`   | Repartidor     |

### Ejemplo: probar RLS con repartidor
```sql
-- Conectate como repartidor_marco
SET ROLE repartidor_marco;
SELECT * FROM logistics.package_history;  -- Solo ve SUS movimientos
RESET ROLE;
```

## 🛑 Detener el proyecto
```bash
docker-compose down
```

## ❓ Preguntas frecuentes

**¿No conecta Beekeeper?**
- Verifica que Docker esté corriendo
- Ejecuta `docker ps` para ver si el contenedor está activo

**¿Error de permisos en los scripts?**
- Asegurate de ejecutarlos en el orden indicado
- Si falla algún script, ejecuta `schemas.sql` de nuevo
