# API inicial (MVP)

## 1) Buscar inventario
`GET /api/inventario/buscar?q=&sku=&codigo_barra=&marca=&contenedor=`

### Respuesta 200
```json
{
  "items": [
    {
      "producto": {
        "id": 1,
        "sku": "SKU-001",
        "codigo_barra": "750000000001",
        "marca": "ACME",
        "nombre": "Tuerca 1/2"
      },
      "ubicacion": {
        "id": 2,
        "rack": "R-01",
        "contenedor": "C-07",
        "zona": "A"
      },
      "cantidad": 12,
      "updated_at": "2026-04-17T12:00:00Z"
    }
  ]
}
```

## 2) Registrar entrada
`POST /api/movimientos/entrada`

```json
{
  "sku": "SKU-001",
  "rack": "R-01",
  "contenedor": "C-07",
  "cantidad": 12,
  "usuario": "operador_1"
}
```

Comportamiento:
- Crea producto/ubicación si no existen.
- Suma cantidad en inventario_ubicacion.
- Registra movimiento tipo `entrada`.

## 3) Registrar salida
`POST /api/movimientos/salida`

```json
{
  "sku": "SKU-001",
  "rack": "R-01",
  "contenedor": "C-07",
  "cantidad": 3,
  "usuario": "operador_1",
  "eliminar_si_cero": true
}
```

Comportamiento:
- Resta cantidad.
- Si llega a cero y `eliminar_si_cero=true`, marca registro inactivo.
- Registra movimiento tipo `salida`.

## 4) Mover inventario
`POST /api/movimientos/mover`

```json
{
  "sku": "SKU-001",
  "origen": { "rack": "R-01", "contenedor": "C-07" },
  "destino": { "rack": "R-03", "contenedor": "C-02" },
  "cantidad": 2,
  "usuario": "operador_2"
}
```

Comportamiento:
- Descuenta en origen.
- Incrementa en destino.
- Registra movimiento tipo `movimiento`.

## 5) Eliminar ubicación de un SKU (salida total)
`DELETE /api/inventario/ubicacion`

```json
{
  "sku": "SKU-001",
  "rack": "R-01",
  "contenedor": "C-07",
  "usuario": "operador_1"
}
```

Comportamiento:
- Deja cantidad en 0 y marca inactivo.
- Registra salida equivalente en movimientos.
