# Integración y mejora sobre AppSheet (VALERITA 5.0)

Esta base busca mejorar la app operativa actual en AppSheet, dejando reglas de negocio y datos en un backend controlado por código.

## Qué ya queda resuelto en este repositorio

- Esquema SQL normalizado para productos, ubicaciones, inventario y movimientos.
- Servicio de dominio (`InventoryService`) para:
  - entrada,
  - salida,
  - traslado,
  - búsqueda por SKU/código de barras/marca/contenedor.
- Suite inicial de pruebas automatizadas.

## Plan recomendado de migración desde AppSheet

1. Exportar tablas actuales desde AppSheet/Google Sheets.
2. Mapear columnas existentes a:
   - `productos`
   - `ubicaciones`
   - `inventario_ubicacion`
   - `movimientos`
3. Importar datos históricos a SQLite/PostgreSQL.
4. Validar paridad funcional contra la app actual (consultas, entradas, salidas y movimientos).
5. Encender API REST y luego UI web/móvil.

## Información que necesitamos de tu app actual

Para cerrar paridad al 100%, necesitamos:
- Nombres exactos de tablas/hojas.
- Campos obligatorios y reglas de validación.
- Flujo real de operación por rol (bodega, supervisor, etc.).
- Catálogo de estados (si usan pendientes/aprobados/cerrados).
