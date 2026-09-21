

import random
import xmlrpc.client

# DATA REAL - LA URL DEL ODOO
URL = "LALALALAL"
DB = "quetzalmart"
USUARIO = "USUARIO ODOO"
PASSWORD = "123"

# COMPRAS A GENERAR
N_COMPRAS = 100

# ------CANTIDAD POR COMPRA
MAX_LINEAS_POR_COMPRA = 3

# ------ cantidad de unidades por producto
MAX_CANTIDAD_POR_LINEA = 17

# SE ABRE UNA CONEXION XON ODOO, en dond e se inicia sesion con las credenciales del admin
common = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common")
uid = common.authenticate(DB, USUARIO, PASSWORD, {})
#si todo ok odoo devuelve el uid
if not uid:
    raise SystemExit("ERROR - NO SE PUDO AUTENTICAR")

models = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object")

# esta conexion es la que permite hacer las cosas
# establece que modelo de odoo, que metodo y que argumentos 
def execute(modelo, metodo, *args):
    return models.execute_kw(DB, uid, PASSWORD, modelo, metodo, list(args))


# obtiene la lista de proveedores y productos
proveedores_ids = execute(
    "res.partner", "search",
    [("category_id.name", "=", "Proveedor")]
)
if not proveedores_ids:
    raise SystemExit("ERROR - NO HAY PROVEEDOR")

# ACA IGUAL SE BUSCAN PERO SE BUSCAN LOS PRODUCTOS
productos_ids = execute(
    "product.product", "search",
    [("categ_id.name", "in", ["Productos", "Materiales"])]
)
if not productos_ids:
    raise SystemExit("ERROR - NO SE ENCONTRARON PRODUCTOS/MATERIALES.")

print(f"SUCCESS - SE ENCONTRADOR PROVEEDORES Y PRODUCTORS!!!!")


# SE CREAN Y CONFIRMAS LAS COMPRAS
creadas = 0
# CUANTAS VECES SE VA A REPETIUR
for i in range(N_COMPRAS):

    #ELIGE PROVEEDOR RANDOM, CANTIDAD DE PRODUCTORS RNADOM Y CUNIDADES RANDOM
    proveedor_id = random.choice(proveedores_ids)

    n_lineas = random.randint(1, MAX_LINEAS_POR_COMPRA)
    #PRODUCTOS RANDOM SIN REPETIR
    items = random.sample(productos_ids, k=min(n_lineas, len(productos_ids)))

    lineas = []
    for producto_id in items:
        cantidad = random.randint(1, MAX_CANTIDAD_POR_LINEA)
        lineas.append((0, 0, {
            "product_id": producto_id,
            "product_qty": cantidad,
        }))

    orden_id = execute("purchase.order", "create", {
        "partner_id": proveedor_id,
        "order_line": lineas,
    })

    # CONFIRMA LA ORDEN 
    execute("purchase.order", "button_confirm", [orden_id])

    creadas += 1
    print(f"Compra {creadas} CREADA!!!!!!")

print(f"\nSUCCESS -  {creadas} compras creadas!!!!!!!")
