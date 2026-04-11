*** Settings ***
Documentation    Suite de testes de Performance — valida SLA de tempo de resposta e comportamento
...              sob carga concorrente dos principais endpoints do ServeRest.
...
...              SLAs definidos:
...                CT-PER-01  GET  /usuarios              < 1000 ms
...                CT-PER-02  POST /login                 < 300 ms
...                CT-PER-03  GET  /produtos              < 400 ms
...                CT-PER-04  POST /usuarios  x5 paralelo < 2000 ms cada
...                CT-PER-05  DELETE /carrinhos/concluir  x3 paralelo < 1500 ms cada
Library    Collections
Library    ../utils/concurrent_helper.py
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Resource    ../resources/prod_page.resource
Resource    ../resources/cart_page.resource
Resource    ../utils/performance.resource
Suite Setup      Inicializar Suite De Performance
Suite Teardown   Delete All Sessions


*** Variables ***
${SLA_USUARIOS_MS}     1000
${SLA_LOGIN_MS}        300
${SLA_PRODUTOS_MS}     400
${SLA_CONCURRENT_MS}   2000
${SLA_DELETE_MS}       1500
${TOKEN_PERF}          ${EMPTY}
${ID_PRODUTO_PERF}     ${EMPTY}


*** Test Cases ***
CT-PER-01: GET /usuarios Response Time < 500ms
    [Documentation]    GET /usuarios deve responder em menos de ${SLA_USUARIOS_MS} ms.
    ...                Mede o tempo real de resposta via res.elapsed do requests.
    [Tags]    performance    usuarios    sla
    ${res}    GET On Session    serverest    /usuarios
    ...    expected_status=any    verify=${VERIFY_SSL}
    Should Be Equal As Integers    ${res.status_code}    200
    ${elapsed_ms}    Obter Elapsed Ms    ${res}
    Validar SLA    ${elapsed_ms}    ${SLA_USUARIOS_MS}    GET /usuarios

CT-PER-02: POST /login Response Time < 300ms
    [Documentation]    POST /login deve responder em menos de ${SLA_LOGIN_MS} ms.
    ...                Executa 3 amostras e valida que todas ficam dentro do SLA.
    [Tags]    performance    login    sla
    FOR    ${i}    IN RANGE    3
        &{body}    Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASSWORD}
        ${res}    POST On Session    serverest    /login    json=${body}
        ...    expected_status=any    verify=${VERIFY_SSL}
        Should Be Equal As Integers    ${res.status_code}    200
        ${elapsed_ms}    Obter Elapsed Ms    ${res}
        Validar SLA    ${elapsed_ms}    ${SLA_LOGIN_MS}    POST /login amostra ${i+1}
    END

CT-PER-03: GET /produtos Response Time < 400ms
    [Documentation]    GET /produtos deve responder em menos de ${SLA_PRODUTOS_MS} ms.
    ...                Executa 3 amostras e valida que todas ficam dentro do SLA.
    [Tags]    performance    produtos    sla
    FOR    ${i}    IN RANGE    3
        ${res}    GET On Session    serverest    /produtos
        ...    expected_status=any    verify=${VERIFY_SSL}
        Should Be Equal As Integers    ${res.status_code}    200
        ${elapsed_ms}    Obter Elapsed Ms    ${res}
        Validar SLA    ${elapsed_ms}    ${SLA_PRODUTOS_MS}    GET /produtos amostra ${i+1}
    END

CT-PER-04: POST /usuarios Concurrent (5 users)
    [Documentation]    5 requisições POST /usuarios simultâneas devem responder em menos de
    ...                ${SLA_CONCURRENT_MS} ms cada. Valida status e tempo de todas as threads.
    [Tags]    performance    usuarios    concorrencia    sla
    ${emails}    Gerar Lista De Emails Perf    5
    ${resultados}    Post Usuario Concorrente Com Tempo    ${BASE_URL}    ${emails}
    Log    [CT-PER-04] Resultados concorrentes: ${resultados}    INFO
    FOR    ${item}    IN    @{resultados}
        ${status}    Get From Dictionary    ${item}    status
        Should Not Be Equal As Integers    ${status}    500
    END
    Validar SLA Lista    ${resultados}    ${SLA_CONCURRENT_MS}    POST /usuarios x5 concurrent

