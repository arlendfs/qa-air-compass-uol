*** Settings ***
Documentation    Suite de testes de Edge Cases — cobre boundary values, unicode, limites numéricos,
...              carrinho multi-item e comportamento sob requisições concorrentes.
Library    String
Library    Collections
Library    ../utils/concurrent_helper.py
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Resource    ../resources/prod_page.resource
Resource    ../resources/cart_page.resource
Suite Setup      Inicializar Suite De Edge Cases
Suite Teardown   Delete All Sessions


*** Variables ***
${NOME_500_CHARS}    ${EMPTY}
${TOKEN_EDGE}        ${EMPTY}


*** Test Cases ***
CT-EDG-01: Buscar Usuário Com ID Muito Longo
    [Documentation]    GET /usuarios/{id} com string de 500 chars não deve retornar 500.
    ...                Documenta comportamento defensivo da API para IDs excessivamente longos.
    [Tags]    edge    usuarios    negativo
    ${id_longo}    Generate Random String    length=500    chars=[LETTERS][NUMBERS]
    ${res}    Pesquisar Usuário Por ID    ${id_longo}
    Log    [CT-EDG-01 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Should Not Be Equal As Integers    ${res.status_code}    500

CT-EDG-02: Cadastrar Usuário Com Nome Muito Longo (500 chars)
    [Documentation]    POST /usuarios com nome de 500 caracteres — documenta se a API aceita ou rejeita.
    ...                Comportamento esperado: 400 (validação de tamanho) ou 201 (sem limite definido).
    [Tags]    edge    usuarios    negativo
    ${email}    Gerar Email Aleatório
    ${res}    Cadastrar Usuário    ${NOME_500_CHARS}    ${email}    teste123
    Log    [CT-EDG-02 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Should Not Be Equal As Integers    ${res.status_code}    500
    IF    ${res.status_code} == 201
        Log    OBSERVAÇÃO: API aceitou nome de 500 chars — sem limite de tamanho definido.    WARN
    ELSE IF    ${res.status_code} == 400
        Log    API rejeitou nome de 500 chars com 400 — validação de tamanho presente.    INFO
    END

CT-EDG-03: Cadastrar Usuário Com Unicode E Emoji No Nome
    [Documentation]    POST /usuarios com nome contendo unicode e emoji — API não deve retornar 500.
    ...                Documenta se a API sanitiza, aceita ou rejeita caracteres especiais.
    [Tags]    edge    usuarios    negativo
    ${email}    Gerar Email Aleatório
    ${res}    Cadastrar Usuário    Ärlen Ñoño 🚀✅    ${email}    teste123
    Log    [CT-EDG-03 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Should Not Be Equal As Integers    ${res.status_code}    500
    IF    ${res.status_code} == 201
        Log    API aceitou unicode/emoji no nome — Status: 201.    INFO
    ELSE
        Log    API rejeitou unicode/emoji — Status: ${res.status_code} | Body: ${res.text}    WARN
    END

CT-EDG-04: Criar Produto Com Preço Zero
    [Documentation]    POST /produtos com preco=0 — documenta se a API aceita ou rejeita preço zero.
    ...                Comportamento esperado: 400 (preço deve ser positivo) ou 201 (zero permitido).
    [Tags]    edge    produtos    negativo
    ${nome}    Gerar Nome Único    prefixo=Produto Preco Zero
    ${res}    Cadastrar Produto    ${nome}    ${0}    Produto com preco zero    ${10}    ${TOKEN_EDGE}
    Log    [CT-EDG-04 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Should Not Be Equal As Integers    ${res.status_code}    500
    IF    ${res.status_code} == 201
        Log    OBSERVAÇÃO: API aceitou preco=0 — comportamento permissivo documentado.    WARN
    ELSE IF    ${res.status_code} == 400
        Log    API rejeitou preco=0 com 400 — validação de valor mínimo presente.    INFO
    END

CT-EDG-05: Criar Produto Com Quantidade Zero
    [Documentation]    POST /produtos com quantidade=0 — produto com estoque zerado deve ser aceito.
    ...                ServeRest permite quantidade=0 (produto sem estoque disponível).
    [Tags]    edge    produtos    positivo
    ${nome}    Gerar Nome Único    prefixo=Produto Qtd Zero
    ${res}    Cadastrar Produto    ${nome}    ${100}    Produto sem estoque    ${0}    ${TOKEN_EDGE}
    Log    [CT-EDG-05 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Should Not Be Equal As Integers    ${res.status_code}    500
    IF    ${res.status_code} == 201
        Log    API aceitou quantidade=0 — produto criado com estoque zerado.    INFO
    ELSE IF    ${res.status_code} == 400
        Log    OBSERVAÇÃO: API rejeitou quantidade=0 — validação mais restritiva que o esperado.    WARN
    END

CT-EDG-06: Criar Produto Com Preço Máximo
    [Documentation]    POST /produtos com preco=999999999 — documenta o limite superior aceito pela API.
    [Tags]    edge    produtos    positivo
    ${nome}    Gerar Nome Único    prefixo=Produto Preco Max
    ${res}    Cadastrar Produto    ${nome}    ${999999999}    Produto com preco maximo    ${1}    ${TOKEN_EDGE}
    Log    [CT-EDG-06 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Should Not Be Equal As Integers    ${res.status_code}    500
    IF    ${res.status_code} == 201
        Log    API aceitou preco=999999999 — sem limite superior definido.    INFO
    ELSE IF    ${res.status_code} == 400
        Log    API rejeitou preco=999999999 — limite superior de preço presente.    WARN
    END

CT-EDG-07: Carrinho Com Múltiplos Produtos (10 itens)
    [Documentation]    POST /carrinhos com 10 produtos distintos — valida que a API aceita múltiplos itens.
    ...                ServeRest suporta múltiplos produtos por carrinho em um único POST.
    [Tags]    edge    carrinho    positivo
    [Teardown]    Cancelar Carrinho Multi Se Existir
    ${ids}    Criar Dez Produtos    ${TOKEN_EDGE}
    ${res}    Criar Carrinho Com Multiplos Produtos    ${TOKEN_EDGE}    ${ids}
    Log    [CT-EDG-07 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Should Be Equal As Integers    ${res.status_code}    201
    Dictionary Should Contain Key    ${res.json()}    _id

CT-EDG-08: Requisições Concorrentes Para POST /usuarios
    [Documentation]    5 requisições POST /usuarios simultâneas com emails únicos — nenhuma deve retornar 500.
    ...                Concorrência gerenciada via ThreadPoolExecutor em concurrent_helper.py.
    [Tags]    edge    usuarios    concorrencia
    ${emails}    Gerar Lista De Emails    5
    ${status_list}    Post Usuario Concorrente    ${BASE_URL}    ${emails}
    Log    [CT-EDG-08 DEBUG] Status codes: ${status_list}    DEBUG
    FOR    ${status}    IN    @{status_list}
        Should Not Be Equal As Integers    ${status}    500
    END
    Log    Todas as ${status_list.__len__()} requisições concorrentes responderam sem erro 500.    INFO


*** Keywords ***
# ── Setup da suite ────────────────────────────────────────────────────────────

Inicializar Suite De Edge Cases
    [Documentation]    Cria sessão, garante admin e prepara fixtures para a suite.
    Criar Sessão ServeRest
    Garantir Admin Existe
    ${token}    Pegar Token de Autenticação
    Set Suite Variable    ${TOKEN_EDGE}    ${token}
    ${nome_longo}    Generate Random String    length=500    chars=[LETTERS][NUMBERS]
    Set Suite Variable    ${NOME_500_CHARS}    ${nome_longo}

# ── Quando (When) — ações específicas desta suite ─────────────────────────────

Criar Dez Produtos
    [Documentation]    Cria 10 produtos distintos e retorna lista de IDs para CT-EDG-07.
    [Arguments]    ${token}
    ${ids}    Create List
    FOR    ${i}    IN RANGE    10
        ${nome}    Gerar Nome Único    prefixo=Edge Multi ${i}
        ${res}     Cadastrar Produto    ${nome}    ${10}    Produto multi-carrinho    ${2}    ${token}
        Should Be Equal As Integers    ${res.status_code}    201
        Append To List    ${ids}    ${res.json()['_id']}
    END
    RETURN    ${ids}

Criar Carrinho Com Multiplos Produtos
    [Documentation]    Envia POST /carrinhos com lista de 10 produtos, 1 unidade cada.
    [Arguments]    ${token}    ${ids}
    ${headers}    Create Dictionary    Authorization=${token}
    ${produtos}   Create List
    FOR    ${id}    IN    @{ids}
        ${item}    Create Dictionary    idProduto=${id}    quantidade=${1}
        Append To List    ${produtos}    ${item}
    END
    ${body}    Create Dictionary    produtos=${produtos}
    ${res}    POST On Session    serverest    /carrinhos    json=${body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Gerar Lista De Emails
    [Documentation]    Gera uma lista de N emails únicos para uso no CT-EDG-08.
    [Arguments]    ${n}
    ${emails}    Create List
    FOR    ${i}    IN RANGE    ${n}
        ${email}    Gerar Email Aleatório
        Append To List    ${emails}    ${email}
    END
    RETURN    ${emails}

# ── Teardown helpers ──────────────────────────────────────────────────────────

Cancelar Carrinho Multi Se Existir
    [Documentation]    Cancela o carrinho multi-produto criado no CT-EDG-07.
    ${headers}    Create Dictionary    Authorization=${TOKEN_EDGE}
    DELETE On Session    serverest    /carrinhos/cancelar-compra
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
