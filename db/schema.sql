-- New Valerita - Esquema inicial para ubicación de productos en bodega

CREATE TABLE IF NOT EXISTS productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku TEXT NOT NULL UNIQUE,
    codigo_barra TEXT UNIQUE,
    marca TEXT NOT NULL,
    nombre TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ubicaciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rack TEXT NOT NULL,
    contenedor TEXT NOT NULL,
    zona TEXT,
    activo INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (rack, contenedor)
);

CREATE TABLE IF NOT EXISTS inventario_ubicacion (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    producto_id INTEGER NOT NULL,
    ubicacion_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
    activo INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id),
    UNIQUE (producto_id, ubicacion_id)
);

CREATE TABLE IF NOT EXISTS movimientos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo TEXT NOT NULL CHECK (tipo IN ('entrada', 'salida', 'movimiento')),
    producto_id INTEGER NOT NULL,
    ubicacion_origen_id INTEGER,
    ubicacion_destino_id INTEGER,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    usuario TEXT,
    observacion TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (ubicacion_origen_id) REFERENCES ubicaciones(id),
    FOREIGN KEY (ubicacion_destino_id) REFERENCES ubicaciones(id)
);

CREATE INDEX IF NOT EXISTS idx_productos_sku ON productos(sku);
CREATE INDEX IF NOT EXISTS idx_productos_codigo_barra ON productos(codigo_barra);
CREATE INDEX IF NOT EXISTS idx_productos_marca ON productos(marca);
CREATE INDEX IF NOT EXISTS idx_ubicaciones_contenedor ON ubicaciones(contenedor);
CREATE INDEX IF NOT EXISTS idx_inventario_producto ON inventario_ubicacion(producto_id);
CREATE INDEX IF NOT EXISTS idx_inventario_ubicacion ON inventario_ubicacion(ubicacion_id);
