# Reglas del proyecto

## Git

- Trabajar siempre en la rama `master`. No crear ramas ni pull requests.
- Hacer commit y push a `origin/master` sin pedir confirmación después de cada cambio.

## Commits

- El mensaje lleva solo un título y una descripción.
- No incluir autoría ni atribución: nada de `Co-Authored-By`, `Generated with` ni menciones a Claude.

## Tags

- Crear un tag por cada cambio fuerte o característica nueva. Los cambios menores no llevan tag.
- Usar tags anotados con versionado semántico (`vMAYOR.MENOR.PARCHE`):
  - Cambio fuerte o incompatible: sube `MAYOR`.
  - Característica nueva: sube `MENOR`.
- Hacer push del tag junto con el commit:

```sh
git tag -a v1.2.0 -m "Descripción del cambio"
git push origin master v1.2.0
```

## Proyecto

- La arquitectura y las decisiones de diseño están en `docs/arquitectura.md`.
- La infraestructura del VPS está en `infraestructura/vps/`, con Docker Compose. Explicar los pasos de infraestructura, porque el dueño del proyecto está aprendiendo.
- El repo es público: nunca subir secretos.
- PostgreSQL es multipropósito: cada proyecto usa su propio esquema. No nombrar recursos compartidos como si fueran solo del XDR.
- Los secretos del VPS se gestionan en `infraestructura/vps/.env`, y `infraestructura/vps/desplegar.sh` los envía al servidor. No editarlos directamente en el servidor.
- Cada `.env` debe tener al lado un `.env.example` con los mismos nombres y valores de ejemplo. El `.env` nunca se sube a git.
