# New-Valerita

Ahora sí partimos con formato **app** (single-page) para operación de bodega.

## Qué incluye

- Pantalla de login.
- App principal con pestañas:
  - Buscar ubicación
  - Registrar entrada
  - Registrar salida
  - Mover producto
- Backend HTTP con endpoints autenticados para esas operaciones.

## Ejecutar

```bash
python server.py
```

Abrir en navegador:

- `http://localhost:8000`

Usuarios demo:

- `admin / 1234`
- `bodega / valerita2026`

## Archivos principales

- `server.py` (API + servidor web)
- `web/index.html` (UI tipo app)
- `src/new_valerita/inventory.py` (reglas de inventario)
- `db/schema.sql` (modelo de datos)

## Tests

```bash
python -m unittest discover -s tests -p 'test_*.py'
```
