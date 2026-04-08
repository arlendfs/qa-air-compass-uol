*** Settings ***
Documentation    Suite de testes de Login — valida fluxos positivo, negativos, contrato e edge cases do endpoint POST /login.
Resource    ../resources/common.resource
Resource    ../resources/login_page.resource
Suite Setup      Criar Sessão ServeRest
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-01: Login Com Credenciais Válidas
    [Documentation]    Dado credenciais válidas, o login deve retornar 200 e um token de autorização.
    [Tags]    login    positivo    smoke
    Given Que A Sessão ServeRest Está Ativa
    When Realizo Login Com    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Then Então O Login Deve Ser Bem-Sucedido    ${res}

CT-02: Login Com Senha Inválida
    [Documentation]    Dado uma senha incorreta, o login deve retornar 401 com mensagem de erro.
    [Tags]    login    negativo
    Given Que A Sessão ServeRest Está Ativa
    When Realizo Login Com    ${ADMIN_EMAIL}    senha_incorreta
    Then Então O Login Deve Falhar Com Status    ${res}    401    Email e/ou senha inválidos

CT-03: Login Com Email Em Formato Inválido
    [Documentation]    Dado um email sem formato válido, o login deve retornar 400 com mensagem de validação.
    [Tags]    login    negativo
    Given Que A Sessão ServeRest Está Ativa
    When Realizo Login Com    email_invalido    ${ADMIN_PASSWORD}
    Then Então O Login Deve Falhar Com Status    ${res}    400    email deve ser um email válido    email

CT-04: Login Com Email Vazio
    [Documentation]    Dado o campo email enviado como string vazia, o login deve retornar 400 com mensagem de validação.
    [Tags]    login    negativo
    Given Que A Sessão ServeRest Está Ativa
    When Realizo Login Com    ${EMPTY}    ${ADMIN_PASSWORD}
    Then Então O Login Deve Falhar Com Status    ${res}    400    email não pode ficar em branco    email

CT-05: Login Com Password Vazio
    [Documentation]    Dado o campo password enviado como string vazia, o login deve retornar 400 com mensagem de validação.
    [Tags]    login    negativo
    Given Que A Sessão ServeRest Está Ativa
    When Realizo Login Com    ${ADMIN_EMAIL}    ${EMPTY}
    Then Então O Login Deve Falhar Com Status    ${res}    400    password não pode ficar em branco    password

CT-06: Contrato De Login - Campos Obrigatórios
    [Documentation]    A resposta 200 deve conter exatamente os campos message e authorization, com authorization iniciando com "Bearer".
    [Tags]    login    contrato
    Given Que A Sessão ServeRest Está Ativa
    When Realizo Login Com    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Then Então O Contrato De Login Deve Estar Correto    ${res}

CT-07: Login Com JSON Malformado
    [Documentation]    Dado um body que não é JSON válido, a API deve retornar 400 ou rejeitar a requisição sem erro 500.
    [Tags]    login    negativo    edge
    Given Que A Sessão ServeRest Está Ativa
    When Realizo Login Com Body Raw    {email: sem_aspas, password}
    Then O Status Não Deve Ser 500    ${res}


*** Keywords ***
# Alias Given para tornar os test cases legíveis sem duplicar lógica
Que A Sessão ServeRest Está Ativa
    Log    Sessão ServeRest ativa.

# Captura o retorno de "Quando Realizo Login Com" na variável ${res} para uso no Then
When Realizo Login Com
    [Arguments]    ${email}    ${password}
    ${res}    Quando Realizo Login Com    ${email}    ${password}
    Set Test Variable    ${res}

# Captura o retorno de "Quando Realizo Login Com Body Raw" na variável ${res} para uso no Then
When Realizo Login Com Body Raw
    [Arguments]    ${raw_body}
    ${res}    Quando Realizo Login Com Body Raw    ${raw_body}
    Set Test Variable    ${res}

# Asserção de CT-07: garante que a API não explodiu com 500 (comportamento defensivo)
O Status Não Deve Ser 500
    [Arguments]    ${res}
    Should Not Be Equal As Integers    ${res.status_code}    500
    Log    Status retornado para body malformado: ${res.status_code}
