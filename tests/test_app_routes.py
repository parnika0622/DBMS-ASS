import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.app import app


class TestAppRoutes(unittest.TestCase):
    def setUp(self):
        app.config["TESTING"] = True
        self.client = app.test_client()

    def test_routes_status_code(self):
        endpoints = [
            "/",
            "/members",
            "/teams",
            "/facilities",
            "/training",
            "/tournaments",
            "/equipment",
            "/reports",
            "/reports?tab=standings",
            "/reports?tab=facilities",
            "/reports?tab=players",
            "/reports?tab=dues",
            "/reports?tab=equipment",
            "/sql-console"
        ]
        for ep in endpoints:
            response = self.client.get(ep)
            self.assertEqual(
                response.status_code, 200,
                f"Endpoint {ep} failed with status {response.status_code}"
            )
            print(f"[OK] Route {ep} returned 200 OK")


if __name__ == "__main__":
    unittest.main()
