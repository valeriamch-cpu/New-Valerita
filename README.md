# Bodega App — Inventario de Bodega Offline-First

App de gestión de inventario para bodegas, offline-first, para **Windows** (prioridad) y **Android**.  
Permite ubicar productos por **Rack** y **Caja/Contenedor**, registrar movimientos de stock y sincronizar cuando haya conexión.

---

## Características principales

- **Autenticación local** con roles `admin` / `operador` (funciona sin internet)
- **Catálogo de productos**: SKU, código de barras, nombre, marca
- **Búsqueda** por código de barras, SKU, nombre, marca (compatible con escáner USB/teclado)
- **Inventario por ubicación**: Rack → Caja → SKU con cantidades
- **Movimientos inmutables** (eventos): UUID, device_id, user_id, timestamp, sku, caja_id, delta
- **Stock no puede ser negativo** por Caja+SKU
- **Importar CSV de Bsale** (columnas: `nombre`, `marca`, `codigo_barra`, `sku`)
- **Tabla outbox** para sincronización futura con servidor central
- **Gestión de usuarios** (solo admin)

---

## Estructura del proyecto

```
lib/
  data/
    database.dart              ← Schema SQLite, migraciones, seed admin
    models/
      usuario.dart
      producto.dart
      rack.dart
      caja.dart
      movimiento.dart
    repositories/
      auth_repository.dart
      producto_repository.dart
      rack_repository.dart
      caja_repository.dart
      movimiento_repository.dart
  ui/
    providers/
      auth_provider.dart
      inventario_provider.dart
    screens/
      login_screen.dart
      home_screen.dart
      productos_screen.dart
      producto_detail_screen.dart
      cajas_screen.dart
      caja_detail_screen.dart
      racks_screen.dart
      movimiento_screen.dart
      importar_csv_screen.dart
      usuarios_screen.dart
```

---

## Schema de base de datos (SQLite local)

```sql
-- Usuarios del sistema
CREATE TABLE usuarios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,       -- SHA-256
  role TEXT NOT NULL DEFAULT 'operador'  -- 'admin' | 'operador'
);

-- Catálogo de productos
CREATE TABLE productos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sku TEXT NOT NULL UNIQUE,
  barcode TEXT,
  nombre TEXT NOT NULL,
  marca TEXT
);

-- Rack (ubicación fija)
CREATE TABLE racks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL UNIQUE
);

-- Caja/Contenedor (puede estar en un rack)
CREATE TABLE cajas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL UNIQUE,        -- ej: "C4"
  rack_id INTEGER REFERENCES racks(id)
);

-- Movimientos (eventos inmutables)
CREATE TABLE movimientos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  uuid TEXT NOT NULL UNIQUE,
  device_id TEXT NOT NULL,
  user_id INTEGER NOT NULL REFERENCES usuarios(id),
  timestamp TEXT NOT NULL,
  sku TEXT NOT NULL REFERENCES productos(sku),
  caja_id INTEGER NOT NULL REFERENCES cajas(id),
  delta INTEGER NOT NULL,             -- positivo=entrada, negativo=salida
  synced INTEGER NOT NULL DEFAULT 0
);

-- Outbox para sincronización futura
CREATE TABLE outbox (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  movimiento_uuid TEXT NOT NULL UNIQUE,
  created_at TEXT NOT NULL,
  sent INTEGER NOT NULL DEFAULT 0
);
```

**Stock calculado**: `SELECT SUM(delta) FROM movimientos WHERE caja_id=? AND sku=?`

---

## Usuario semilla (primer arranque)

| Campo    | Valor      |
|----------|-----------|
| Usuario  | `admin`   |
| Contraseña | `admin123` |
| Rol     | `admin`   |

Crea usuarios adicionales desde el menú **Usuarios** (solo admin).

---

## Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.5.0
- Para Windows: Visual Studio con "Desktop development with C++"
- Para Android: Android SDK / Android Studio

---

## Instalación y ejecución en Windows

```powershell
# 1. Clonar el repositorio
git clone https://github.com/valeriamch-cpu/New-Valerita.git
cd New-Valerita

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en Windows
flutter run -d windows

# 4. Compilar ejecutable Windows
flutter build windows
# El ejecutable queda en: build\windows\x64\runner\Release\bodega_app.exe
```

### Requisito adicional Windows
Asegúrate de tener instalado el paquete **sqflite_common_ffi** (ya incluido en pubspec.yaml). No se requiere instalación adicional de SQLite: viene incluido en el ejecutable.

---

## Instalación y ejecución en Android

```bash
# 1. Conectar dispositivo Android o iniciar emulador

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en Android
flutter run -d android

# 4. Compilar APK
flutter build apk --release
# El APK queda en: build/app/outputs/flutter-apk/app-release.apk
```

---

## Importar productos desde Bsale (CSV)

1. En Bsale exporta el catálogo a CSV.
2. El archivo debe tener las columnas (con header): `nombre`, `marca`, `codigo_barra`, `sku`
3. En la app ve a **Productos → Importar CSV** y selecciona el archivo.
4. La app insertará o ignorará (sin duplicar) los productos por SKU.

Ejemplo de CSV válido:
```csv
nombre,marca,codigo_barra,sku
Aceite Vegetal 1L,Natura,7801234567890,AV-001
Detergente 500g,Ariel,7809876543210,DT-002
```

---

## Flujo de movimiento rápido (escáner de barras)

1. Ir a **Movimiento** en el menú principal.
2. Escanear o escribir el código de barras / SKU del producto → presionar **Enter**.
3. La app identifica el producto automáticamente.
4. Escanear o seleccionar la **Caja** destino.
5. Ingresar cantidad y presionar **+** (entrada) o **−** (salida).
6. La app valida que el stock no quede negativo.
7. El movimiento se registra localmente (con UUID, device_id, timestamp).

> El campo de búsqueda acepta entrada rápida de escáner USB (actúa como teclado) y envía al presionar Enter.

---

## Sincronización (futuro)

La arquitectura está lista para sincronización:
- Todos los movimientos tienen `synced = 0` hasta que se envíen.
- La tabla `outbox` lleva los movimientos pendientes.
- Para implementar sync, se agrega un servicio que lea `outbox WHERE sent = 0` y los envíe al servidor.
- El servidor acepta movimientos idempotentes (por UUID).
