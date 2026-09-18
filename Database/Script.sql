CREATE SCHEMA IF NOT EXISTS modelo_quetzalmart;

CREATE TABLE cliente (
    id_cliente          SERIAL PRIMARY KEY,
    nombre              VARCHAR(150) NOT NULL,      -- Name
    tipo_compania       VARCHAR(100),                -- Company Type
    compania_relacionada VARCHAR(150),               -- Related Company
    email               VARCHAR(150),                -- Email
    telefono            VARCHAR(30),                 -- Phone
    direccion           VARCHAR(200),                -- Street
    direccion_2         VARCHAR(200),                -- Street2 (linea adicional: apto, referencia, etc.)
    ciudad              VARCHAR(100),                -- City
    estado              VARCHAR(100),                -- State
    codigo_postal       VARCHAR(20),                 -- Zip
    pais                VARCHAR(100),                -- Country
    nit                 VARCHAR(50),                 -- Tax ID
    sitio_web           VARCHAR(200),                -- Website
    etiquetas           VARCHAR(300),                -- Tags (lista separada por comas)
    referencia          VARCHAR(100),                -- Reference
    notas               TEXT,                        -- Notes
    fecha_creacion      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- PROVEEDORES

CREATE TABLE proveedor (
    id_proveedor    SERIAL PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    email           VARCHAR(150),
    telefono        VARCHAR(30),
    direccion       VARCHAR(200),
    ciudad          VARCHAR(100),
    pais            VARCHAR(100),
    nit             VARCHAR(50),
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- PRODUCTOS / MATERIALES

CREATE TABLE producto (
    id_producto         SERIAL PRIMARY KEY,
    id_externo          VARCHAR(100),                -- ID Externo (id de origen en el Excel)
    nombre              VARCHAR(150) NOT NULL,        -- Name
    tipo_producto       VARCHAR(50) NOT NULL,         -- Product Type: 'VENTA' | 'MATERIAL'
    referencia_interna  VARCHAR(100),                 -- Internal Reference: SKU propio de la empresa
    codigo_barras       VARCHAR(100),                 -- Barcode: codigo EAN/UPC para escaneo
    precio_venta        NUMERIC(12,2) NOT NULL DEFAULT 0,  -- Sales Price
    costo               NUMERIC(12,2) NOT NULL DEFAULT 0,  -- Cost
    peso                NUMERIC(10,3),                -- Weight
    descripcion_venta   TEXT,                         -- Sales Description
    valores_producto    TEXT,                         -- Product Values
    publicado           BOOLEAN NOT NULL DEFAULT FALSE, -- Esta publicado
    fecha_creacion      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_producto_codigo_barras
        UNIQUE (codigo_barras),

    CONSTRAINT chk_producto_precio
        CHECK (precio_venta >= 0),

    CONSTRAINT chk_producto_costo
        CHECK (costo >= 0),

    CONSTRAINT chk_producto_tipo
        CHECK (tipo_producto IN ('VENTA', 'MATERIAL'))
);


-- SUCURSALES

CREATE TABLE sucursal (
    id_sucursal     SERIAL PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    pais            VARCHAR(100) NOT NULL,
    ciudad          VARCHAR(100),
    direccion       VARCHAR(200),
    activa          BOOLEAN NOT NULL DEFAULT TRUE
);


-- INVENTARIO POR SUCURSAL

CREATE TABLE inventario (
    id_inventario   SERIAL PRIMARY KEY,
    id_sucursal     INTEGER NOT NULL,
    id_producto     INTEGER NOT NULL,
    cantidad        NUMERIC(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_inventario_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal),

    CONSTRAINT fk_inventario_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto),

    CONSTRAINT uq_inventario_sucursal_producto
        UNIQUE (id_sucursal, id_producto),

    CONSTRAINT chk_inventario_cantidad
        CHECK (cantidad >= 0)
);


-- COTIZACIONES

CREATE TABLE cotizacion (
    id_cotizacion   SERIAL PRIMARY KEY,
    id_cliente      INTEGER,
    id_proveedor    INTEGER,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          VARCHAR(50) NOT NULL DEFAULT 'BORRADOR',
    total           NUMERIC(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_cotizacion_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT fk_cotizacion_proveedor
        FOREIGN KEY (id_proveedor)
        REFERENCES proveedor(id_proveedor),

    CONSTRAINT chk_cotizacion_total
        CHECK (total >= 0),

    CONSTRAINT chk_cotizacion_origen
        CHECK (
            (id_cliente IS NOT NULL AND id_proveedor IS NULL)
            OR
            (id_cliente IS NULL AND id_proveedor IS NOT NULL)
        )
);


CREATE TABLE detalle_cotizacion (
    id_detalle          SERIAL PRIMARY KEY,
    id_cotizacion       INTEGER NOT NULL,
    id_producto         INTEGER NOT NULL,
    cantidad            NUMERIC(12,2) NOT NULL,
    precio_unitario     NUMERIC(12,2) NOT NULL,
    subtotal            NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_detalle_cotizacion
        FOREIGN KEY (id_cotizacion)
        REFERENCES cotizacion(id_cotizacion)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_cotizacion_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto),

    CONSTRAINT chk_detalle_cotizacion_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT chk_detalle_cotizacion_precio
        CHECK (precio_unitario >= 0),

    CONSTRAINT chk_detalle_cotizacion_subtotal
        CHECK (subtotal >= 0)
);


-- VENTAS

CREATE TABLE venta (
    id_venta        SERIAL PRIMARY KEY,
    id_cliente      INTEGER NOT NULL,
    id_sucursal     INTEGER,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          VARCHAR(50) NOT NULL DEFAULT 'PENDIENTE',
    canal           VARCHAR(20) NOT NULL DEFAULT 'SUCURSAL',
    total           NUMERIC(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_venta_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT fk_venta_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal),

    CONSTRAINT chk_venta_total
        CHECK (total >= 0),

    CONSTRAINT chk_venta_canal
        CHECK (canal IN ('SUCURSAL', 'WEB'))
);


CREATE TABLE detalle_venta (
    id_detalle          SERIAL PRIMARY KEY,
    id_venta            INTEGER NOT NULL,
    id_producto         INTEGER NOT NULL,
    cantidad            NUMERIC(12,2) NOT NULL,
    precio_unitario     NUMERIC(12,2) NOT NULL,
    subtotal            NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_detalle_venta
        FOREIGN KEY (id_venta)
        REFERENCES venta(id_venta)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_venta_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto),

    CONSTRAINT chk_detalle_venta_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT chk_detalle_venta_precio
        CHECK (precio_unitario >= 0),

    CONSTRAINT chk_detalle_venta_subtotal
        CHECK (subtotal >= 0)
);

