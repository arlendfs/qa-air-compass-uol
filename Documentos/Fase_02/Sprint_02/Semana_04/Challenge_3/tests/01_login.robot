*** Settings ***
Documentation    Suite de testes de Login — valida fluxos positivo e negativos do endpoint POST /login.
Resource    ../resources/common.resource
Resource    ../resources/login_page.resource
Suite Setup      Criar Sessão ServeRest
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-01: Login Com Credenciais Válidas
    [Documentation]    Dado credenciais válidas, o login deve retornar 200 e um token de autorização.
    [Tags]    login    positivo
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


*** Keywords ***
# Alias Given para tornar os test cases legíveis sem duplicar lógica
Que A Sessão ServeRest Está Ativa
    Log    Sessão ServeRest ativa.

# Sobrescreve o retorno de "Quando Realizo Login Com" na variável ${res} para uso no Then
When Realizo Login Com
    [Arguments]    ${email}    ${password}
    ${res}    Quando Realizo Login Com    ${email}    ${password}
    Set Test Variable    ${res}
