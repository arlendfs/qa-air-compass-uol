import pytest

from src.calculadora import Calculadora

class TestCalculadora:
    """Testes para a classe Calculadora."""
   
    def test_somar(self):
        """Teste para o método somar."""
        calculadora = Calculadora()
        resultado = calculadora.somar(2, 3)
        assert resultado == 5