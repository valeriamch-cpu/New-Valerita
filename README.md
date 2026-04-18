# New-Valerita

## ¿Por qué se veía “estructura de código” y no app?

Porque GitHub Pages muestra la raíz del repo. Antes la UI principal estaba en `web/`, por eso no abría directo como app.

## Solución aplicada

Ahora la app está lista en la **raíz** del repositorio para GitHub Pages:

- `index.html` (bienvenida)
- `buscador.html` (buscador + eliminar)
- `data/inventario.json` (base inicial de productos)
- `.nojekyll` (evita conflictos de render en Pages)

## Uso en GitHub Pages

Abrir:

- `https://valeriamch-cpu.github.io/New-Valerita/`

Flujo:
1. Bienvenido
2. Entrar
3. Buscar por código barra / SKU / nombre / marca
4. Ver ubicación y eliminar

## Nota

En GitHub Pages no corre Python backend; este modo funciona 100% estático con `localStorage` para eliminaciones.
