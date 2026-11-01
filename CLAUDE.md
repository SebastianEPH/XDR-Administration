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
- La infraestructura se administra con Terraform en `infraestructura/`. Explicar los pasos de Terraform, porque el dueño del proyecto lo está aprendiendo.
- El repo es público: nunca subir secretos, `terraform.tfvars` ni `terraform.tfstate`.
- Cada `.env` debe tener al lado un `.env.example` con los mismos nombres y valores de ejemplo. El `.env` nunca se sube a git.
