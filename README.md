# New-Valerita

Backend + interfaz web inicial para mejorar la operación actual de bodega (hoy en AppSheet).

## Lo que ya puedes usar

1. **Login web** con usuario y clave.
2. **Pantalla buscador** por `SKU`, `código de barras` o `marca`.
3. Resultado con ubicación exacta (`rack` y `contenedor`) y cantidad.
4. Soporte de lógica inventario en backend (`entrada`, `salida`, `movimiento`, `buscar`).

## Usuarios demo

- `admin / 1234`
- `bodega / valerita2026`

## Ejecutar la app

```bash
python server.py
```

Abrir en navegador:

- `http://localhost:8000`

## Estructura

- `server.py`: servidor HTTP con login y API de búsqueda.
- `web/index.html`: página de inicio de sesión.
- `web/dashboard.html`: buscador de productos y ubicación.
- `src/new_valerita/inventory.py`: reglas de inventario.
- `db/schema.sql`: esquema SQL.

## Tests

```bash
python -m unittest discover -s tests -p 'test_*.py'
```

## Siguiente mejora recomendada

Con tus tablas reales de AppSheet, conectamos importación directa y agregamos módulo de entradas/salidas desde interfaz (no solo búsqueda).
