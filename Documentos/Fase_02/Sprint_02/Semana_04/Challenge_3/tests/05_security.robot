*** Settings ***
Documentation    Suite de testes de Segurança — cobre autenticação, autorização e resistência a payloads maliciosos.
# Foco: garantir que a API não vaza informações, não escala privilégios e não retorna 500 para inputs adversariais.
Resource    ../resources/common.resource
Resource    ../resources/security.resource
Suite Setup      Inicializar Suite De Segurança
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-40: Acessar /usuarios Sem Token
    [Documentation]    GET /usuarios sem Authorization deve retornar 200 — endpoint público no ServeRest.
    ...                Documenta que a listagem de usuários não requer autenticação (risco de exposição de dados).
    [Tags]    segurança    autenticação    positivo
    Quando Acesso Usuarios Sem Token
    Então A API Deve Aceitar Endpoint Público

CT-41: Acessar /produtos Com Token Inválido
    [Documentation]    POST /produtos com token Bearer forjado deve retornar 401.
    [Tags]    segurança    autenticação    negativo
    Quando Acesso Produtos Com Token Inválido
    Então A API Deve Retornar Não Autorizado

CT-42: Criar Produto Sem Token
    [Documentation]    POST /produtos sem header Authorization deve retornar 401.
    [Tags]    segurança    autenticação    negativo
    Quando Crio Produto Sem Token
    Então A API Deve Retornar Não Autorizado

CT-43: Atualizar Usuário De Outro Usuário
    [Documentation]    Usuário não-admin tenta PUT /usuarios/{id_admin} com seu próprio token.
    ...                ServeRest não implementa isolamento de ownership — documenta o comportamento atual.
    [Tags]    segurança    autorização
    Dado Que Existe Um Usuário Não Admin Provisionado
    Quando Atualizo Usuário De Outro Com Token Próprio    ${ID_ADMIN}    ${TOKEN_NAO_ADMIN}
    Então A API Deve Bloquear Ou Aceitar Sem Escalar Privilégio

CT-44: Deletar Produto De Outro Usuário
    [Documentation]    Usuário não-admin tenta DELETE /produtos/{id} — deve retornar 403.
    [Tags]    segurança    autorização    negativo
    Dado Que Existe Um Usuário Não Admin Provisionado
    Quando Deleto Produto Com Token De Não Admin    ${ID_PRODUTO_SEC}    ${TOKEN_NAO_ADMIN}
    Então A API Deve Retornar Proibido

CT-45: SQL Injection No Campo Email
    [Documentation]    POST /login com payload SQL injection no campo email não deve retornar 500.
    ...                Comportamento esperado: 400 (validação de formato) ou 401 (credencial inválida).
    [Tags]    segurança    injeção    negativo
    Quando Envio SQL Injection No Campo Email
    Então A API Não Deve Retornar Erro Interno

CT-46: XSS Payload No Campo Nome
    [Documentation]    POST /usuarios com script XSS no campo nome não deve retornar 500.
    ...                Documenta se a API sanitiza ou rejeita o payload.
    [Tags]    segurança    injeção    negativo
    Quando Envio XSS Payload No Campo Nome
    Então A API Não Deve Retornar Erro Interno

CT-47: JSON Injection Na Requisição
    [Documentation]    POST /login com campos extras (__proto__, role, admin) não deve retornar 500.
    ...                Documenta resistência a prototype pollution e escalada de privilégio via JSON.
    [Tags]    segurança    injeção    negativo
    Quando Envio JSON Injection Na Requisição
    Então A API Não Deve Retornar Erro Interno


*** Keywords ***
# ── Setup da suite ────────────────────────────────────────────────────────────

Inicializar Suite De Segurança
    [Documentation]    Cria sessão, obtém token de admin e provisiona produto para testes de autorização.
    # TOKEN_ADMIN e ID_ADMIN expostos como variáveis de suite para CT-43 e CT-44.
    Criar Sessão ServeRest
    ${token}    Pegar Token de Autenticação
    Set Suite Variable    ${TOKEN_ADMIN}    ${token}
    # Obtém o ID do admin via GET /usuarios com params= para evitar que o = no query string
    # seja interpretado pelo Robot Framework como argumento nomeado.
    ${params}     Create Dictionary    email=${ADMIN_EMAIL}
    ${res_user}   GET On Session    serverest    /usuarios
    ...    params=${params}    expected_status=any    verify=${VERIFY_SSL}
    ${lista}      Get From Dictionary    ${res_user.json()}    usuarios
    ${admin}      Set Variable    ${lista}[0]
    ${id_admin}   Get From Dictionary    ${admin}    _id
    Set Suite Variable    ${ID_ADMIN}    ${id_admin}
    Provisionar Produto Com Token Admin    ${TOKEN_ADMIN}

# ── Dado (Given) — pré-condições específicas desta suite ─────────────────────

Dado Que Existe Um Usuário Não Admin Provisionado
    [Documentation]    Cria usuário não-admin, faz login e expõe ${TOKEN_NAO_ADMIN} como variável de teste.
    Provisionar Usuário Não Admin
    ${token}    Pegar Token de Autenticação    ${EMAIL_NAO_ADMIN}    ${PASSWORD_NAO_ADMIN}
    Set Test Variable    ${TOKEN_NAO_ADMIN}    ${token}
