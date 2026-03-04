# Calculadora com Python com Pytest

Projeto desenvolvido para praticar TDD durante meus estudos em testes automatizados com Python e Pytest para AI/R - Compass UOL.

## Sobre

Calculadora simples com 6 operações implementadas seguindo a metodologia Test-Driven Development (testes primeiro, código depois).

### Operações

| Operação | Método | Descrição |
|----------|--------|-----------|
| Soma | `somar(a, b)` | a + b |
| Subtração | `subtrair(a, b)` | a - b |
| Multiplicação | `multiplicar(a, b)` | a * b |
| Divisão | `dividir(a, b)` | a / b (com validação) |
| Raiz Quadrada | `raiz_quadrada(a)` | √a (com validação) |
| Potência | `potencia(base, expoente)` | base^expoente |

## Estrutura

```bash
calculadora-tdd-python/
├── src/
│ ├── init.py
│ └── calculadora.py
├── tests/
│ ├── init.py
│ └── test_calculadora.py
├── .gitignore
├── pytest.ini
├── README.md
└── requirements.txt
````

## Tecnologias e Conceitos

- Python 3.9+
- Pytest para testes automatizados
- TDD (Test-Driven Development)
- Testes Parametrizados com `@pytest.mark.parametrize`
- Testes de Exceções com `pytest.raises`
- Fixtures para setup dos testes
- Cobertura de Código com pytest-cov

## Testes Implementados
### Operações Básicas
## Soma
```python
@pytest.mark.parametrize("a, b, esperado", [
    (2, 3, 5),
    (-1, 1, 0),
    (0, 0, 0),
    (1.5, 2.5, 4.0),
    (100, 200, 300),
    (-2, -3, -5)
])

def test_somar(self, calc, a, b, esperado):
    resultado = calc.somar(a, b)
    assert resultado == pytest.approx(esperado)

```

## Subtração

```python
@pytest.mark.parametrize("a, b, esperado", [
    (2, 3, -1),
    (15, 10, 5),
    (0, 0, 0),
    (3.5, 2.5, 1.0),
    (-5, -4, -1),
    (5, -3, 8)
])

def test_subtrair(self, calc, a, b, esperado):
    resultado = calc.subtrair(a, b)
    assert resultado == pytest.approx(esperado)

```

## Mutiplacação

```python
@pytest.mark.parametrize("a, b, esperado", [
    (2, 3, 6),
    (-2, 3, -6),
    (0, 5, 0),
    (2.5, 2, 5.0),
    (-3, -3, 9)
])

def test_multiplicar(self, calc, a, b, esperado):
    resultado = calc.multiplicar(a, b)
    assert resultado == pytest.approx(esperado)
```
## Divisão com Exceção

```python
@pytest.mark.parametrize("a, b, esperado", [
    (6, 3, 2),
    (5, 2, 2.5),
    (-8, 2, -4),
    (8, -2, -4),
    (-8, -2, 4),
    (0, 5, 0),
])

def test_dividir(self, calc, a, b, esperado):
    resultado = calc.dividir(a, b)
    assert resultado == pytest.approx(esperado)

def test_dividir_por_zero(self, calc):
    with pytest.raises(ZeroDivisionError):
        calc.dividir(5, 0)
```
## Raiz Quadrada

```python
@pytest.mark.parametrize("a, esperado", [
    (4, 2),
    (1, 1),
    (0, 0),
    (2, 1.41421356),
])
def test_raiz_quadrada(self, calc, a, esperado):
    assert calc.raiz_quadrada(a) == pytest.approx(esperado)

def test_raiz_quadrada_negativa(self, calc):
    with pytest.raises(ValueError):
        calc.raiz_quadrada(-4)
```
O maior desafio foi lidar com comparação de números float em operações como raiz quadrada de 2. 
Resolvi usando pytest.approx para evitar falhas por precisão numérica.

## Potência

```python
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
    assert calc.potencia(base, expoente) == pytest.approx(esperado)

@pytest.mark.parametrize("base, expoente", [
    (0, -1),
    (0, -5),
])
def test_potencia_zero_expoente_negativo(self, calc, base, expoente):
    with pytest.raises(ZeroDivisionError):
        calc.potencia(base, expoente)
```
Decidi delegar a divisão por zero ao comportamento nativo do Python (ZeroDivisionError) em vez de criar uma exceção personalizada, mantendo coerência com a linguagem.

## Clone o repositório
```bash
git clone https://github.com/seu-usuario/calculadora-tdd-python.git
cd calculadora-tdd-python

# Crie e ative um ambiente virtual (opcional)
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows
```

## Instale as dependências
```bash
pip install -r requirements.txt
````

## Execute os teste

```bash
pytest
pytest -v
pytest --cov=src --cov-report=term-missing
pytest -k potencia -v
pytest -k raiz -v
```

## Configuração do Pytest (pytest.ini)

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
markers =
    excecao: Testes que verificam exceções
    operacoes_basicas: Testes das operações básicas (soma, subtracao, multiplicacao)
    operacoes_avancadas: Testes de raiz quadrada e potencia
addopts = -v --tb=short --strict-markers
```

## Dependências (requirements.txt)
```bash
- pytest==9.0.2
- pytest-cov==7.0.0
```

## O que aprendi
- Escrever testes antes do código força um design mais simples e focado

- Testes parametrizados evitam repetição e aumentam cobertura de cenários facilitando muito a não repetição de códigos de testes, reduzindo linhas.

- Comparação de floats requer atenção (use pytest.approx)

- Exceções devem ser testadas explicitamente com pytest.raises

- A escolha entre exceções nativas ou personalizadas impacta a legibilidade do código

## Desenvolvido por:
- Arlen Freitas - Squad 3