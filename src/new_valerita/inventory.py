from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from typing import Any


@dataclass
class LocationRef:
    rack: str
    contenedor: str
    zona: str | None = None


class InventoryService:
    """Servicio base para gestionar inventario por ubicación."""

    def __init__(self, db_path: str = ":memory:") -> None:
        self.conn = sqlite3.connect(db_path)
        self.conn.row_factory = sqlite3.Row

    def close(self) -> None:
        self.conn.close()

    def init_schema(self, schema_path: str = "db/schema.sql") -> None:
        with open(schema_path, "r", encoding="utf-8") as f:
            self.conn.executescript(f.read())
        self.conn.commit()

    def _get_or_create_product(
        self,
        sku: str,
        codigo_barra: str | None,
        marca: str,
        nombre: str,
    ) -> int:
        row = self.conn.execute("SELECT id FROM productos WHERE sku = ?", (sku,)).fetchone()
        if row:
            self.conn.execute(
                """
                UPDATE productos
                SET codigo_barra = COALESCE(?, codigo_barra),
                    marca = ?,
                    nombre = ?,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = ?
                """,
                (codigo_barra, marca, nombre, row["id"]),
            )
            return int(row["id"])

        cur = self.conn.execute(
            """
            INSERT INTO productos (sku, codigo_barra, marca, nombre)
            VALUES (?, ?, ?, ?)
            """,
            (sku, codigo_barra, marca, nombre),
        )
        return int(cur.lastrowid)

    def _get_or_create_location(self, ref: LocationRef) -> int:
        row = self.conn.execute(
            "SELECT id FROM ubicaciones WHERE rack = ? AND contenedor = ?",
            (ref.rack, ref.contenedor),
        ).fetchone()
        if row:
            self.conn.execute(
                "UPDATE ubicaciones SET zona = COALESCE(?, zona), activo = 1, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
                (ref.zona, row["id"]),
            )
            return int(row["id"])

        cur = self.conn.execute(
            "INSERT INTO ubicaciones (rack, contenedor, zona) VALUES (?, ?, ?)",
            (ref.rack, ref.contenedor, ref.zona),
        )
        return int(cur.lastrowid)

    def _ensure_inventory_row(self, product_id: int, location_id: int) -> int:
        row = self.conn.execute(
            "SELECT id FROM inventario_ubicacion WHERE producto_id = ? AND ubicacion_id = ?",
            (product_id, location_id),
        ).fetchone()
        if row:
            return int(row["id"])

        cur = self.conn.execute(
            "INSERT INTO inventario_ubicacion (producto_id, ubicacion_id, cantidad, activo) VALUES (?, ?, 0, 1)",
            (product_id, location_id),
        )
        return int(cur.lastrowid)

    def registrar_entrada(
        self,
        sku: str,
        codigo_barra: str | None,
        marca: str,
        nombre: str,
        rack: str,
        contenedor: str,
        cantidad: int,
        usuario: str | None = None,
    ) -> None:
        if cantidad <= 0:
            raise ValueError("cantidad debe ser mayor que 0")

        product_id = self._get_or_create_product(sku, codigo_barra, marca, nombre)
        location_id = self._get_or_create_location(LocationRef(rack=rack, contenedor=contenedor))
        inventory_id = self._ensure_inventory_row(product_id, location_id)

        self.conn.execute(
            "UPDATE inventario_ubicacion SET cantidad = cantidad + ?, activo = 1, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
            (cantidad, inventory_id),
        )
        self.conn.execute(
            """
            INSERT INTO movimientos (tipo, producto_id, ubicacion_destino_id, cantidad, usuario)
            VALUES ('entrada', ?, ?, ?, ?)
            """,
            (product_id, location_id, cantidad, usuario),
        )
        self.conn.commit()

    def registrar_salida(
        self,
        sku: str,
        rack: str,
        contenedor: str,
        cantidad: int,
        usuario: str | None = None,
        eliminar_si_cero: bool = True,
    ) -> None:
        if cantidad <= 0:
            raise ValueError("cantidad debe ser mayor que 0")

        row = self.conn.execute(
            """
            SELECT p.id AS producto_id, u.id AS ubicacion_id, i.id AS inventario_id, i.cantidad
            FROM productos p
            JOIN inventario_ubicacion i ON i.producto_id = p.id
            JOIN ubicaciones u ON u.id = i.ubicacion_id
            WHERE p.sku = ? AND u.rack = ? AND u.contenedor = ? AND i.activo = 1
            """,
            (sku, rack, contenedor),
        ).fetchone()
        if not row:
            raise ValueError("No existe inventario activo para ese SKU y ubicación")
        if int(row["cantidad"]) < cantidad:
            raise ValueError("Stock insuficiente")

        self.conn.execute(
            "UPDATE inventario_ubicacion SET cantidad = cantidad - ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
            (cantidad, row["inventario_id"]),
        )
        if eliminar_si_cero:
            self.conn.execute(
                "UPDATE inventario_ubicacion SET activo = CASE WHEN cantidad = 0 THEN 0 ELSE activo END WHERE id = ?",
                (row["inventario_id"],),
            )

        self.conn.execute(
            """
            INSERT INTO movimientos (tipo, producto_id, ubicacion_origen_id, cantidad, usuario)
            VALUES ('salida', ?, ?, ?, ?)
            """,
            (row["producto_id"], row["ubicacion_id"], cantidad, usuario),
        )
        self.conn.commit()

    def mover(
        self,
        sku: str,
        origen_rack: str,
        origen_contenedor: str,
        destino_rack: str,
        destino_contenedor: str,
        cantidad: int,
        usuario: str | None = None,
    ) -> None:
        self.registrar_salida(
            sku=sku,
            rack=origen_rack,
            contenedor=origen_contenedor,
            cantidad=cantidad,
            usuario=usuario,
            eliminar_si_cero=True,
        )

        prod = self.conn.execute("SELECT codigo_barra, marca, nombre FROM productos WHERE sku = ?", (sku,)).fetchone()
        if not prod:
            raise ValueError("Producto no encontrado")

        self.registrar_entrada(
            sku=sku,
            codigo_barra=prod["codigo_barra"],
            marca=prod["marca"],
            nombre=prod["nombre"],
            rack=destino_rack,
            contenedor=destino_contenedor,
            cantidad=cantidad,
            usuario=usuario,
        )

        # Re-clasificar los dos movimientos generados como un movimiento de traslado lógico.
        self.conn.execute(
            """
            INSERT INTO movimientos (tipo, producto_id, ubicacion_origen_id, ubicacion_destino_id, cantidad, usuario)
            SELECT 'movimiento', p.id, uo.id, ud.id, ?, ?
            FROM productos p
            JOIN ubicaciones uo ON uo.rack = ? AND uo.contenedor = ?
            JOIN ubicaciones ud ON ud.rack = ? AND ud.contenedor = ?
            WHERE p.sku = ?
            """,
            (cantidad, usuario, origen_rack, origen_contenedor, destino_rack, destino_contenedor, sku),
        )
        self.conn.commit()

    def buscar(self, **filters: Any) -> list[dict[str, Any]]:
        clauses = ["i.activo = 1", "u.activo = 1"]
        params: list[Any] = []

        if filters.get("sku"):
            clauses.append("p.sku = ?")
            params.append(filters["sku"])
        if filters.get("codigo_barra"):
            clauses.append("p.codigo_barra = ?")
            params.append(filters["codigo_barra"])
        if filters.get("marca"):
            clauses.append("LOWER(p.marca) LIKE LOWER(?)")
            params.append(f"%{filters['marca']}%")
        if filters.get("contenedor"):
            clauses.append("u.contenedor = ?")
            params.append(filters["contenedor"])

        query = f"""
        SELECT p.sku, p.codigo_barra, p.marca, p.nombre,
               u.rack, u.contenedor, u.zona,
               i.cantidad, i.updated_at
        FROM inventario_ubicacion i
        JOIN productos p ON p.id = i.producto_id
        JOIN ubicaciones u ON u.id = i.ubicacion_id
        WHERE {' AND '.join(clauses)}
        ORDER BY p.sku, u.rack, u.contenedor
        """

        rows = self.conn.execute(query, tuple(params)).fetchall()
        return [dict(r) for r in rows]
