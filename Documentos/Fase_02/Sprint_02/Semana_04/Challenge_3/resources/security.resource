*** Settings ***
Documentation    Keywords de segurança — ações e asserções para testes de autenticação, autorização e injeção.
Resource    common.resource
Resource    users_page.resource
Resource    prod_page.resource


*** Keywords ***
# ── Setup helpers — provisionamento de dados isolados ────────────────────────

Provisionar Usuário Não Admin
    [Documentation]    Cria um usuário não-admin e retorna email, password e id como variáveis de teste.
    # Usado como pré-condição em testes que precisam de um token de usuário comum.
    ${email}      Gerar Email Aleatório
    ${res}        Cadastrar Usuário    Usuario Seguranca    ${email}    teste123    false
    Should Be Equal As Integers    ${res.status_code}    201
    Set Test Variable    ${EMAIL_NAO_ADMIN}      ${email}
    Set Test Variable    ${PASSWORD_NAO_ADMIN}   teste123
    Set Test Variable    ${ID_NAO_ADMIN}         ${res.json()['_id']}

Provisionar Produto Com Token Admin
    [Documentation]    Cria um produto via admin e expõe ${ID_PRODUTO_SEC} como variável de suite.
    [Arguments]    ${token_admin}
    ${nome}    Gerar Nome Único    prefixo=Produto Sec
    ${res}     Cadastrar Produto    ${nome}    100    Produto para teste de segurança    10    ${token_admin}
    Should Be Equal As Integers    ${res.status_code}    201
    Set Suite Variable    ${ID_PRODUTO_SEC}    ${res.json()['_id']}

# ── Quando (When) — requisições sem autenticação ─────────────────────────────

Quando Acesso Usuarios Sem Token
    [Documentation]    Envia GET /usuarios sem header Authorization — endpoint público no ServeRest.
    # ServeRest: GET /usuarios é público (não requer token). Valida que retorna 200, não 401.
    ${headers}    Create Dictionary    accept=application/json
    ${res}    GET On Session    serverest    /usuarios
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-40 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_SEC}    ${res}

Quando Acesso Produtos Com Token Inválido
    [Documentation]    Envia POST /produtos com token Bearer forjado — deve retornar 401.
    ${headers}    Create Dictionary    Authorization=Bearer token_invalido_forjado_xyz
    ${nome}    Gerar Nome Único    prefixo=Produto Token Inv
    ${body}    Create Dictionary    nome=${nome}    preco=${100}    descricao=Teste    quantidade=${5}
    ${res}    POST On Session    serverest    /produtos    json=${body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-41 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_SEC}    ${res}

Quando Crio Produto Sem Token
    [Documentation]    Envia POST /produtos sem header Authorization — deve retornar 401.
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json
    ${nome}    Gerar Nome Único    prefixo=Produto Sem Token
    ${body}    Create Dictionary    nome=${nome}    preco=${100}    descricao=Teste    quantidade=${5}
    ${res}    POST On Session    serverest    /produtos    json=${body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-42 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_SEC}    ${res}

# ── Quando (When) — requisições com token de outro usuário ───────────────────

Quando Atualizo Usuário De Outro Com Token Próprio
    [Documentation]    Usuário não-admin tenta PUT /usuarios/{id_admin} com seu próprio token.
    # ServeRest: qualquer usuário autenticado pode chamar PUT /usuarios/{id}.
    # O teste documenta se a API aplica isolamento de ownership ou não.
    [Arguments]    ${id_alvo}    ${token_proprio}
    ${email_novo}    Gerar Email Aleatório
    ${body}    Create Dictionary
    ...    nome=Invasor Teste    email=${email_novo}    password=teste123    administrador=false
    ${headers}    Create Dictionary    Authorization=${token_proprio}
    ${res}    PUT On Session    serverest    /usuarios/${id_alvo}    json=${body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-43 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_SEC}    ${res}

Quando Deleto Produto Com Token De Não Admin
    [Documentation]    Usuário não-admin tenta DELETE /produtos/{id} — deve retornar 403.
    [Arguments]    ${id_produto}    ${token_nao_admin}
    ${headers}    Create Dictionary    Authorization=${token_nao_admin}
    ${res}    DELETE On Session    serverest    /produtos/${id_produto}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-44 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_SEC}    ${res}

