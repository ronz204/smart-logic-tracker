-- =========================================================
-- seeders.sql
-- Datos de prueba: 10-15 filas por tabla.
-- Se usan UUIDs fijos para poder referenciar filas entre
-- tablas sin depender del orden de insercion.
-- El volumen masivo (5000+ filas) se genera aparte en P4.
-- =========================================================

SET search_path TO logistics;

-- =========================================================
-- customers (12 filas)
-- =========================================================
INSERT INTO logistics.customers (id, full_name, email, phone, payment_method, is_active) VALUES
  ('c0000000-0000-0000-0000-000000000001', 'Ana Vargas Soto',      'ana.vargas@example.com',      '8801-1111', '{"type": "card", "last4": "4242"}', true),
  ('c0000000-0000-0000-0000-000000000002', 'Luis Mora Jimenez',    'luis.mora@example.com',       '8801-2222', '{"type": "sinpe", "phone": "8801-2222"}', true),
  ('c0000000-0000-0000-0000-000000000003', 'Carla Rojas Quesada',  'carla.rojas@example.com',     '8801-3333', '{"type": "card", "last4": "1881"}', true),
  ('c0000000-0000-0000-0000-000000000004', 'Diego Fernandez Leon', 'diego.fernandez@example.com', '8801-4444', NULL, true),
  ('c0000000-0000-0000-0000-000000000005', 'Maria Castro Brenes',  'maria.castro@example.com',    '8801-5555', '{"type": "card", "last4": "5577"}', true),
  ('c0000000-0000-0000-0000-000000000006', 'Jose Solano Araya',    'jose.solano@example.com',     '8801-6666', '{"type": "sinpe", "phone": "8801-6666"}', true),
  ('c0000000-0000-0000-0000-000000000007', 'Paula Chacon Vega',    'paula.chacon@example.com',    '8801-7777', NULL, true),
  ('c0000000-0000-0000-0000-000000000008', 'Andres Ramirez Cruz',  'andres.ramirez@example.com',  '8801-8888', '{"type": "card", "last4": "9012"}', true),
  ('c0000000-0000-0000-0000-000000000009', 'Sofia Salazar Mata',   'sofia.salazar@example.com',   '8801-9999', '{"type": "card", "last4": "3344"}', false),
  ('c0000000-0000-0000-0000-000000000010', 'Kevin Gomez Alvarado', 'kevin.gomez@example.com',     '8802-1010', NULL, true),
  ('c0000000-0000-0000-0000-000000000011', 'Laura Mendez Pineda',  'laura.mendez@example.com',    '8802-2020', '{"type": "sinpe", "phone": "8802-2020"}', true),
  ('c0000000-0000-0000-0000-000000000012', 'Esteban Nunez Porras', 'esteban.nunez@example.com',   '8802-3030', '{"type": "card", "last4": "6655"}', true);

-- =========================================================
-- couriers (10 filas)
-- db_username es el puente con las politicas RLS (CURRENT_USER)
-- =========================================================
INSERT INTO logistics.couriers (id, full_name, national_id, phone, vehicle_type, db_username, is_active) VALUES
  ('d0000000-0000-0000-0000-000000000001', 'Marco Jimenez Solis',   '1-1111-1111', '8701-0001', 'motorcycle', 'repartidor_marco',   true),
  ('d0000000-0000-0000-0000-000000000002', 'Tatiana Vindas Rojas',  '2-2222-2222', '8701-0002', 'car',        'repartidor_tatiana', true),
  ('d0000000-0000-0000-0000-000000000003', 'Rodrigo Salas Umana',   '3-3333-3333', '8701-0003', 'motorcycle', 'repartidor_rodrigo', true),
  ('d0000000-0000-0000-0000-000000000004', 'Vanessa Picado Leon',   '4-4444-4444', '8701-0004', 'pickup',     'repartidor_vanessa', true),
  ('d0000000-0000-0000-0000-000000000005', 'Felipe Aguilar Mora',   '5-5555-5555', '8701-0005', 'truck',      'repartidor_felipe',  true),
  ('d0000000-0000-0000-0000-000000000006', 'Daniela Soto Quiros',   '6-6666-6666', '8701-0006', 'car',        'repartidor_daniela', true),
  ('d0000000-0000-0000-0000-000000000007', 'Gustavo Brenes Castro', '7-7777-7777', '8701-0007', 'motorcycle', 'repartidor_gustavo', true),
  ('d0000000-0000-0000-0000-000000000008', 'Ivannia Rojas Mata',    '8-8888-8888', '8701-0008', 'car',        'repartidor_ivannia', false),
  ('d0000000-0000-0000-0000-000000000009', 'Sebastian Vega Cruz',   '9-9999-9999', '8701-0009', 'pickup',     'repartidor_sebas',   true),
  ('d0000000-0000-0000-0000-000000000010', 'Natalia Alfaro Diaz',   '1-0101-0101', '8701-0010', 'motorcycle', 'repartidor_natalia', true);

