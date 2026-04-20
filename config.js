// Configuración de fuentes de datos externas.
// Prioridad en buscador:
// 1) GOOGLE_SHEETS_CONFIG (si tiene sheetId)
// 2) SUPABASE_CONFIG (si tiene url + anonKey)
// 3) data/inventario.json (modo local)

window.GOOGLE_SHEETS_CONFIG = {
  // Base compartida por el usuario:
  // https://docs.google.com/spreadsheets/d/141S3HMqerG55owN-sor2EIqn0AEHV-0JZcvzPvptdJE/edit
  sheetId: '141S3HMqerG55owN-sor2EIqn0AEHV-0JZcvzPvptdJE',
  gid: '0',
  sheetName: '',
  // Opcional: endpoint de Apps Script para permitir eliminación directa sobre la hoja.
  // appsScriptUrl: 'https://script.google.com/macros/s/AKfyc.../exec'
  appsScriptUrl: ''
};

window.SUPABASE_CONFIG = {
  url: '', // Ejemplo: https://xxxxx.supabase.co
  anonKey: '' // Tu anon public key
};
