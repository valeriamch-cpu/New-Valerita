# New-Valerita

## App en GitHub Pages

- `index.html` (bienvenida)
- `buscador.html` (buscador + eliminar)
- `config.js` (conexión a fuentes externas)
- `data/inventario.json` (respaldo local)

## Conexión actual: Google Sheets

La app ya viene configurada para leer tu hoja:

- `https://docs.google.com/spreadsheets/d/141S3HMqerG55owN-sor2EIqn0AEHV-0JZcvzPvptdJE/edit`

El buscador usa este orden:

1. **Apps Script** (si `appsScriptUrl` está configurado).
2. **CSV publicado** (si `publicCsvUrl` está configurado).
3. **Google Sheets** directo (si `sheetId` está configurado).
4. **Supabase** (si `url` + `anonKey` están configurados).
5. **JSON local** (`data/inventario.json`) como fallback.

Si Google Sheets falla por permisos/CORS, el buscador ahora cambia automáticamente a modo local y muestra el detalle del error en pantalla.

Nota sobre botón **Eliminar**:
- Con `appsScriptUrl`: elimina en la base remota.
- Con `publicCsvUrl` o Google Sheets directo sin Apps Script: elimina solo en la vista local del navegador (no borra la fila original en la hoja).

Nota sobre botón **Editar**:
- Con `appsScriptUrl`: edita en la base remota (acción `update`).
- Con `publicCsvUrl` o Google Sheets directo sin Apps Script: edita solo en la vista local del navegador.

## Campos esperados en la hoja

Encabezados (en cualquier orden, sin importar mayúsculas/acentos):

- `sku`
- `codigo_barra` (o `codigo`, `barcode`)
- `nombre` (o `producto`)
- `marca`
- `cantidad` (o `stock`)
- `rack`
- `contenedor` (o `caja`)

## Eliminar registros

- En **Google Sheets**, la eliminación directa requiere configurar `appsScriptUrl` en `config.js`.
- Si no hay `appsScriptUrl`, el modo Google Sheets queda en **solo lectura** y el botón eliminar mostrará aviso.

Guía:

- `docs/google-sheets-setup.md`

## URL pública

- `https://valeriamch-cpu.github.io/New-Valerita/`
