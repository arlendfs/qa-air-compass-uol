import pytest

from src.calculadora import Calculadora

class TestCalculadora:
    """Testes para a classe Calculadora."""

    @pytest.fixture
    def calc(self):
        """Fixture para criar uma instância da Calculadora."""
        return Calculadora()
    
    """Teste para o método somar usando pytest.mark.parametrize para testar múltiplos casos."""
    @pytest.mark.parametrize("a, b, esperado", [
        (2, 3, 5),
        (-1, 1, 0),
        (0, 0, 0),
        (1.5, 2.5, 4.0),
        (100, 200, 300),
        (-2, -3, -5)
    ])

    def test_somar(self, calc, a, b, esperado):
        """Teste para o método somar."""
        resultado = calc.somar(a, b)
        assert resultado == esperado

    """Teste para o método subtrair usando pytest.mark.parametrize para testar múltiplos casos."""
    @pytest.mark.parametrize("a, b, esperado", [
        (2, 3, -1),
        (15, 10, 5),
        (0, 0, 0),
        (3.5, 2.5, 1.0),
        (-5, -4, -1),
        (5, -3, 8)
    ])

    def test_subtrair(self, calc, a, b, esperado):
        """Teste para o método subtrair."""
        resultado = calc.subtrair(a, b)
        assert resultado == esperado


    @pytest.mark.parametrize("a, b, esperado", [
        (2, 3, 6),
        (-2, 3, -6),
        (0, 5, 0),
        (2.5, 2, 5.0),
        (-3, -3, 9)
    ])

    def test_multiplicar(self, calc, a, b, esperado):
        """Teste para o método multiplicar."""
        resultado = calc.multiplicar(a, b)
        assert resultado == esperado

    """Teste para o método dividir usando pytest.mark.parametrize para testar múltiplos casos, incluindo divisão por zero."""
    @pytest.mark.parametrize("a, b, esperado", [
        (6, 3, 2),
        (5, 2, 2.5),
        (-8, 2, -4),
        (8, -2, -4),
        (-8, -2, 4),
    ])

    def test_dividir(self, calc, a, b, esperado):
        """Teste para o método dividir."""
        resultado = calc.dividir(a, b)
        assert resultado == esperado

    def test_dividir_por_zero(self, calc):
        """Teste para verificar se a divisão por zero lança ValueError."""
        with pytest.raises(ValueError, match="Divisão por zero não é permitida."):
            calc.dividir(5, 0)