CT-PER-05: DELETE /carrinhos/concluir-compra Under Load
    [Documentation]    3 usuários distintos com carrinhos ativos executam DELETE /carrinhos/concluir-compra
    ...                simultaneamente. Cada resposta deve chegar em menos de ${SLA_DELETE_MS} ms.
    [Tags]    performance    carrinho    concorrencia    sla
    ${tokens}    Provisionar Usuarios Com Carrinhos    3
    ${resultados}    Delete Concluir Compra Com Tempo    ${BASE_URL}    ${tokens}
    Log    [CT-PER-05] Resultados concorrentes: ${resultados}    INFO
    FOR    ${item}    IN    @{resultados}
        ${status}    Get From Dictionary    ${item}    status
        Should Be Equal As Integers    ${status}    200
    END
    Validar SLA Lista    ${resultados}    ${SLA_DELETE_MS}    DELETE /carrinhos/concluir-compra x3 concurrent


*** Keywords ***
# ── Setup da suite ────────────────────────────────────────────────────────────

Inicializar Suite De Performance
    [Documentation]    Cria sessão, garante admin e provisiona produto fixture para CT-PER-05.
    Criar Sessão ServeRest
    Garantir Admin Existe
    ${token}    Pegar Token de Autenticação
    Set Suite Variable    ${TOKEN_PERF}    ${token}
    ${nome}    Gerar Nome Único    prefixo=Perf Fixture
    ${res}     Cadastrar Produto    ${nome}    ${99}    Produto fixture perf    ${50}    ${token}
    Should Be Equal As Integers    ${res.status_code}    201
    Set Suite Variable    ${ID_PRODUTO_PERF}    ${res.json()['_id']}

# ── Helpers específicos desta suite ──────────────────────────────────────────

Gerar Lista De Emails Perf
    [Documentation]    Gera N emails únicos para uso nos testes de performance.
    [Arguments]    ${n}
    ${emails}    Create List
    FOR    ${i}    IN RANGE    ${n}
        ${email}    Gerar Email Aleatório
        Append To List    ${emails}    ${email}
    END
    RETURN    ${emails}

Provisionar Usuarios Com Carrinhos
    [Documentation]    Cria N usuários não-admin, faz login para cada um e cria um carrinho ativo.
    ...                Retorna lista de tokens Bearer prontos para o DELETE concorrente do CT-PER-05.
    [Arguments]    ${n}
    ${tokens}    Create List
    FOR    ${i}    IN RANGE    ${n}
        ${email}      Gerar Email Aleatório
        &{body_user}  Create Dictionary
        ...    nome=Perf Load User ${i}    email=${email}
        ...    password=teste123    administrador=false
        ${res_user}   POST On Session    serverest    /usuarios    json=${body_user}
        ...    expected_status=any    verify=${VERIFY_SSL}
        Should Be Equal As Integers    ${res_user.status_code}    201
        ${token_user}    Pegar Token de Autenticação    ${email}    teste123
        ${headers}    Create Dictionary    Authorization=${token_user}
        ${item}       Create Dictionary    idProduto=${ID_PRODUTO_PERF}    quantidade=${1}
        ${produtos}   Create List    ${item}
        ${body_cart}  Create Dictionary    produtos=${produtos}
        ${res_cart}   POST On Session    serverest    /carrinhos    json=${body_cart}
        ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
        Should Be Equal As Integers    ${res_cart.status_code}    201
        Append To List    ${tokens}    ${token_user}
    END
    RETURN    ${tokens}