-- COMPRAS

CREATE TABLE compra (
    id_compra       SERIAL PRIMARY KEY,
    id_proveedor    INTEGER NOT NULL,
    id_sucursal     INTEGER,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          VARCHAR(50) NOT NULL DEFAULT 'PENDIENTE',
    total           NUMERIC(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_compra_proveedor
        FOREIGN KEY (id_proveedor)
        REFERENCES proveedor(id_proveedor),

    CONSTRAINT fk_compra_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal),

    CONSTRAINT chk_compra_total
        CHECK (total >= 0)
);


CREATE TABLE detalle_compra (
    id_detalle      SERIAL PRIMARY KEY,
    id_compra       INTEGER NOT NULL,
    id_producto     INTEGER NOT NULL,
    cantidad        NUMERIC(12,2) NOT NULL,
    costo_unitario  NUMERIC(12,2) NOT NULL,
    subtotal        NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_detalle_compra
        FOREIGN KEY (id_compra)
        REFERENCES compra(id_compra)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_compra_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto),

    CONSTRAINT chk_detalle_compra_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT chk_detalle_compra_costo
        CHECK (costo_unitario >= 0),

    CONSTRAINT chk_detalle_compra_subtotal
        CHECK (subtotal >= 0)
);

-- FACTURAS

CREATE TABLE factura (
    id_factura      SERIAL PRIMARY KEY,
    id_venta        INTEGER,
    id_compra       INTEGER,
    numero_factura  VARCHAR(100) NOT NULL,
    fecha           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total           NUMERIC(12,2) NOT NULL,
    archivo_pdf     VARCHAR(500),

    CONSTRAINT uq_factura_numero
        UNIQUE (numero_factura),

    CONSTRAINT fk_factura_venta
        FOREIGN KEY (id_venta)
        REFERENCES venta(id_venta),

    CONSTRAINT fk_factura_compra
        FOREIGN KEY (id_compra)
        REFERENCES compra(id_compra),

    CONSTRAINT chk_factura_total
        CHECK (total >= 0),

    CONSTRAINT chk_factura_origen
        CHECK (
            (id_venta IS NOT NULL AND id_compra IS NULL)
            OR
            (id_venta IS NULL AND id_compra IS NOT NULL)
        )
);


