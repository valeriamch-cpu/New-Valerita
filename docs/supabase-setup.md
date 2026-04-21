# Supabase setup (Super Base)

## 1) Crea tabla `inventario`

```sql
create table if not exists inventario (
  id bigint generated always as identity primary key,
  sku text not null,
  codigo_barra text,
  nombre text not null,
  marca text not null,
  cantidad integer not null default 0,
  rack text not null,
  contenedor text not null,
  created_at timestamptz not null default now()
);
```

## 2) Carga masiva

En Supabase -> Table editor -> `inventario` -> Import data from CSV.

## 3) Activa acceso desde frontend

En el proyecto Supabase, usa la `anon key` y URL del proyecto.

## 4) Configura `config.js`

```js
window.SUPABASE_CONFIG = {
  url: 'https://TU-PROYECTO.supabase.co',
  anonKey: 'TU_ANON_KEY'
};
```

## 5) Publica en GitHub

Al abrir la app:
- Si `config.js` está vacío => modo local (`data/inventario.json`).
- Si `config.js` tiene URL/key => modo Supabase real.
