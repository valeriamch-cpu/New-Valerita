# New-Valerita

Backend base para evolucionar la app de bodega actual (AppSheet) a una solución mantenible por código.

## Objetivo

Permitir encontrar ubicación exacta de productos y operar inventario por:

- Código de barras
- SKU
- Marca
- Contenedor

También soporta múltiples ubicaciones para un mismo SKU y salida total/parcial por ubicación.

## Qué incluye esta versión

- **Modelo de datos SQL** en `db/schema.sql`.
- **Servicio de inventario** en Python (`InventoryService`) con operaciones de entrada/salida/movimiento/búsqueda.
- **Pruebas automatizadas** de escenarios críticos.
- **Guía de migración** desde AppSheet.

## Estructura

- `db/schema.sql`
- `src/new_valerita/inventory.py`
- `tests/test_inventory.py`
- `docs/api.md`
- `docs/appsheet-integration.md`

## Ejecución de pruebas

```bash
python -m unittest discover -s tests -p 'test_*.py'
```

## Próximo paso

Con acceso a la estructura real de la app en AppSheet, podemos construir el importador de datos y un API HTTP (FastAPI) manteniendo exactamente tus reglas actuales.
