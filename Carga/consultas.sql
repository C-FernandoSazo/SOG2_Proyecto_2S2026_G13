
-- Empleados 35
SELECT COUNT(*) FROM public.hr_employee WHERE active = true;

-- Departamentos 5
SELECT COUNT(*) FROM public.hr_department;

-- Cargos 6
SELECT COUNT(*) FROM public.hr_job;

-- Materiales MAS DE 60 MATERIALES
SELECT COUNT(*) FROM public.product_template pt
JOIN public.product_category pc ON pt.categ_id = pc.id WHERE pc.name = 'Materiales';

-- PRODUCTOS
SELECT COUNT(*) FROM public.product_template pt
JOIN public.product_category pc ON pt.categ_id = pc.id WHERE pc.name = 'Productos';


-- Cotizaciones 20 - SUMA LOS PRESUPUESTO A LOS CLIENETS Y VENDEDORES
SELECT (SELECT COUNT(*) FROM public.sale_order WHERE state IN ('draft','sent')) + (SELECT COUNT(*) FROM public.purchase_order WHERE state IN ('draft','sent')) AS total_cotizaciones;


-- VENTAS MAS DE 150 - VENTAS CONFIRMADAS
SELECT COUNT(*) FROM public.sale_order WHERE state IN ('sale','done');


-- Compras MAS DE 100
SELECT COUNT(*) FROM public.purchase_order WHERE state IN ('purchase','done');


-- Facturas MAS DE 50
SELECT COUNT(*) FROM public.account_move
WHERE move_type IN ('out_invoice','in_invoice') AND state = 'posted';



-- ************************************************

-- COTIZACIONES

SELECT
  (SELECT COUNT(*) FROM public.sale_order WHERE state IN ('draft','sent')) +
  (SELECT COUNT(*) FROM public.purchase_order WHERE state IN ('draft','sent'))
  AS total_cotizaciones;
SELECT 'CLIENTE' AS tipo, so.id, so.name, rp.name AS contacto, so.amount_total, so.date_order FROM public.sale_order so
JOIN public.res_partner rp ON so.partner_id = rp.id WHERE so.state IN ('draft','sent')
UNION ALL
SELECT 'PROVEEDOR' AS tipo, po.id, po.name, rp.name AS contacto, po.amount_total, po.date_order
FROM public.purchase_order po JOIN public.res_partner rp ON po.partner_id = rp.id WHERE po.state IN ('draft','sent') ORDER BY id LIMIT 15;


-- VENTRAS
SELECT COUNT(*) FROM public.sale_order WHERE state IN ('sale','done');

SELECT so.id, so.name, rp.name AS cliente, so.amount_total, so.date_order, so.state FROM public.sale_order so
JOIN public.res_partner rp ON so.partner_id = rp.id WHERE so.state IN ('sale','done') ORDER BY so.id LIMIT 50;


-- COMPRAS
SELECT po.id, po.name, rp.name AS proveedor, po.amount_total, po.date_order, po.state FROM public.purchase_order po
JOIN public.res_partner rp ON po.partner_id = rp.id WHERE po.state IN ('purchase','done') ORDER BY po.id LIMIT 20;


-- factura
SELECT COUNT(*) FROM public.account_move
WHERE move_type IN ('out_invoice','in_invoice') AND state = 'posted';

SELECT am.id, am.name, rp.name AS contacto, am.move_type, am.amount_total, am.invoice_date FROM public.account_move am
JOIN public.res_partner rp ON am.partner_id = rp.id
WHERE am.move_type IN ('out_invoice','in_invoice') AND am.state = 'posted' ORDER BY am.id LIMIT 10;


-- ***********************************************************

-- lista los EMPLEASOS
SELECT COUNT(*) FROM public.hr_employee WHERE active = true;

SELECT e.id, e.name, e.work_email, e.work_phone, d.name AS departamento, j.name AS puesto FROM public.hr_employee e
LEFT JOIN public.hr_department d ON e.department_id = d.id
LEFT JOIN public.hr_job j ON e.job_id = j.id WHERE e.active = true ORDER BY e.id LIMIT 50;

-- LISTA LOS DEPARTAMENTOS

SELECT id, name FROM public.hr_department ORDER BY id;

-- LISTA LOS CARGOS

SELECT id, name FROM public.hr_job ORDER BY id LIMIT 10;

-- LISTA LOS MATERIALES
SELECT pt.id, pt.name, pt.default_code AS referencia, pt.list_price AS precio_venta
FROM public.product_template pt
JOIN public.product_category pc ON pt.categ_id = pc.id WHERE pc.name = 'Materiales' ORDER BY pt.id LIMIT 60;


-- LISTAR LOS PRODUCTOS

SELECT pt.id, pt.name, pt.default_code AS referencia, pt.list_price AS precio_venta,  pt.active AS activo
FROM public.product_template pt
JOIN public.product_category pc ON pt.categ_id = pc.id
WHERE pc.name = 'Productos'
ORDER BY pt.id
LIMIT 15;


-- CLIENTE
SELECT COUNT(*) FROM public.res_partner rp JOIN public.res_partner_res_partner_category_rel rel ON rp.id = rel.partner_id
JOIN public.res_partner_category cat ON rel.category_id = cat.id
WHERE cat.name::text ILIKE '%Cliente%';

SELECT rp.id, rp.name, rp.email, rp.phone, rp.city
FROM public.res_partner rp
JOIN public.res_partner_res_partner_category_rel rel ON rp.id = rel.partner_id
JOIN public.res_partner_category cat ON rel.category_id = cat.id WHERE cat.name::text ILIKE '%Cliente%' ORDER BY rp.id LIMIT 50;


-- PROVEEDOR
SELECT COUNT(*) FROM public.res_partner rp
JOIN public.res_partner_res_partner_category_rel rel ON rp.id = rel.partner_id
JOIN public.res_partner_category cat ON rel.category_id = cat.id WHERE cat.name::text ILIKE '%Proveedor%';