-- =========================================================
-- branches (10 filas)
-- =========================================================
INSERT INTO logistics.branches (id, name, province, address, package_capacity) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'Sucursal Heredia Centro',      'Heredia',    'Av. 2, Heredia centro, 100m sur del parque', 500),
  ('b0000000-0000-0000-0000-000000000002', 'Sucursal San Jose Centro',     'San Jose',   'Calle 5, San Jose centro, frente a Correos', 800),
  ('b0000000-0000-0000-0000-000000000003', 'Sucursal Alajuela Centro',     'Alajuela',   'Av. 1, Alajuela centro, contiguo al mercado', 450),
  ('b0000000-0000-0000-0000-000000000004', 'Sucursal Cartago Centro',      'Cartago',    'Calle 3, Cartago centro, costado de la Basilica', 400),
  ('b0000000-0000-0000-0000-000000000005', 'Sucursal Heredia Mercedes',    'Heredia',    'Mercedes Norte, 200m oeste del parque', 300),
  ('b0000000-0000-0000-0000-000000000006', 'Sucursal San Jose Pavas',      'San Jose',   'Pavas, frente a la Municipalidad', 350),
  ('b0000000-0000-0000-0000-000000000007', 'Sucursal Alajuela San Rafael', 'Alajuela',   'San Rafael de Alajuela, 50m norte de la iglesia', 250),
  ('b0000000-0000-0000-0000-000000000008', 'Sucursal Puntarenas Centro',   'Puntarenas', 'Paseo de los Turistas, Puntarenas centro', 400),
  ('b0000000-0000-0000-0000-000000000009', 'Sucursal Guanacaste Liberia',  'Guanacaste', 'Liberia centro, frente al hospital', 300),
  ('b0000000-0000-0000-0000-000000000010', 'Sucursal Limon Centro',        'Limon',      'Limon centro, costado del muelle', 350);

-- =========================================================
-- routes (15 filas)
-- =========================================================
INSERT INTO logistics.routes (id, courier_id, origin_branch_id, route_date, shift, status) VALUES
  ('e0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', '2026-06-10', 'morning',   'finished'),
  ('e0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', '2026-06-10', 'afternoon', 'finished'),
  ('e0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000001', '2026-06-11', 'morning',   'finished'),
  ('e0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000003', '2026-06-11', 'night',     'finished'),
  ('e0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', '2026-06-12', 'morning',   'finished'),
  ('e0000000-0000-0000-0000-000000000006', 'd0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000004', '2026-06-12', 'afternoon', 'in_progress'),
  ('e0000000-0000-0000-0000-000000000007', 'd0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', '2026-06-13', 'morning',   'in_progress'),
  ('e0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000005', '2026-06-13', 'afternoon', 'planned'),
  ('e0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000001', '2026-06-14', 'morning',   'planned'),
  ('e0000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000007', 'b0000000-0000-0000-0000-000000000006', '2026-06-14', 'night',     'planned'),
  ('e0000000-0000-0000-0000-000000000011', 'd0000000-0000-0000-0000-000000000009', 'b0000000-0000-0000-0000-000000000009', '2026-06-15', 'morning',   'planned'),
  ('e0000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000010', 'b0000000-0000-0000-0000-000000000001', '2026-06-15', 'afternoon', 'planned'),
  ('e0000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000003', '2026-06-16', 'morning',   'planned'),
  ('e0000000-0000-0000-0000-000000000014', 'd0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', '2026-06-09', 'morning',   'cancelled'),
  ('e0000000-0000-0000-0000-000000000015', 'd0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000004', '2026-06-09', 'night',     'finished');

