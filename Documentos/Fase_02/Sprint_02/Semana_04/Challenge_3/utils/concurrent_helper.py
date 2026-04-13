"""
concurrent_helper.py — biblioteca Robot Framework para requisições HTTP concorrentes.
Usada por 06_edge_cases.robot e 07_performance.robot.
"""
import concurrent.futures
import time
import requests


def post_usuario_concorrente(base_url, emails, verify_ssl=False):
    """
    Dispara POST /usuarios em paralelo para cada email da lista.
    Retorna lista de status codes inteiros.
    Usada pelo CT-55 (edge cases).
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


def post_usuario_concorrente_com_tempo(base_url, emails, verify_ssl=False):
    """
    Dispara POST /usuarios em paralelo para cada email da lista.
    Retorna lista de dicts: [{"status": int, "elapsed_ms": float}]
    Usada pelo CT-59 (performance — concurrent POST /usuarios).
    """
    def _post(email):
        body = {
            "nome": "Perf Concurrent User",
            "email": email,
            "password": "teste123",
            "administrador": "false"
        }
        res = requests.post(
            f"{base_url}/usuarios",
            json=body,
            verify=verify_ssl,
            timeout=15
        )
        elapsed_ms = round(res.elapsed.total_seconds() * 1000, 1)
        return {"status": res.status_code, "elapsed_ms": elapsed_ms}

    with concurrent.futures.ThreadPoolExecutor(max_workers=len(emails)) as pool:
        resultados = list(pool.map(_post, emails))

    return resultados


def delete_concluir_compra_com_tempo(base_url, tokens, verify_ssl=False):
    """
    Dispara DELETE /carrinhos/concluir-compra em paralelo para cada token da lista.
    Retorna lista de dicts: [{"status": int, "elapsed_ms": float}]
    Usada pelo CT-60 (performance — DELETE /carrinhos/concluir-compra under load).
    """
    def _delete(token):
        headers = {"Authorization": token, "accept": "application/json"}
        res = requests.delete(
            f"{base_url}/carrinhos/concluir-compra",
            headers=headers,
            verify=verify_ssl,
            timeout=15
        )
        elapsed_ms = round(res.elapsed.total_seconds() * 1000, 1)
        return {"status": res.status_code, "elapsed_ms": elapsed_ms}

    with concurrent.futures.ThreadPoolExecutor(max_workers=len(tokens)) as pool:
        resultados = list(pool.map(_delete, tokens))

    return resultados