-- DEPARTAMENTOS

CREATE TABLE departamento (
    id_departamento SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     TEXT
);

-- CARGOS

CREATE TABLE cargo (
    id_cargo        SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     TEXT
);


-- EMPLEADOS

CREATE TABLE empleado (
    id_empleado         SERIAL PRIMARY KEY,
    id_departamento     INTEGER NOT NULL,
    id_cargo            INTEGER NOT NULL,
    id_sucursal         INTEGER,
    nombre              VARCHAR(150) NOT NULL,
    apellido            VARCHAR(150),
    email               VARCHAR(150),
    telefono            VARCHAR(30),
    fecha_contratacion  DATE,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_empleado_departamento
        FOREIGN KEY (id_departamento)
        REFERENCES departamento(id_departamento),

    CONSTRAINT fk_empleado_cargo
        FOREIGN KEY (id_cargo)
        REFERENCES cargo(id_cargo),

    CONSTRAINT fk_empleado_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal)
);


-- ============================================================
-- GESTION DOCUMENTAL

CREATE TABLE documento (
    id_documento        SERIAL PRIMARY KEY,
    nombre              VARCHAR(200) NOT NULL,
    tipo_documento      VARCHAR(100) NOT NULL,
    categoria           VARCHAR(100),
    ruta_archivo        VARCHAR(500),
    fecha_carga         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    id_proveedor        INTEGER,
    id_empleado         INTEGER,

    CONSTRAINT fk_documento_proveedor
        FOREIGN KEY (id_proveedor)
        REFERENCES proveedor(id_proveedor),

    CONSTRAINT fk_documento_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES empleado(id_empleado)
);

-- ETIQUETAS DE DOCUMENTOS

CREATE TABLE etiqueta (
    id_etiqueta     SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE documento_etiqueta (
    id_documento    INTEGER NOT NULL,
    id_etiqueta     INTEGER NOT NULL,

    PRIMARY KEY (id_documento, id_etiqueta),

    CONSTRAINT fk_documento_etiqueta_documento
        FOREIGN KEY (id_documento)
        REFERENCES documento(id_documento)
        ON DELETE CASCADE,

    CONSTRAINT fk_documento_etiqueta_etiqueta
        FOREIGN KEY (id_etiqueta)
        REFERENCES etiqueta(id_etiqueta)
        ON DELETE CASCADE
);


-- MARKETING / ENVIO DE CORREOS

CREATE TABLE envio_marketing (
    id_envio        SERIAL PRIMARY KEY,
    id_cliente      INTEGER NOT NULL,
    id_venta        INTEGER,
    tipo_envio      VARCHAR(20) NOT NULL,   -- 'COMPRA' | 'CAMPANIA'
    asunto          VARCHAR(200) NOT NULL,
    cuerpo          TEXT,
    fecha_envio     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_envio_marketing_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT fk_envio_marketing_venta
        FOREIGN KEY (id_venta)
        REFERENCES venta(id_venta),

    CONSTRAINT chk_envio_marketing_tipo
        CHECK (tipo_envio IN ('COMPRA', 'CAMPANIA'))
);


-- INDICES

CREATE INDEX idx_cotizacion_cliente
    ON cotizacion(id_cliente);

CREATE INDEX idx_cotizacion_proveedor
    ON cotizacion(id_proveedor);

CREATE INDEX idx_venta_cliente
    ON venta(id_cliente);

CREATE INDEX idx_venta_sucursal
    ON venta(id_sucursal);

CREATE INDEX idx_compra_proveedor
    ON compra(id_proveedor);

CREATE INDEX idx_inventario_producto
    ON inventario(id_producto);

CREATE INDEX idx_empleado_departamento
    ON empleado(id_departamento);

CREATE INDEX idx_empleado_cargo
    ON empleado(id_cargo);

CREATE INDEX idx_producto_tipo
    ON producto(tipo_producto);

CREATE INDEX idx_envio_marketing_cliente
    ON envio_marketing(id_cliente);