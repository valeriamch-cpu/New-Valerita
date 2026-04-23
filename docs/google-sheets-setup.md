# Google Sheets Setup

## 1) Compartir la hoja

Para que GitHub Pages pueda leer datos desde el navegador, la hoja debe estar compartida con acceso de lectura:

- **Share / Compartir** → **Anyone with the link** → **Viewer**.

## 2) Configurar `config.js`

```js
window.GOOGLE_SHEETS_CONFIG = {
  sheetId: '141S3HMqerG55owN-sor2EIqn0AEHV-0JZcvzPvptdJE',
  gid: '0',
  sheetName: '',
  appsScriptUrl: ''
};
```

- Usa `gid` cuando quieras apuntar a una pestaña específica.
- O usa `sheetName` (nombre de la pestaña) y deja `gid` como está.

## 3) Columnas de inventario

Encabezados sugeridos:

- `sku`
- `codigo_barra`
- `nombre`
- `marca`
- `cantidad`
- `rack`
- `contenedor`

Sinónimos soportados por la app:

- `codigo` o `barcode` para `codigo_barra`
- `producto` para `nombre`
- `stock` para `cantidad`
- `caja` para `contenedor`

## 4) Habilitar eliminar (opcional)

Google Sheets no permite `DELETE` directo desde GitHub Pages. Para borrar filas desde la app:

1. Crea un **Google Apps Script Web App**.
2. Implementa un endpoint `POST` que reciba `{ action: 'delete', sku, rack, contenedor }`.
3. Publica el script y pega su URL en `appsScriptUrl`.

Si `appsScriptUrl` está vacío, la app usa Google Sheets en modo solo lectura.
En ese caso, el botón **Eliminar** solo oculta filas localmente en el navegador.
En ese caso, el botón **Editar** también aplica cambios solo localmente.

Si quieres impedir esas mutaciones locales (y exigir escritura real), deja en `config.js`:

```js
window.APP_CONFIG = { allowLocalMutations: false };
```

Si `appsScriptUrl` está configurado, la app intenta primero leer inventario desde Apps Script con:

- `GET <appsScriptUrl>?action=list&sku=...&codigo_barra=...&nombre=...&marca=...`
- `POST <appsScriptUrl>` con `{ action: "update", sku, rack_original, contenedor_original, cantidad, rack, contenedor, ... }`
- `POST <appsScriptUrl>` con `{ action: "delete", sku, rack, contenedor }`

Respuesta esperada (cualquiera de las dos):

```json
[{ "sku": "SKU-1", "codigo_barra": "123", "nombre": "Prod", "marca": "Marca", "cantidad": 10, "rack": "R1", "contenedor": "C1" }]
```

o

```json
{ "items": [ ... ] }
```

## 4.1) Alternativa simple: CSV publicado

Si no quieres Apps Script, puedes publicar una pestaña como CSV y usar `publicCsvUrl`:

1. En Google Sheets: **Archivo → Compartir → Publicar en la web**.
2. Elige la pestaña y formato **CSV**.
3. Copia la URL pública y pégala en `config.js`:

```js
publicCsvUrl: 'https://docs.google.com/spreadsheets/d/e/.../pub?output=csv'
```

## 5) Si aparece `Error: Failed to fetch`

Eso normalmente indica permisos de la hoja o bloqueo CORS del endpoint seleccionado.

Checklist rápido:

1. Confirma: **Share → Anyone with the link → Viewer**.
2. Verifica que `sheetId` y `gid` sean correctos.
3. Si usas nombre de pestaña, prueba con `sheetName`.
4. Reintenta en incógnito para descartar caché.

La app intenta Apps Script, CSV publicado y luego rutas directas (`gviz` por JSONP, `gviz` por fetch y `export csv`); si todas fallan, cae a `data/inventario.json` como respaldo.
