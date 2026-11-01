# Arquitectura

XDR interno para las laptops Windows de la empresa, diseñado para no mantener ningún servidor encendido. No busca alertas en tiempo real: el administrador revisa los eventos cuando abre el panel.

Microsoft Defender sigue activo como antivirus. Este proyecto agrega visibilidad y respuesta, no lo reemplaza.

```
Laptop (agente + Sysmon + SQLite)
   │  solo conexiones salientes por HTTPS
   ▼
Buzón en la nube (API sin servidor + almacenamiento)
   ▲
   │  al abrir el panel: descarga eventos y envía comandos
Panel web y base de datos en la PC del administrador
```

## Componentes

| Componente | Tecnología | Función |
|---|---|---|
| Agente | Go, servicio de Windows | Registra eventos, los guarda en SQLite, los sube y ejecuta órdenes |
| Sensores | Sysmon y eventos de Defender | Aportan procesos, conexiones, archivos y alertas de malware |
| Buzón | Cloudflare Worker y R2 | Guarda eventos y órdenes hasta que el destinatario los recoge |
| Panel | Web local y base de datos local | Importa eventos, aplica reglas y envía órdenes |
| Infraestructura | Terraform | Declara los recursos de la nube en `infra/` |

## Flujos

**Eventos:** el agente sube lotes comprimidos y cifrados de forma periódica, sin esperar al panel. Así los datos se conservan aunque la laptop esté apagada cuando se abre el panel o la formateen después.

**Órdenes:** el agente consulta el buzón cada pocos minutos. Las laptops no reciben conexiones entrantes, por lo que no necesitan IP pública.

**Datos grandes:** se suben solo bajo pedido, directo al almacenamiento y con un enlace temporal.

**Importación:** el panel sigue siempre este orden:

1. Descargar el lote.
2. Verificar su integridad.
3. Guardarlo en la base de datos local.
4. Borrarlo del bucket.

Si un paso falla, el lote sigue en el bucket y se reintenta sin duplicar datos.

## Requisitos de seguridad

- Las órdenes van firmadas con una clave que solo está en la PC del administrador.
- El agente solo acepta acciones predefinidas, nunca comandos libres.
- Cada laptop tiene su propia credencial y no puede leer datos de otra.
- Las laptops solo pueden subir datos; borrarlos es exclusivo del panel.
- Los lotes se cifran para que solo la PC del administrador pueda leerlos.
- La base de datos local necesita una copia de seguridad cifrada, porque es la única copia del historial.
- Los usuarios de las laptops no deben tener permisos de administrador; con ellos podrían desactivar el agente.
- Los trabajadores deben estar informados por escrito de que las laptops están monitoreadas.

## Portabilidad

- R2 es compatible con la API de S3, así que el mismo código de almacenamiento sirve para ambos.
- El agente y el panel solo hablan con nuestra API, no con servicios de una nube concreta.
- Las órdenes se guardan como archivos en el bucket, sin una base de datos adicional.
- Cada nube tiene su propio módulo en `infra/modules/`. Por ahora solo existe el de Cloudflare.

## Decisiones pendientes

- Cantidad de laptops, para confirmar que el uso entra en el plan gratuito.
- Herramienta para emular Windows durante las pruebas.
