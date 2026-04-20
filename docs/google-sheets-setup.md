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
