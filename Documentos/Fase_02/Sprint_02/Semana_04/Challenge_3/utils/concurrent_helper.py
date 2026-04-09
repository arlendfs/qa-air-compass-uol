"""
concurrent_helper.py — biblioteca Robot Framework para requisições HTTP concorrentes.
Usada pelo CT-55 em 06_edge_cases.robot.
"""
import concurrent.futures
import requests


def post_usuario_concorrente(base_url, emails, verify_ssl=False):
    """
    Dispara POST /usuarios em paralelo para cada email da lista.
    Retorna lista de status codes inteiros.
    """
    def _post(email):
        body = {
            "nome": "Concurrent User",
            "email": email,
            "password": "teste123",
            "administrador": "false"
        }
        res = requests.post(
            f"{base_url}/usuarios",
            json=body,
            verify=verify_ssl,
            timeout=10
        )
        return res.status_code

    with concurrent.futures.ThreadPoolExecutor(max_workers=len(emails)) as pool:
        resultados = list(pool.map(_post, emails))

    return resultados
