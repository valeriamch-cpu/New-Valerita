# New-Valerita

Flujo solicitado:

1. Página principal de bienvenida (`/`).
2. Botón **Entrar** que lleva al buscador simple (`/buscador.html`).
3. Buscador por código de barras, SKU, nombre o marca.
4. Tabla de resultados con ubicación (rack/caja) y opción de eliminar.

## Ejecutar local (con backend Python)

```bash
python server.py
```

Abrir:

- `http://localhost:8000`

## GitHub Pages (estático)

Si abres en `valeriamch-cpu.github.io/New-Valerita/`, no existe backend Python.
Por eso el buscador corre en **modo estático** leyendo:

- `web/data/inventario.json`

La eliminación en GitHub Pages se guarda en `localStorage` del navegador (no en servidor).

## API usada por UI (modo local)

- `GET /api/inventario?codigo_barra=&sku=&nombre=&marca=`
- `POST /api/eliminar`

## Estructura clave

- `web/index.html` (bienvenida)
- `web/buscador.html` (buscador + eliminar)
- `web/data/inventario.json` (datos estáticos para GitHub Pages)
- `server.py`
- `src/new_valerita/inventory.py`