-- =========================================================
-- packages (15 filas)
-- Repartidas entre varias rutas/repartidores para poder
-- demostrar RLS: marco y tatiana quedan con paquetes propios.
-- =========================================================
INSERT INTO logistics.packages (
  id, customer_id, route_id, recipient_name, recipient_phone, recipient_address,
  weight_kg, declared_value, status
) VALUES
  ('f0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'Sebastian Loaiza',  '8901-0001', 'Heredia, Mercedes Sur, casa 12',         2.50,  45000.00, 'delivered'),
  ('f0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'Karla Ugalde',      '8901-0002', 'Heredia, Ulloa, 100m norte del EBAIS',   1.20,    NULL,    'delivered'),
  ('f0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 'Ronald Espinoza',   '8901-0003', 'San Jose, Sabana Sur, edificio Lex',     5.00, 120000.00, 'delivered'),
  ('f0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000003', 'Gabriela Solis',    '8901-0004', 'Heredia, San Francisco, calle 8',        0.80,  15000.00, 'delivered'),
  ('f0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000004', 'Pablo Quesada',     '8901-0005', 'Alajuela, La Garita, frente a la plaza', 3.30,    NULL,    'delivered'),
  ('f0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000005', 'Melissa Arce',      '8901-0006', 'Heredia centro, avenida 4',               1.00,  20000.00, 'delivered'),
  ('f0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000007', 'e0000000-0000-0000-0000-000000000006', 'Jorge Calderon',    '8901-0007', 'Cartago, Tres Rios, 50m sur del banco',  4.50,    NULL,    'in_transit'),
  ('f0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000008', 'e0000000-0000-0000-0000-000000000007', 'Yolanda Perez',     '8901-0008', 'San Jose, Pavas, residencial Las Vegas', 2.00,  60000.00, 'in_transit'),
  ('f0000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000009', 'e0000000-0000-0000-0000-000000000008', 'Mauricio Fonseca',  '8901-0009', 'Heredia, San Pablo, calle principal',    0.60,    NULL,    'picked_up'),
  ('f0000000-0000-0000-0000-000000000010', 'c0000000-0000-0000-0000-000000000010', 'e0000000-0000-0000-0000-000000000009', 'Adriana Barrantes', '8901-0010', 'Heredia centro, 200m oeste del parque',  1.80,  30000.00, 'pending'),
  ('f0000000-0000-0000-0000-000000000011', 'c0000000-0000-0000-0000-000000000011', 'e0000000-0000-0000-0000-000000000010', 'Ricardo Murillo',   '8901-0011', 'San Jose, Pavas, frente al super',       2.20,    NULL,    'pending'),
  ('f0000000-0000-0000-0000-000000000012', 'c0000000-0000-0000-0000-000000000012', NULL,                                   'Vanessa Hidalgo',   '8901-0012', 'Limon centro, calle 2',                  6.00,  85000.00, 'pending'),
  ('f0000000-0000-0000-0000-000000000013', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000011', 'Daniel Castillo',   '8901-0013', 'Guanacaste, Liberia, barrio El Carmen',  3.00,    NULL,    'pending'),
  ('f0000000-0000-0000-0000-000000000014', 'c0000000-0000-0000-0000-000000000002', NULL,                                   'Fabiola Rojas',     '8901-0014', 'Puntarenas centro, calle 3',              1.50,  25000.00, 'pending'),
  ('f0000000-0000-0000-0000-000000000015', 'c0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000012', 'Esteban Salazar',   '8901-0015', 'Heredia, Mercedes Norte, casa 5',         2.80,    NULL,    'pending');

-- =========================================================
-- package_history (15 filas)
-- courier_id corresponde al repartidor de la ruta del paquete,
-- para que las politicas RLS de P1d tengan datos reales que filtrar.
-- =========================================================
INSERT INTO logistics.package_history (package_id, courier_id, recorded_status, location) VALUES
  ('f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'picked_up',  '{"lat": 9.9990, "lng": -84.1167, "approx_address": "Heredia centro"}'),
  ('f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'delivered',  '{"lat": 9.9933, "lng": -84.1180, "approx_address": "Mercedes Sur"}'),
  ('f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'delivered',  '{"lat": 9.9912, "lng": -84.1090, "approx_address": "Ulloa"}'),
  ('f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000002', 'picked_up',  '{"lat": 9.9355, "lng": -84.1004, "approx_address": "Sabana Sur"}'),
  ('f0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000002', 'delivered',  '{"lat": 9.9356, "lng": -84.1010, "approx_address": "Sabana Sur, edificio Lex"}'),
  ('f0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000003', 'delivered',  '{"lat": 10.0021, "lng": -84.1233, "approx_address": "San Francisco de Heredia"}'),
  ('f0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000004', 'delivered',  '{"lat": 10.0301, "lng": -84.2660, "approx_address": "La Garita"}'),
  ('f0000000-0000-0000-0000-000000000006', 'd0000000-0000-0000-0000-000000000001', 'delivered',  '{"lat": 9.9988, "lng": -84.1170, "approx_address": "Heredia centro"}'),
  ('f0000000-0000-0000-0000-000000000007', 'd0000000-0000-0000-0000-000000000005', 'picked_up',  '{"lat": 9.9075, "lng": -83.9667, "approx_address": "Tres Rios"}'),
  ('f0000000-0000-0000-0000-000000000007', 'd0000000-0000-0000-0000-000000000005', 'in_transit', '{"lat": 9.9100, "lng": -83.9700, "approx_address": "Tres Rios, ruta a Cartago"}'),
  ('f0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000002', 'picked_up',  '{"lat": 9.9395, "lng": -84.1390, "approx_address": "Pavas"}'),
  ('f0000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000002', 'in_transit', '{"lat": 9.9400, "lng": -84.1400, "approx_address": "Pavas, residencial Las Vegas"}'),
  ('f0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000006', 'picked_up',  '{"lat": 10.0150, "lng": -84.1100, "approx_address": "San Pablo de Heredia"}'),
  ('f0000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000003', 'pending',    '{"lat": 9.9988, "lng": -84.1170, "approx_address": "Heredia centro, en bodega"}'),
  ('f0000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000009', 'pending',    '{"lat": 10.6346, "lng": -85.4378, "approx_address": "Liberia, en bodega"}');