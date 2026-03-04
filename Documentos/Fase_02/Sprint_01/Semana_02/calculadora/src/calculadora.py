import math

class Calculadora:
    """Classe para realizar operações matemáticas básicas."""
    def somar(self, a, b):
        """Retorna a soma de a e b."""
        return a + b

    def subtrair(self, a, b):
        """Retorna a subtração de a por b."""
        return a - b
    
    def multiplicar(self, a, b):
        """Retorna a multiplicação de a por b."""
        return a * b

    def dividir(self, a, b):
        """Retorna a divisão de a por b. Lança ValueError se b for zero."""
        if b == 0:
            raise ZeroDivisionError("Divisão por zero não é permitida.")
        return a / b

    def raiz_quadrada(self, a):
        """Retorna a raiz quadrada de a. Lança ValueError se a for negativo."""
        if a < 0:
            raise ValueError("Raiz quadrada de número negativo não é permitida.")
        return math.sqrt(a)
