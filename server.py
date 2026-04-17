from __future__ import annotations

import json
import secrets
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

from src.new_valerita import InventoryService

USERS = {
    "admin": "1234",
    "bodega": "valerita2026",
}

TOKENS: set[str] = set()


class AppHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        self.web_root = Path(__file__).parent / "web"
        super().__init__(*args, directory=str(self.web_root), **kwargs)

    @property
    def svc(self) -> InventoryService:
        return self.server.inventory_service  # type: ignore[attr-defined]

    def do_POST(self) -> None:
        if self.path == "/api/login":
            self.handle_login()
            return
        self.send_error(HTTPStatus.NOT_FOUND)

    def do_GET(self) -> None:
        if self.path.startswith("/api/search"):
            self.handle_search()
            return
        if self.path == "/":
            self.path = "/index.html"
        return super().do_GET()

    def handle_login(self) -> None:
        length = int(self.headers.get("Content-Length", "0"))
        payload = self.rfile.read(length)
        try:
            data = json.loads(payload.decode("utf-8"))
        except json.JSONDecodeError:
            self.send_json({"error": "JSON inválido"}, HTTPStatus.BAD_REQUEST)
            return

        usuario = data.get("usuario", "")
        clave = data.get("clave", "")
        if USERS.get(usuario) != clave:
            self.send_json({"error": "Credenciales inválidas"}, HTTPStatus.UNAUTHORIZED)
            return

        token = secrets.token_urlsafe(24)
        TOKENS.add(token)
        self.send_json({"token": token}, HTTPStatus.OK)

    def handle_search(self) -> None:
        auth = self.headers.get("Authorization", "")
        if not auth.startswith("Bearer "):
            self.send_json({"error": "No autorizado"}, HTTPStatus.UNAUTHORIZED)
            return

        token = auth.replace("Bearer ", "", 1)
        if token not in TOKENS:
            self.send_json({"error": "Token inválido"}, HTTPStatus.UNAUTHORIZED)
            return

        parsed = urlparse(self.path)
        query = parse_qs(parsed.query)
        items = self.svc.buscar(
            sku=self.first(query, "sku"),
            codigo_barra=self.first(query, "codigo_barra"),
            marca=self.first(query, "marca"),
        )
        self.send_json({"items": items}, HTTPStatus.OK)

    @staticmethod
    def first(query: dict[str, list[str]], key: str) -> str | None:
        values = query.get(key)
        if not values:
            return None
        value = values[0].strip()
        return value or None

    def send_json(self, body: dict, status: HTTPStatus) -> None:
        payload = json.dumps(body).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


def bootstrap_sample_data(svc: InventoryService) -> None:
    svc.init_schema()
    existing = svc.buscar(sku="SKU-001")
    if existing:
        return

    svc.registrar_entrada(
        sku="SKU-001",
        codigo_barra="750000000001",
        marca="ACME",
        nombre="Tuerca 1/2",
        rack="R-01",
        contenedor="C-07",
        cantidad=14,
        usuario="bootstrap",
    )
    svc.registrar_entrada(
        sku="SKU-001",
        codigo_barra="750000000001",
        marca="ACME",
        nombre="Tuerca 1/2",
        rack="R-03",
        contenedor="C-11",
        cantidad=8,
        usuario="bootstrap",
    )
    svc.registrar_entrada(
        sku="SKU-777",
        codigo_barra="750000000777",
        marca="TORNIMAX",
        nombre="Arandela 3/8",
        rack="R-02",
        contenedor="C-02",
        cantidad=40,
        usuario="bootstrap",
    )


def run() -> None:
    svc = InventoryService("inventory.db")
    bootstrap_sample_data(svc)

    server = ThreadingHTTPServer(("0.0.0.0", 8000), AppHandler)
    server.inventory_service = svc  # type: ignore[attr-defined]

    print("Servidor iniciado en http://localhost:8000")
    print("Usuarios demo: admin/1234 o bodega/valerita2026")
    try:
        server.serve_forever()
    finally:
        svc.close()


if __name__ == "__main__":
    run()
