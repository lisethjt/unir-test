import app
import math


class Calculator:
    def add(self, x, y):
        self.check_types(x, y)
        return x + y

    def substract(self, x, y):
        self.check_types(x, y)
        return x - y

    def multiply(self, x, y):
        # Mantiene la validacion de permisos junto a la operacion protegida.
        if not app.util.validate_permissions(f"{x} * {y}", "user1"):
            raise TypeError("User has no permissions")

        self.check_types(x, y)
        return x * y

    def divide(self, x, y):
        self.check_types(x, y)
        if y == 0:
            raise TypeError("Division by zero is not possible")

        return x / y

    def power(self, x, y):
        self.check_types(x, y)
        return x ** y

    def square_root(self, x):
        self.check_type(x)
        if x < 0:
            raise TypeError("Square root is not possible for negative numbers")

        return math.sqrt(x)

    def log10(self, x):
        self.check_type(x)
        if x <= 0:
            raise TypeError("Logarithm base 10 is only possible for positive numbers")

        return math.log10(x)

    def check_types(self, x, y):
        self.check_type(x)
        self.check_type(y)

    def check_type(self, x):
        # bool se rechaza de forma explicita, aunque herede de int.
        if isinstance(x, bool) or not isinstance(x, (int, float)):
            raise TypeError("Parameter must be a number")

        # Evita que valores NaN/Inf se propaguen en las operaciones.
        if not math.isfinite(x):
            raise TypeError("Parameter must be a finite number")


if __name__ == "__main__":  # pragma: no cover
    calc = Calculator()
    result = calc.add(2, 2)
    print(result)
