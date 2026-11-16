"""Opérations arithmétiques de base."""


def additionner(a: float, b: float) -> float:
    """Retourne a + b."""
    return a + b


def soustraire(a: float, b: float) -> float:
    """Retourne a - b."""
    return a - b


def multiplier(a: float, b: float) -> float:
    """Retourne a * b."""
    return a * b


def diviser(a: float, b: float) -> float:
    """Retourne a / b.

    Raises:
        ZeroDivisionError: si b vaut 0.
    """
    if b == 0:
        raise ZeroDivisionError("Division par zéro impossible")
    return a / b
