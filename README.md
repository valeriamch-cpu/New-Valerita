# New-Valerita

Versión directa: al abrir la app entra de inmediato a la página de inventario.

## Pantalla principal

Muestra datos de bodega en tabla con columnas:

- SKU
- Código barra
- Nombre
- Marca
- Stock
- Rack
- Caja

## Ejecutar

```bash
python server.py
```

Abrir en navegador:

- `http://localhost:8000`

## Backend

- `GET /api/inventario` (también `GET /api/search`)
- Filtros: `sku`, `codigo_barra`, `marca`

## Archivos principales

- `web/index.html`
- `server.py`
- `src/new_valerita/inventory.py`
- `db/schema.sql`

## Tests

```bash
python -m unittest discover -s tests -p 'test_*.py'
```
