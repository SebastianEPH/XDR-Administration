# Arquitectura

XDR interno para las laptops Windows de la empresa, con un VPS económico como punto público y base de datos, y la PC del administrador para el análisis pesado. No busca alertas en tiempo real: el administrador revisa los eventos cuando abre el panel.

Microsoft Defender sigue activo como antivirus. Este proyecto agrega visibilidad y respuesta, no lo reemplaza.

```
Laptop (agente + Sysmon + SQLite)
   │  solo conexiones salientes por HTTPS
   ▼
VPS con Docker (Caddy + API + frp + PostgreSQL)
   ▲
   │  túnel SSH y túnel frp, iniciados por la PC del administrador
Panel web y análisis en la PC del administrador
```

## Componentes

| Componente | Tecnología | Función |
|---|---|---|
| Agente (`cliente/`) | Go, servicio de Windows | Registra eventos, los guarda en SQLite, los envía y ejecuta órdenes |
| Sensores | Sysmon y eventos de Defender | Aportan procesos, conexiones, archivos y alertas de malware |
| Entrada web | Caddy en Docker | Recibe el tráfico HTTPS y lo reenvía a la API |
| API | Go en Docker | Autentica a los agentes, guarda eventos y entrega órdenes |
| Túneles | frp en Docker | Reenvía sesiones en vivo hacia la PC del administrador y las laptops |
| Base de datos | PostgreSQL 18 en Docker | Servidor compartido entre proyectos; cada uno usa su esquema, y el XDR guarda en `xdr` sus eventos, alertas, órdenes e historial |
| Panel (`admin/`) | Web local | Consulta la base de datos, aplica reglas y envía órdenes |
| Infraestructura (`infraestructura/vps/`) | Docker Compose | Define los servicios del VPS |

## Flujos

**Eventos:** el agente envía lotes comprimidos a la API de forma periódica, sin esperar al panel. Si no hay conexión, los guarda en SQLite y los reintenta. Así los datos se conservan aunque la PC del administrador esté apagada o la laptop se formatee después.

**Órdenes:** el agente consulta el VPS cada pocos minutos. Si la laptop está apagada, la orden espera hasta que vuelva a conectarse. Las laptops no reciben conexiones entrantes, por lo que no necesitan IP pública.

**Datos grandes:** se suben solo bajo pedido y se guardan temporalmente en el disco del VPS hasta que el panel los descarga.

**Análisis:** el panel lee los eventos por lotes desde PostgreSQL a través de un túnel SSH y procesa lo pesado en la PC del administrador.

**Acceso remoto:** una orden firmada hace que el agente abra un túnel saliente hacia el VPS. El túnel se cierra al terminar la sesión o al vencer su plazo, así que no queda abierto de forma permanente.

**Si el panel está cerrado:** los agentes siguen enviando eventos y consultando órdenes, pero no hay sesiones en vivo.

## Requisitos de seguridad

- Las órdenes van firmadas con una clave que solo está en la PC del administrador, de modo que tomar el VPS no permite controlar las laptops.
- El agente solo acepta acciones predefinidas, nunca comandos libres.
- Cada laptop tiene su propia credencial y no puede leer datos de otra.
- Las laptops solo pueden enviar eventos; no pueden leerlos ni borrarlos.
- frp exige token y cifrado, y solo expone los servicios necesarios.
- PostgreSQL nunca se expone a internet: solo escucha en el VPS y se accede por un túnel SSH.
- La pantalla de administración nunca se expone a internet.
- El VPS tiene el firewall limitado a los puertos necesarios y SSH solo con clave.
- Los eventos quedan legibles en el VPS, así que proteger el servidor es crítico.
- Antes de instalar agentes en laptops reales, el XDR debe tener un VPS propio, sin otros proyectos públicos.
- La base de datos necesita copias de seguridad cifradas fuera del VPS, porque es la única copia del historial.
- Los usuarios de las laptops no deben tener permisos de administrador; con ellos podrían desactivar el agente.
- Los trabajadores deben estar informados por escrito de que las laptops están monitoreadas y de que existe acceso remoto.

## Capacidad

El VPS tiene 40 GB de disco y 4 GB de RAM. Eventos, archivos temporales y copias locales comparten ese espacio, por lo que hay que definir el tiempo de retención y vigilar el uso del disco.

## Portabilidad

El VPS se contrata manualmente. Su configuración está en `infraestructura/vps/` y debe poder repetirse en otro proveedor.

## Decisiones pendientes

- Cantidad de laptops.
- Herramienta para emular Windows durante las pruebas.
- Herramienta de acceso remoto: administración por comandos o vista de pantalla.
- Tiempo de retención de los eventos en la base de datos.
- Destino de las copias de seguridad.