# ── Quando (When) — payloads maliciosos ──────────────────────────────────────

Quando Envio SQL Injection No Campo Email
    [Documentation]    Envia POST /login com payload de SQL injection no campo email.
    # Objetivo: API não deve retornar 500 nem vazar stack trace.
    # Comportamento esperado: 400 (validação) ou 401 (credencial inválida).
    &{body}    Create Dictionary
    ...    email=' OR '1'='1'; --    password=qualquer
    ${res}    POST On Session    serverest    /login    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-45 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_SEC}    ${res}

Quando Envio XSS Payload No Campo Nome
    [Documentation]    Envia POST /usuarios com payload XSS no campo nome.
    # Objetivo: API não deve retornar 500 nem refletir o script na resposta sem sanitização.
    ${email}    Gerar Email Aleatório
    &{body}    Create Dictionary
    ...    nome=<script>alert('xss')</script>    email=${email}    password=teste123    administrador=false
    ${res}    POST On Session    serverest    /usuarios    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-46 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_SEC}    ${res}

Quando Envio JSON Injection Na Requisição
    [Documentation]    Envia POST /login com payload que tenta injetar campos extras no JSON.
    # Objetivo: API deve ignorar campos extras e não retornar 500.
    &{body}    Create Dictionary
    ...    email=${ADMIN_EMAIL}    password=${ADMIN_PASSWORD}
    ...    admin=true    __proto__={"isAdmin": true}    role=superuser
    ${res}    POST On Session    serverest    /login    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-47 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_SEC}    ${res}

# ── Então (Then) — asserções de segurança ────────────────────────────────────

Então A API Deve Retornar Não Autorizado
    [Documentation]    Valida que a API retornou 401 — token ausente ou inválido.
    [Arguments]    ${res}=${RESPOSTA_SEC}
    Should Be Equal As Integers    ${res.status_code}    401
    Log    [DEBUG] Body 401: ${res.text}    DEBUG

Então A API Deve Retornar Proibido
    [Documentation]    Valida que a API retornou 403 — autenticado mas sem permissão.
    [Arguments]    ${res}=${RESPOSTA_SEC}
    Should Be Equal As Integers    ${res.status_code}    403
    Log    [DEBUG] Body 403: ${res.text}    DEBUG

Então A API Não Deve Retornar Erro Interno
    [Documentation]    Valida que a API não retornou 500 para payload malicioso (comportamento defensivo).
    [Arguments]    ${res}=${RESPOSTA_SEC}
    Should Not Be Equal As Integers    ${res.status_code}    500
    Log    [DEBUG] Status para payload malicioso: ${res.status_code} | Body: ${res.text}    DEBUG

Então A API Deve Aceitar Endpoint Público
    [Documentation]    Valida que endpoint público retorna 200 sem token — GET /usuarios é aberto no ServeRest.
    [Arguments]    ${res}=${RESPOSTA_SEC}
    Should Be Equal As Integers    ${res.status_code}    200

Então A API Deve Bloquear Ou Aceitar Sem Escalar Privilégio
    [Documentation]    Valida que PUT de outro usuário não retornou 500 e documenta o comportamento de ownership.
    # ServeRest não implementa isolamento de ownership — qualquer token autenticado pode alterar qualquer usuário.
    # O teste documenta esse comportamento: se retornar 200, loga como observação de design; se 403, passou.
    [Arguments]    ${res}=${RESPOSTA_SEC}
    Should Not Be Equal As Integers    ${res.status_code}    500
    IF    ${res.status_code} == 200
        Log    OBSERVAÇÃO: ServeRest não implementa isolamento de ownership — PUT de outro usuário retornou 200.    WARN
    ELSE IF    ${res.status_code} == 403
        Log    API bloqueou corretamente a atualização de outro usuário — Status: 403.    INFO
    ELSE
        Log    Status inesperado para PUT de outro usuário: ${res.status_code} | Body: ${res.text}    WARN
    END
