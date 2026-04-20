import json
import unittest
from http import HTTPStatus

from server import AppHandler


class AppHandlerUnitTests(unittest.TestCase):
    def test_first_returns_value_or_none(self) -> None:
        self.assertEqual(AppHandler.first({"sku": [" SKU-1 "]}, "sku"), "SKU-1")
        self.assertIsNone(AppHandler.first({}, "sku"))
        self.assertIsNone(AppHandler.first({"sku": ["   "]}, "sku"))

    def test_json_encoding(self) -> None:
        payload = json.dumps({"ok": True}).encode("utf-8")
        self.assertEqual(payload, b'{"ok": true}')
        self.assertEqual(HTTPStatus.OK, 200)


if __name__ == "__main__":
    unittest.main()
