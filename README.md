# New-Valerita

Aplicación para bodega orientada a encontrar la ubicación específica de productos por:

- Código de barras
- SKU
- Marca
- Contenedor

También soporta múltiples ubicaciones para el mismo SKU (por rack/contenedor) y gestión de salidas para limpiar inventario cuando un producto se retira.

## Alcance MVP

1. **Búsqueda de inventario** con filtros por código de barra, SKU, marca y contenedor.
2. **Registro de entradas** de producto por ubicación.
3. **Registro de salidas** con opción de desactivar la ubicación al llegar a cantidad cero.
4. **Movimiento entre ubicaciones** para transferir producto entre racks/contenedores.
5. **Historial de movimientos** para trazabilidad.

## Estructura del proyecto

- `db/schema.sql`: esquema relacional inicial.
- `docs/api.md`: contrato API propuesto para endpoints del MVP.

## Reglas de negocio base

- Un mismo SKU puede existir en múltiples ubicaciones.
- Una ubicación se identifica por combinación única de `rack + contenedor`.
- El inventario se gestiona por `producto + ubicación`.
- Al salir un producto por completo de una ubicación, el registro puede desactivarse.

## Próximos pasos sugeridos

1. Implementar backend (por ejemplo, Node.js/Express o FastAPI).
2. Crear autenticación simple por usuario operador.
3. Agregar interfaz con escaneo de código de barras.
4. Configurar reportes de existencias por zona/rack.
