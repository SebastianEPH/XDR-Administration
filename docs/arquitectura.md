# Arquitectura

XDR interno para las laptops Windows de la empresa, con un VPS económico como punto público y base de datos, y la PC del administrador para el análisis pesado. No busca alertas en tiempo real: el administrador revisa los eventos cuando abre el panel.

Microsoft Defender sigue activo como antivirus. Este proyecto agrega visibilidad y respuesta, no lo reemplaza.

```
Laptop (agente + Sysmon + SQLite)
   │  solo conexiones salientes por HTTPS
   ▼
VPS (API + frp + PostgreSQL) ──── R2 (lotes de eventos)
   ▲
   │  túnel saliente iniciado por la PC del administrador
Panel web y análisis en la PC del administrador
```

## Componentes

| Componente | Tecnología | Función |
|---|---|---|
| Agente (`cliente/`) | Go, servicio de Windows | Registra eventos, los guarda en SQLite, los sube y ejecuta órdenes |
| Sensores | Sysmon y eventos de Defender | Aportan procesos, conexiones, archivos y alertas de malware |
| VPS | OVH VPS-1 con Docker: API y frp | Autentica a los agentes, guarda órdenes pendientes y reenvía sesiones en vivo |
| Base de datos | PostgreSQL 18 en Docker, en el VPS | Guarda eventos, alertas e historial |
| Almacenamiento | Cloudflare R2 | Guarda los lotes hasta que el panel los importa |
| Panel (`admin/`) | Web local | Importa eventos a la base de datos, aplica reglas y envía órdenes |
| Infraestructura (`infraestructura/`) | Terraform | Declara los recursos de la nube |

## Flujos

**Eventos:** el agente sube lotes comprimidos y cifrados de forma periódica, sin esperar al panel. Así los datos se conservan aunque la PC del administrador esté apagada o la laptop se formatee después.

**Órdenes:** el agente consulta el VPS cada pocos minutos. Si la laptop está apagada, la orden espera hasta que vuelva a conectarse. Las laptops no reciben conexiones entrantes, por lo que no necesitan IP pública.

**Datos grandes:** se suben solo bajo pedido, directo a R2 y con un enlace temporal.

**Importación:** el panel sigue siempre este orden:

1. Descargar el lote.
2. Verificar su integridad.
3. Descifrarlo en la PC del administrador y guardarlo en PostgreSQL por un túnel SSH.
4. Borrarlo del bucket.

Si un paso falla, el lote sigue en el bucket y se reintenta sin duplicar datos.

**Acceso remoto:** una orden firmada hace que el agente abra un túnel saliente hacia el VPS. El túnel se cierra al terminar la sesión o al vencer su plazo, así que no queda abierto de forma permanente.

**Si el panel está cerrado:** los agentes siguen subiendo eventos y consultando órdenes, pero no hay sesiones en vivo. El trabajo pesado se ejecuta solo en la PC del administrador.

## Requisitos de seguridad

- Las órdenes van firmadas con una clave que solo está en la PC del administrador, de modo que tomar el VPS no permite controlar las laptops.
- El agente solo acepta acciones predefinidas, nunca comandos libres.
- Cada laptop tiene su propia credencial y no puede leer datos de otra.
- Las laptops solo pueden subir datos; borrarlos es exclusivo del panel.
- Los lotes se cifran para que solo la PC del administrador pueda leerlos.
- frp exige token y cifrado, y solo expone los servicios necesarios.
- La pantalla de administración y la base de datos nunca se exponen a internet.
- El VPS tiene el firewall limitado a los puertos necesarios y SSH solo con clave.
- Antes de instalar agentes en laptops reales, el XDR debe tener un VPS propio, sin otros proyectos públicos.
- PostgreSQL nunca se expone a internet: solo escucha en el VPS y se accede por un túnel SSH.
- La base de datos necesita copias de seguridad cifradas fuera del VPS, porque es la única copia del historial.
- Los eventos quedan legibles en el VPS una vez importados, así que proteger el servidor es crítico.
- Hay que vigilar el disco: el VPS tiene 40 GB y debe definirse cuánto tiempo se conserva el historial.
- Los usuarios de las laptops no deben tener permisos de administrador; con ellos podrían desactivar el agente.
- Los trabajadores deben estar informados por escrito de que las laptops están monitoreadas y de que existe acceso remoto.

## Portabilidad

- R2 es compatible con la API de S3, así que el mismo código de almacenamiento sirve para ambos.
- El agente y el panel solo hablan con nuestra API, no con servicios de una nube concreta.
- Cada nube tiene su propia carpeta en `infraestructura/`: Cloudflare y AWS son alternativas y solo se despliega una.
- El VPS se contrata manualmente y su configuración debe poder repetirse en otro proveedor.

## Decisiones pendientes

- Cantidad de laptops.
- Herramienta para emular Windows durante las pruebas.
- Herramienta de acceso remoto: administración por comandos o vista de pantalla.
- Tiempo de retención de los eventos en la base de datos.
