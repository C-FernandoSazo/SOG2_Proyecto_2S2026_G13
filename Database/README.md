# Modelo de Datos QuetzalMart — Explicación de Tablas

Documento de apoyo para el `modelo_quetzalmart.sql`. Describe qué representa cada tabla y por qué existe dentro del modelo.

[Diagrama Entidad Relacion](./Esquema%20ER.pdf)

---

## Entidades principales

**`cliente`**
Representa a las personas o empresas que compran en QuetzalMart. Existe porque el ERP necesita identificar a quién se le vende, y porque el RPA debe cargar automáticamente esta información desde los Excel del departamento de ventas.

**`proveedor`**
Representa a las empresas que abastecen a QuetzalMart de productos o materiales. Necesaria para registrar compras, cotizaciones y documentos como contratos de outsourcing.

**`producto`**
Catálogo de artículos que maneja la empresa, ya sean productos de venta al cliente o materiales internos de operación (la columna `tipo_producto` distingue entre ambos). Es la tabla central que conecta ventas, compras, cotizaciones e inventario.

---

## Operación en sucursales

**`sucursal`**
Representa cada punto físico de QuetzalMart (incluyendo las nuevas de México y El Salvador). Permite que ventas, compras, inventario y empleados se asocien a una ubicación concreta.

**`inventario`**
Registra cuánta existencia de cada producto/material hay en cada sucursal. Existe porque el stock no es global sino por tienda, y la empresa necesita saber qué tiene disponible en cada una.

---

## Transacciones comerciales

**`cotizacion`** / **`detalle_cotizacion`**
Registran ofertas de precio hechas antes de concretar una venta o compra. `cotizacion` guarda el encabezado (a quién y cuándo), y `detalle_cotizacion` los productos incluidos. Se separaron en dos tablas porque una cotización puede tener varios productos (relación uno a muchos).

**`venta`** / **`detalle_venta`**
Registran las ventas realizadas a clientes. Igual que las cotizaciones, se dividen en encabezado y detalle porque una venta incluye múltiples productos. La columna `canal` distingue si la venta se originó en sucursal o en el portal web.

**`compra`** / **`detalle_compra`**
Registran las compras hechas a proveedores, con la misma lógica de encabezado/detalle que las ventas.

**`factura`**
Representa el comprobante fiscal generado, ya sea de una venta o de una compra (nunca ambas a la vez). Se separó de `venta`/`compra` porque una factura es un documento formal con su propio número y PDF, mientras que la venta/compra es el registro operativo de la transacción.

---

## Recursos humanos

**`departamento`**
Cataloga las áreas de trabajo de la empresa (mínimo 5 según el enunciado). Existe para poder agrupar y filtrar empleados por área.

**`cargo`**
Cataloga los puestos que puede tener un empleado (mínimo 6). Se separó de `empleado` para no repetir el nombre del puesto en cada registro y mantener consistencia.

**`empleado`**
Registra al personal de la empresa (mínimo 35), vinculado a un departamento, un cargo y opcionalmente una sucursal. Es un requisito explícito y evaluable del proyecto.

---

## Gestión documental

**`documento`**
Representa cualquier archivo cargado al sistema (facturas de proveedor, contratos de outsourcing, contratos de empleados). Guarda la ruta del archivo y a qué proveedor o empleado pertenece.

**`etiqueta`** / **`documento_etiqueta`**
`etiqueta` cataloga las palabras clave disponibles para clasificar documentos. `documento_etiqueta` es una tabla puente porque un documento puede tener varias etiquetas y una etiqueta puede aplicar a varios documentos (relación muchos a muchos).

---

## Marketing

**`envio_marketing`**
Deja evidencia de los correos que el CRM envía a un cliente después de una compra: el de confirmación de compra y el de campaña publicitaria. Existe porque el enunciado pide que ambos correos sean verificables y estén diferenciados por asunto.