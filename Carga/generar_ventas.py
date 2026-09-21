
import random
import xmlrpc.client

# DATA REAL - LA URL DEL ODOO
URL = "LALALALAL"
DB = "quetzalmart"
USUARIO = "USUARIO ODOO"
PASSWORD = "123"
N_VENTAS = 150


# ------ cantidad de productos
MAX_LINEAS_POR_VENTA = 5

# -------- cantidad de unidades por producto
MAX_CANTIDAD_POR_LINEA = 7

# la conecion igual que en el de comrpa - se autentica la sesion
common = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common")
uid = common.authenticate(DB, USUARIO, PASSWORD, {})
if not uid:
    raise SystemExit("ERROR - NO SE PUDO AUTENTICAR")

models = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object")

# eejcuta las peticiones a odoo, se le pasa el modelo, el metodo y los argumentos
def execute(modelo, metodo, *args):
    return models.execute_kw(DB, uid, PASSWORD, modelo, metodo, list(args))


# igual que la otra aca se buscan los clientes, productos y equipos de venta
clientes_ids = execute(
    "res.partner", "search",
    [("category_id.name", "=", "Cliente")]
)
if not clientes_ids:
    raise SystemExit("ERROR - NO SE ENCONTRARON CLIENTES.")

productos_ids = execute(
    "product.product", "search",
    [("categ_id.name", "=", "Productos")]
)
if not productos_ids:
    raise SystemExit("ERROR - NO SE ENCONTRARON PRODUCTOS.")

equipos_ids = execute("crm.team", "search", [])

print(f"SUCCESS - SE ENCONTRADOR CLIENTES, PRODUCTORS Y EQUIPOS DE VENTA!!!!")

# se crean las ventas eligiendo id random y cantidades random dentro del margen
creadas = 0
for i in range(N_VENTAS):
    cliente_id = random.choice(clientes_ids)
    equipo_id = random.choice(equipos_ids) if equipos_ids else False

    n_lineas = random.randint(1, MAX_LINEAS_POR_VENTA)
    productos_venta = random.sample( productos_ids, k=min(n_lineas, len(productos_ids)) )

    lineas = []
    for producto_id in productos_venta:
        cantidad = random.randint(1, MAX_CANTIDAD_POR_LINEA)
        lineas.append((0, 0, {
            "product_id": producto_id,
            "product_uom_qty": cantidad,
        }))

    valores_orden = {
        "partner_id": cliente_id,
        "order_line": lineas, }
    if equipo_id:
        valores_orden["team_id"] = equipo_id

    orden_id = execute("sale.order", "create", valores_orden)

    # confirma
    execute("sale.order", "action_confirm", [orden_id])

    creadas += 1
    print(f" SUCCESS!!! Venta {creadas}CREADA!!!!!!")

print(f"\nSUCCESS -  {creadas} ventas creadas!!!!!!!")
