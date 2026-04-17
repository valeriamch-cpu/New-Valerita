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
        routes = {
            "/api/login": self.handle_login,
            "/api/entrada": self.handle_entrada,
            "/api/salida": self.handle_salida,
            "/api/movimiento": self.handle_movimiento,
        }
        handler = routes.get(self.path)
        if handler:
            handler()
            return
        self.send_error(HTTPStatus.NOT_FOUND)

    def do_GET(self) -> None:
        if self.path.startswith("/api/search"):
            self.handle_search()
            return
        if self.path in ("/", "/dashboard.html"):
            self.path = "/index.html"
        return super().do_GET()

    def handle_login(self) -> None:
        data = self.read_json_body()
        if data is None:
            return

        usuario = data.get("usuario", "")
        clave = data.get("clave", "")
        if USERS.get(usuario) != clave:
            self.send_json({"error": "Credenciales inválidas"}, HTTPStatus.UNAUTHORIZED)
            return

        token = secrets.token_urlsafe(24)
        TOKENS.add(token)
        self.send_json({"token": token, "usuario": usuario}, HTTPStatus.OK)

    def handle_search(self) -> None:
        if not self.require_auth():
            return

        parsed = urlparse(self.path)
        query = parse_qs(parsed.query)
        items = self.svc.buscar(
            sku=self.first(query, "sku"),
            codigo_barra=self.first(query, "codigo_barra"),
            marca=self.first(query, "marca"),
            contenedor=self.first(query, "contenedor"),
        )
        self.send_json({"items": items}, HTTPStatus.OK)

    def handle_entrada(self) -> None:
        if not self.require_auth():
            return
        data = self.read_json_body()
        if data is None:
            return

        required = ["sku", "marca", "nombre", "rack", "contenedor", "cantidad"]
        missing = [k for k in required if k not in data or data[k] in ("", None)]
        if missing:
            self.send_json({"error": f"Campos requeridos: {', '.join(missing)}"}, HTTPStatus.BAD_REQUEST)
            return

        try:
            self.svc.registrar_entrada(
                sku=str(data["sku"]),
                codigo_barra=str(data.get("codigo_barra") or "") or None,
                marca=str(data["marca"]),
                nombre=str(data["nombre"]),
                rack=str(data["rack"]),
                contenedor=str(data["contenedor"]),
                cantidad=int(data["cantidad"]),
                usuario="web",
            )
        except ValueError as exc:
            self.send_json({"error": str(exc)}, HTTPStatus.BAD_REQUEST)
            return

        self.send_json({"ok": True, "message": "Entrada registrada"}, HTTPStatus.OK)

    def handle_salida(self) -> None:
        if not self.require_auth():
            return
        data = self.read_json_body()
        if data is None:
            return

        required = ["sku", "rack", "contenedor", "cantidad"]
        missing = [k for k in required if k not in data or data[k] in ("", None)]
        if missing:
            self.send_json({"error": f"Campos requeridos: {', '.join(missing)}"}, HTTPStatus.BAD_REQUEST)
            return

        try:
            self.svc.registrar_salida(
                sku=str(data["sku"]),
                rack=str(data["rack"]),
                contenedor=str(data["contenedor"]),
                cantidad=int(data["cantidad"]),
                usuario="web",
                eliminar_si_cero=True,
            )
        except ValueError as exc:
            self.send_json({"error": str(exc)}, HTTPStatus.BAD_REQUEST)
            return

        self.send_json({"ok": True, "message": "Salida registrada"}, HTTPStatus.OK)

    def handle_movimiento(self) -> None:
        if not self.require_auth():
            return
        data = self.read_json_body()
        if data is None:
            return

        required = ["sku", "origen_rack", "origen_contenedor", "destino_rack", "destino_contenedor", "cantidad"]
        missing = [k for k in required if k not in data or data[k] in ("", None)]
        if missing:
            self.send_json({"error": f"Campos requeridos: {', '.join(missing)}"}, HTTPStatus.BAD_REQUEST)
            return

        try:
            self.svc.mover(
                sku=str(data["sku"]),
                origen_rack=str(data["origen_rack"]),
                origen_contenedor=str(data["origen_contenedor"]),
                destino_rack=str(data["destino_rack"]),
                destino_contenedor=str(data["destino_contenedor"]),
                cantidad=int(data["cantidad"]),
                usuario="web",
            )
        except ValueError as exc:
            self.send_json({"error": str(exc)}, HTTPStatus.BAD_REQUEST)
            return

        self.send_json({"ok": True, "message": "Movimiento registrado"}, HTTPStatus.OK)

    def read_json_body(self) -> dict | None:
        length = int(self.headers.get("Content-Length", "0"))
        payload = self.rfile.read(length)
        try:
            return json.loads(payload.decode("utf-8"))
        except json.JSONDecodeError:
            self.send_json({"error": "JSON inválido"}, HTTPStatus.BAD_REQUEST)
            return None

    def require_auth(self) -> bool:
        auth = self.headers.get("Authorization", "")
        if not auth.startswith("Bearer "):
            self.send_json({"error": "No autorizado"}, HTTPStatus.UNAUTHORIZED)
            return False

        token = auth.replace("Bearer ", "", 1)
        if token not in TOKENS:
            self.send_json({"error": "Token inválido"}, HTTPStatus.UNAUTHORIZED)
            return False
        return True

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
