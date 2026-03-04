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
        assert resultado == pytest.approx(esperado)

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
        assert resultado == pytest.approx(esperado)


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
        assert resultado == pytest.approx(esperado)

    """Teste para o método dividir usando pytest.mark.parametrize para testar múltiplos casos, incluindo divisão por zero."""
    @pytest.mark.parametrize("a, b, esperado", [
        (6, 3, 2),
        (5, 2, 2.5),
        (-8, 2, -4),
        (8, -2, -4),
        (-8, -2, 4),
        (0, 5, 0),
    ])

    def test_dividir(self, calc, a, b, esperado):
        """Teste para o método dividir."""
        resultado = calc.dividir(a, b)
        assert resultado == pytest.approx(esperado)

    def test_dividir_por_zero(self, calc):
        """Teste para verificar se a divisão por zero lança ValueError."""
        with pytest.raises(ZeroDivisionError):
            calc.dividir(5, 0)

    """Teste para o método raiz_quadrada usando pytest.mark.parametrize para testar múltiplos casos, incluindo casos de borda."""
    @pytest.mark.parametrize("a, esperado", [
        (4, 2),
        (1, 1),
        (0, 0),
        (2, 1.41421356),
    ])

    def test_raiz_quadrada(self, calc, a, esperado):
        """Teste para o método raiz_quadrada."""
        assert calc.raiz_quadrada(a) == pytest.approx(esperado)

    def test_raiz_quadrada_negativa(self, calc):
        """Teste para verificar se a raiz quadrada de um número negativo lança ValueError."""
        with pytest.raises(ValueError):
            calc.raiz_quadrada(-4)

    """Teste para o método potencia usando pytest.mark.parametrize para testar múltiplos casos, incluindo casos de borda e expoentes negativos."""
    @pytest.mark.parametrize("base, expoente, esperado", [
        (2, 3, 8),
        (5, 2, 25),
        (10, 1, 10),
        (7, 0, 1),
        (1, 999, 1),
        (0, 5, 0),
        (-2, 3, -8),
        (-2, 2, 4),
        (2, -1, 0.5),
    ])

    def test_potencia(self, calc, base, expoente, esperado):
        """Teste parametrizado para potência"""
        assert calc.potencia(base, expoente) == pytest.approx(esperado)

    @pytest.mark.parametrize("base, expoente", [
        (0, -1),
        (0, -5),
    ])

    def test_potencia_zero_expoente_negativo(self, calc, base, expoente):
        """Teste para verificar se zero elevado a um expoente negativo lança ZeroDivisionError."""
        with pytest.raises(ZeroDivisionError):
            calc.potencia(base, expoente)

