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
  // Opcional: URL CSV publicada (Archivo -> Compartir -> Publicar en la web -> CSV)
  // publicCsvUrl: 'https://docs.google.com/spreadsheets/d/e/.../pub?output=csv'
  publicCsvUrl: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQTKf_MVDfSJiyo4f7325RNyI1M2bggGWBvoUNuWoWirecMTjJHEonaGwvcAZ24diANIaa28hXWB_ls/pub?gid=0&single=true&output=csv',
  // Opcional: endpoint de Apps Script para leer + eliminar directo sobre la hoja.
  // Si lo completas, el buscador intentará primero cargar datos desde aquí.
  // appsScriptUrl: 'https://script.google.com/macros/s/AKfyc.../exec'
  appsScriptUrl: ''
};

window.SUPABASE_CONFIG = {
  url: '', // Ejemplo: https://xxxxx.supabase.co
  anonKey: '' // Tu anon public key
};
