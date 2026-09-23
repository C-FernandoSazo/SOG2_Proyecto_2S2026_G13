# Portal Web

Documentación técnica de la configuración de la tienda en línea (eCommerce), integrados al ERP/CRM de QuetzalMart. 

## 1. Tienda en línea (eCommerce)

### 1.1 Creación del sitio con el Configurador de Odoo
Al instalar la app **Website**, Odoo lanza automáticamente el asistente **"Configurador de sitio web"**, que arma el sitio (incluido el módulo de eCommerce) en 4 pasos guiados:

1. **Inicio del asistente** — pantalla "¿Todo listo para crear el sitio web perfecto?", se inicia con el botón **¡Hagámoslo!**.

![PORTALWEB](capturas/portalweb7.png)

2. **Paso 1 — Tipo de sitio**: en el campo "Quiero ___" se elige **"una tienda en línea"** (entre las opciones: sitio web empresarial, tienda en línea, blog, sitio de evento, plataforma de elearning).

![PORTALWEB](capturas/portalweb1.png)

3. **Paso 1 — Rubro del negocio**: se completa "para mi negocio de ___" con **"Tienda de comestibles"**.

![PORTALWEB](capturas/portalweb2.png)

4. **Paso 1 — Objetivo principal**: se despliega el selector de objetivo (obtener leads, impulsar la marca, vender más, informar a los clientes, programar citas) y se elige el objetivo del sitio.

![PORTALWEB](capturas/portalweb8.png)
![PORTALWEB](capturas/portalweb3.png)

5. **Paso 2 — Paleta de colores**: Odoo detecta colores automáticamente a partir del logo de QuetzalMart subido y se elige la paleta (tonos café/crema, acorde a la marca). Se continúa con **¡Vamos!**.

![PORTALWEB](capturas/portalweb9.png)

6. **Paso 3 — Páginas y funciones**: se seleccionan las páginas/funciones a activar en el sitio. Marcadas: **Sobre nosotros**, **Política de privacidad**, **Tienda** (aplicación de Comercio electrónico — clave para tener la tienda en línea), **Chat en vivo** y **Ubicación de tiendas**. Se confirma con **Crear mi sitio web**.

![PORTALWEB](capturas/portalweb5.png)
![PORTALWEB](capturas/portalweb10.png)

7. **Paso 4 — Tema visual**: se elige la plantilla/tema del sitio entre las opciones propuestas por Odoo.
![PORTALWEB](capturas/portalweb11.png)

8. **Generación automática del sitio**: Odoo aplica colores y diseño, busca imágenes, adapta los bloques de contenido y genera texto inicial ("Creando su sitio web..." → "Finalizando").
![PORTALWEB](capturas/portalweb12.png)
![PORTALWEB](capturas/portalweb13.png)

9. **Resultado**: sitio publicado y funcionando en `http://18.222.102.249`, con la tienda QuetzalMart ya operativa (menú **Tienda**, ícono de carrito de compras visible, toggle **Publicado** activado).
![PORTALWEB](capturas/portalweb14.png)

### 1.2 Catálogo de productos
- Productos ya cargados y publicados en el sitio (`Publicado = true`) desde Sitio Web → eCommerce → Productos.
- Verificado: imagen, descripción y precio visibles en la ficha de cada producto.
- Productos agrupados por categorías de sitio web para navegación ordenada del catálogo.

![PUBLI](capturas/product_publicados.png)

### 1.3 Carrito de compras
- Agregar/quitar productos, cambio de cantidades, recálculo de subtotal en tiempo real.

![CARRITO](capturas/carrito1.png)
![CARRITO](capturas/carrito2.png)

### 1.4 Impuestos
- Impuesto de venta (IVA) configurado como impuesto por defecto en los productos.
- Verificado en el carrito: la línea de impuesto se calcula correctamente al finalizar la compra.

### 1.5 Cálculo de envío
- Método de envío configurado (precio fijo) y publicado en el sitio web.
- Verificado en el checkout: el método aparece seleccionable y el total se recalcula con el costo de envío.

### 1.6 Métodos de pago
Dos proveedores de pago configurados:

| Proveedor | Comportamiento |
| --- | --- |
| **Demo** (simula pago con tarjeta) | Confirma el pago automáticamente → dispara la generación automática de la factura. Es el método recomendado para pruebas y para el día de la calificación. |
| **Transferencia bancaria** | Queda en estado "pendiente de confirmación" hasta validación manual del pago recibido. Este es el comportamiento **esperado** de Odoo, no un error: no hay forma de confirmar automáticamente que el dinero llegó sin una pasarela real. |

![PAGO](capturas/MetodoDePago.png)

### 1.7 Facturación automática conectada al ERP/CRM
- Activado en **Sitio Web → Configuración → Ajustes → Shop - Checkout Process → Automatic Invoice**.
- Flujo verificado de punta a punta:
  1. Cliente compra en la tienda y paga con Demo.
  2. Se confirma la orden de venta automáticamente (visible en Ventas → Pedidos), demostrando la integración con el ERP.
  3. El cliente se crea/actualiza automáticamente en Contactos/CRM.
  4. La factura se genera sola (sin intervención manual) y queda asociada a la orden.

![ORDEN](capturas/orden.png)

### 1.8 Envío de correo con la factura (SMTP)
Problema inicial: la factura no llegaba por correo. Causas encontradas y solución:

1. **Servidor de correo saliente sin configurar** → se creó un servidor SMTP dedicado (Gmail, cuenta neutral del proyecto, no personal de ningún integrante, cumpliendo el requisito del enunciado de Marketing).
2. **Error de red al probar la conexión** (`[Errno 101] Network is unreachable`): la VM (AWS EC2) intentaba resolver `smtp.gmail.com` por IPv6, sin ruta de salida IPv6 configurada en la VPC.
   - Diagnóstico: `curl -4` conectaba bien, `curl -6` fallaba.
   - Solución aplicada en el host: en `/etc/gai.conf` se habilitó la línea `precedence ::ffff:0:0/96  100` para forzar preferencia de IPv4 en la resolución DNS del sistema.
   - Se reinició el contenedor Docker `quetzalmart-odoo` (`docker restart quetzalmart-odoo`) para aplicar el cambio.
3. **Gmail rechazaba el remitente** (`5.5.2 Syntax error, cannot decode response`): causado por un carácter inválido/invisible copiado en el campo de usuario del servidor SMTP. Se corrigió retipeando manualmente el correo y la contraseña de aplicación (sin copiar/pegar) en los campos de Usuario, FROM Filter y correo de la Compañía.
4. Con eso, la conexión SMTP quedó exitosa y el correo con la factura llega correctamente al cliente, con remitente institucional del proyecto (no personal).

![FACT](capturas/factura.png)