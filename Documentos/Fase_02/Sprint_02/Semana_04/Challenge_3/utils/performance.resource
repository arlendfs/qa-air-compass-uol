*** Settings ***
Documentation    Keywords de performance — medição de tempo de resposta e asserções de SLA.
Library    Collections
Resource    ../resources/common.resource


*** Keywords ***
Obter Elapsed Ms
    [Documentation]    Extrai o tempo de resposta em ms de um objeto Response do RequestsLibrary.
    [Arguments]    ${res}
    ${elapsed_ms}    Evaluate    round($res.elapsed.total_seconds() * 1000, 1)
    RETURN    ${elapsed_ms}

Validar SLA
    [Documentation]    Falha se o tempo de resposta exceder o threshold definido.
    ...                Loga o resultado independente de passar ou falhar.
    [Arguments]    ${elapsed_ms}    ${threshold_ms}    ${label}
    Log    [SLA] ${label} — ${elapsed_ms} ms (limite: ${threshold_ms} ms)    INFO
    Should Be True    ${elapsed_ms} <= ${threshold_ms}
    ...    msg=[SLA VIOLADO] ${label}: ${elapsed_ms} ms > ${threshold_ms} ms

Validar SLA Lista
    [Documentation]    Valida SLA para cada item de uma lista de dicts {elapsed_ms, status}.
    ...                Loga min, max e média. Falha se qualquer item violar o threshold.
    [Arguments]    ${resultados}    ${threshold_ms}    ${label}
    ${tempos}    Create List
    FOR    ${item}    IN    @{resultados}
        ${ms}    Get From Dictionary    ${item}    elapsed_ms
        Append To List    ${tempos}    ${ms}
    END
    ${min_ms}    Evaluate    min($tempos)
    ${max_ms}    Evaluate    max($tempos)
    ${avg_ms}    Evaluate    round(sum($tempos) / len($tempos), 1)
    Log    [SLA] ${label} — min: ${min_ms} ms | max: ${max_ms} ms | avg: ${avg_ms} ms (limite: ${threshold_ms} ms)    INFO
    FOR    ${ms}    IN    @{tempos}
        Should Be True    ${ms} <= ${threshold_ms}
        ...    msg=[SLA VIOLADO] ${label}: ${ms} ms > ${threshold_ms} ms
    END
