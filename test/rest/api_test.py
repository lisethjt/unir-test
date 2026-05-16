import http.client
import os
import unittest
from urllib.error import HTTPError
from urllib.request import urlopen

import pytest

BASE_URL = os.environ.get("BASE_URL")
DEFAULT_TIMEOUT = 2  # in secs


@pytest.mark.api
class TestApi(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(BASE_URL, "URL no configurada")
        self.assertTrue(len(BASE_URL) > 8, "URL no configurada")

    def get_status_code(self, url):
        # urlopen lanza HTTPError en respuestas no-2xx; normalizamos ambos casos a codigo.
        try:
            response = urlopen(url, timeout=DEFAULT_TIMEOUT)
            return response.status
        except HTTPError as error:
            return error.code

    def test_api_add(self):
        url = f"{BASE_URL}/calc/add/2/2"
        self.assertEqual(
            self.get_status_code(url), http.client.OK, f"Error en la petición API a {url}"
        )

    def test_api_substract_success(self):
        url = f"{BASE_URL}/calc/substract/10/4"
        self.assertEqual(
            self.get_status_code(url), http.client.OK, f"Error en la petición API a {url}"
        )

    def test_api_multiply_success(self):
        url = f"{BASE_URL}/calc/multiply/3/5"
        self.assertEqual(
            self.get_status_code(url), http.client.OK, f"Error en la petición API a {url}"
        )

    def test_api_divide_success(self):
        url = f"{BASE_URL}/calc/divide/9/3"
        self.assertEqual(
            self.get_status_code(url), http.client.OK, f"Error en la petición API a {url}"
        )

    def test_api_power_success(self):
        url = f"{BASE_URL}/calc/power/2/3"
        self.assertEqual(
            self.get_status_code(url), http.client.OK, f"Error en la petición API a {url}"
        )

    def test_api_square_root_success(self):
        url = f"{BASE_URL}/calc/square-root/9"
        self.assertEqual(
            self.get_status_code(url), http.client.OK, f"Error en la petición API a {url}"
        )

    def test_api_log10_success(self):
        url = f"{BASE_URL}/calc/log10/100"
        self.assertEqual(
            self.get_status_code(url), http.client.OK, f"Error en la petición API a {url}"
        )

    def test_api_add_fails_with_invalid_parameter(self):
        url = f"{BASE_URL}/calc/add/a/2"
        self.assertEqual(
            self.get_status_code(url),
            http.client.BAD_REQUEST,
            f"La API debería devolver 400 en {url}",
        )

    def test_api_divide_fails_with_zero_divisor(self):
        url = f"{BASE_URL}/calc/divide/1/0"
        self.assertEqual(
            self.get_status_code(url),
            http.client.BAD_REQUEST,
            f"La API debería devolver 400 en {url}",
        )

    def test_api_square_root_fails_with_negative_number(self):
        url = f"{BASE_URL}/calc/square-root/-9"
        self.assertEqual(
            self.get_status_code(url),
            http.client.BAD_REQUEST,
            f"La API debería devolver 400 en {url}",
        )

    def test_api_log10_fails_with_non_positive_number(self):
        url = f"{BASE_URL}/calc/log10/0"
        self.assertEqual(
            self.get_status_code(url),
            http.client.BAD_REQUEST,
            f"La API debería devolver 400 en {url}",
        )
