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
            raise ValueError("Divisão por zero não é permitida.")
        return a / b
