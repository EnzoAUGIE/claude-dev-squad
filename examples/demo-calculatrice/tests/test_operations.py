import pytest

from calculatrice import additionner, diviser, multiplier, soustraire


def test_additionner():
    assert additionner(2, 3) == 5


def test_soustraire():
    assert soustraire(5, 3) == 2


def test_multiplier():
    assert multiplier(4, 2.5) == 10


def test_diviser():
    assert diviser(9, 3) == 3


def test_diviser_par_zero():
    with pytest.raises(ZeroDivisionError):
        diviser(1, 0)
