import unittest

from src.new_valerita import InventoryService


class InventoryServiceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.svc = InventoryService()
        self.svc.init_schema()

    def tearDown(self) -> None:
        self.svc.close()

    def test_entrada_y_busqueda_por_sku(self) -> None:
        self.svc.registrar_entrada(
            sku="SKU-001",
            codigo_barra="750000000001",
            marca="ACME",
            nombre="Tuerca 1/2",
            rack="R-01",
            contenedor="C-07",
            cantidad=10,
            usuario="operador",
        )

        result = self.svc.buscar(sku="SKU-001")
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["cantidad"], 10)

    def test_mismo_sku_en_dos_ubicaciones(self) -> None:
        for rack, cont in [("R-01", "C-07"), ("R-02", "C-03")]:
            self.svc.registrar_entrada(
                sku="SKU-001",
                codigo_barra="750000000001",
                marca="ACME",
                nombre="Tuerca 1/2",
                rack=rack,
                contenedor=cont,
                cantidad=5,
                usuario="operador",
            )

        result = self.svc.buscar(sku="SKU-001")
        self.assertEqual(len(result), 2)

    def test_salida_desactiva_al_llegar_a_cero(self) -> None:
        self.svc.registrar_entrada(
            sku="SKU-001",
            codigo_barra="750000000001",
            marca="ACME",
            nombre="Tuerca 1/2",
            rack="R-01",
            contenedor="C-07",
            cantidad=3,
        )
        self.svc.registrar_salida(
            sku="SKU-001",
            rack="R-01",
            contenedor="C-07",
            cantidad=3,
            eliminar_si_cero=True,
        )
        result = self.svc.buscar(sku="SKU-001")
        self.assertEqual(result, [])

    def test_movimiento_transfiere_stock(self) -> None:
        self.svc.registrar_entrada(
            sku="SKU-001",
            codigo_barra="750000000001",
            marca="ACME",
            nombre="Tuerca 1/2",
            rack="R-01",
            contenedor="C-07",
            cantidad=10,
        )
        self.svc.mover(
            sku="SKU-001",
            origen_rack="R-01",
            origen_contenedor="C-07",
            destino_rack="R-03",
            destino_contenedor="C-02",
            cantidad=4,
        )

        origen = self.svc.buscar(sku="SKU-001", contenedor="C-07")
        destino = self.svc.buscar(sku="SKU-001", contenedor="C-02")

        self.assertEqual(origen[0]["cantidad"], 6)
        self.assertEqual(destino[0]["cantidad"], 4)

    def test_busqueda_por_nombre(self) -> None:
        self.svc.registrar_entrada(
            sku="SKU-ABC",
            codigo_barra="750000001111",
            marca="ACME",
            nombre="Perno Largo",
            rack="R-10",
            contenedor="C-99",
            cantidad=2,
        )
        result = self.svc.buscar(nombre="perno")
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["sku"], "SKU-ABC")

    def test_eliminar_ubicacion(self) -> None:
        self.svc.registrar_entrada(
            sku="SKU-DEL",
            codigo_barra="750000009999",
            marca="ACME",
            nombre="Producto Borrar",
            rack="R-05",
            contenedor="C-01",
            cantidad=7,
        )
        self.svc.eliminar_ubicacion("SKU-DEL", "R-05", "C-01")
        result = self.svc.buscar(sku="SKU-DEL")
        self.assertEqual(result, [])


if __name__ == "__main__":
    unittest.main()
