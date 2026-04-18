# New-Valerita

Flujo solicitado:

1. Página principal de bienvenida (`/`).
2. Botón **Entrar** que lleva al buscador simple (`/buscador.html`).
3. Buscador por código de barras, SKU, nombre o marca.
4. Tabla de resultados con ubicación (rack/caja) y opción de eliminar.

## Ejecutar

```bash
python server.py
```

Luego abrir:

- `http://localhost:8000`

## API usada por UI

- `GET /api/inventario?codigo_barra=&sku=&nombre=&marca=`
- `POST /api/eliminar`

## Estructura clave

- `web/index.html` (bienvenida)
- `web/buscador.html` (buscador + eliminar)
- `server.py`
- `src/new_valerita/inventory.py`
