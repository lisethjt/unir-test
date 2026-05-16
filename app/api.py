import http.client

from flask import Flask

from app import util
from app.calc import Calculator

CALCULATOR = Calculator()
api_application = Flask(__name__)
HEADERS = {"Content-Type": "text/plain", "Access-Control-Allow-Origin": "*"}
SECURITY_HEADERS = {
    "X-Frame-Options": "DENY",
    "X-Content-Type-Options": "nosniff",
    "Content-Security-Policy": "default-src 'self'; frame-ancestors 'none'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; img-src 'self' data:",
    "Referrer-Policy": "no-referrer",
}


@api_application.after_request
def apply_security_headers(response):
    for header_name, header_value in SECURITY_HEADERS.items():
        response.headers.setdefault(header_name, header_value)
    return response

# Todos los endpoints siguen el mismo contrato: entrada valida => 200, invalida => 400.
@api_application.route("/")
def hello():
    return "Hello from The Calculator!\n"


@api_application.route("/calc/add/<op_1>/<op_2>", methods=["GET"])
def add(op_1, op_2):
    try:
        num_1, num_2 = util.convert_to_number(op_1), util.convert_to_number(op_2)
        return ("{}".format(CALCULATOR.add(num_1, num_2)), http.client.OK, HEADERS)
    except TypeError as e:
        return (str(e), http.client.BAD_REQUEST, HEADERS)


@api_application.route("/calc/substract/<op_1>/<op_2>", methods=["GET"])
def substract(op_1, op_2):
    try:
        num_1, num_2 = util.convert_to_number(op_1), util.convert_to_number(op_2)
        return ("{}".format(CALCULATOR.substract(num_1, num_2)), http.client.OK, HEADERS)
    except TypeError as e:
        return (str(e), http.client.BAD_REQUEST, HEADERS)


@api_application.route("/calc/multiply/<op_1>/<op_2>", methods=["GET"])
def multiply(op_1, op_2):
    try:
        num_1, num_2 = util.convert_to_number(op_1), util.convert_to_number(op_2)
        return ("{}".format(CALCULATOR.multiply(num_1, num_2)), http.client.OK, HEADERS)
    except TypeError as e:
        return (str(e), http.client.BAD_REQUEST, HEADERS)


@api_application.route("/calc/divide/<op_1>/<op_2>", methods=["GET"])
def divide(op_1, op_2):
    try:
        num_1, num_2 = util.convert_to_number(op_1), util.convert_to_number(op_2)
        return ("{}".format(CALCULATOR.divide(num_1, num_2)), http.client.OK, HEADERS)
    except TypeError as e:
        return (str(e), http.client.BAD_REQUEST, HEADERS)


@api_application.route("/calc/power/<op_1>/<op_2>", methods=["GET"])
def power(op_1, op_2):
    try:
        num_1, num_2 = util.convert_to_number(op_1), util.convert_to_number(op_2)
        return ("{}".format(CALCULATOR.power(num_1, num_2)), http.client.OK, HEADERS)
    except TypeError as e:
        return (str(e), http.client.BAD_REQUEST, HEADERS)


@api_application.route("/calc/square-root/<op_1>", methods=["GET"])
def square_root(op_1):
    try:
        num_1 = util.convert_to_number(op_1)
        return ("{}".format(CALCULATOR.square_root(num_1)), http.client.OK, HEADERS)
    except TypeError as e:
        return (str(e), http.client.BAD_REQUEST, HEADERS)


@api_application.route("/calc/log10/<op_1>", methods=["GET"])
def log10(op_1):
    try:
        num_1 = util.convert_to_number(op_1)
        return ("{}".format(CALCULATOR.log10(num_1)), http.client.OK, HEADERS)
    except TypeError as e:
        return (str(e), http.client.BAD_REQUEST, HEADERS)
