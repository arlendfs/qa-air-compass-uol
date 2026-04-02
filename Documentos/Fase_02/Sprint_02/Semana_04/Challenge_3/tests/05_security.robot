*** Settings ***
Documentation    Security suite — invalid/missing tokens, unauthorized access, and injection payloads.
Resource    ../resources/common.resource
Resource    ../services/auth_service.resource
Resource    ../services/user_service.resource
Resource    ../services/product_service.resource
Resource    ../services/cart_service.resource
Resource    ../utils/data_loader.resource
Resource    ../utils/retry.resource
Resource    ../utils/logger.resource
Suite Setup      Security Suite Setup
Suite Teardown   Delete All Sessions
Test Tags        security    regression


*** Variables ***
${INVALID_TOKEN}    Bearer token_invalido_xyz_123
${EMPTY_TOKEN}      ${EMPTY}


*** Test Cases ***
CT-SEC-01: Criar Produto Com Token Inválido Deve Retornar 401
    [Documentation]    A forged/expired token must be rejected with 401 on protected endpoints.
    [Tags]    token    negativo    critical
    Log Step    CT-SEC-01    Invalid token on POST /produtos
    ${payload}    Generate Dynamic Product Payload
    ${res}    Create Product
    ...    ${payload}[nome]    ${payload}[preco]    ${payload}[descricao]    ${payload}[quantidade]
    ...    ${INVALID_TOKEN}
    Assert Response Status    ${res}    401    CT-SEC-01

CT-SEC-02: Criar Produto Sem Token Deve Retornar 401
    [Documentation]    A request with no Authorization header must be rejected with 401.
    [Tags]    token    negativo    critical
    Log Step    CT-SEC-02    Missing token on POST /produtos
    ${payload}    Generate Dynamic Product Payload
    ${res}    Create Product
    ...    ${payload}[nome]    ${payload}[preco]    ${payload}[descricao]    ${payload}[quantidade]
    ...    ${EMPTY_TOKEN}
    Assert Response Status    ${res}    401    CT-SEC-02

CT-SEC-03: Criar Produto Com Token De Usuário Não-Admin Deve Retornar 403
    [Documentation]    A non-admin user token must be forbidden from creating products.
    [Tags]    authorization    negativo    critical
    Log Step    CT-SEC-03    Non-admin token on POST /produtos
    ${payload}    Generate Dynamic User Payload    valid_non_admin
    ${res_user}    Create User    ${payload}[nome]    ${payload}[email]    ${payload}[password]    false
    ${token_user}    Get Auth Token    ${payload}[email]    ${payload}[password]
    ${prod}    Generate Dynamic Product Payload
    ${res}    Create Product
    ...    ${prod}[nome]    ${prod}[preco]    ${prod}[descricao]    ${prod}[quantidade]
    ...    ${token_user}
    Assert Response Status    ${res}    403    CT-SEC-03
    [Teardown]    Delete User By ID    ${res_user.json()['_id']}

CT-SEC-04: Deletar Produto Com Token Inválido Deve Retornar 401
    [Documentation]    DELETE /produtos/{id} with a forged token must return 401.
    [Tags]    token    negativo
    Log Step    CT-SEC-04    Invalid token on DELETE /produtos
    ${res}    Delete Product By ID    id_qualquer    ${INVALID_TOKEN}
    Assert Response Status    ${res}    401    CT-SEC-04

CT-SEC-05: Checkout Com Token Inválido Deve Retornar 401
    [Documentation]    DELETE /carrinhos/concluir-compra with a forged token must return 401.
    [Tags]    token    negativo    critical
    Log Step    CT-SEC-05    Invalid token on checkout
    ${res}    Checkout Cart    ${INVALID_TOKEN}
    Assert Response Status    ${res}    401    CT-SEC-05

CT-SEC-06: Cancelar Carrinho Com Token Inválido Deve Retornar 401
    [Documentation]    DELETE /carrinhos/cancelar-compra with a forged token must return 401.
    [Tags]    token    negativo
    Log Step    CT-SEC-06    Invalid token on cancel cart
    ${res}    Cancel Cart    ${INVALID_TOKEN}
    Assert Response Status    ${res}    401    CT-SEC-06

CT-SEC-07: Login Com SQL Injection Não Deve Autenticar
    [Documentation]    SQL injection payload must not bypass authentication — expects 400 or 401.
    [Tags]    injection    negativo    critical
    Log Step    CT-SEC-07    SQL injection on POST /login
    ${data}    Get Test Data Field    login.json    sql_injection
    ${res}    Login User    ${data}[email]    ${data}[password]
    Should Be True    ${res.status_code} in [400, 401]
    ...    msg=SQL injection must not return 200. Got: ${res.status_code}

CT-SEC-08: Login Com XSS Payload Não Deve Autenticar
    [Documentation]    XSS payload in email field must be rejected — expects 400.
    [Tags]    injection    negativo    critical
    Log Step    CT-SEC-08    XSS payload on POST /login
    ${data}    Get Test Data Field    login.json    xss_payload
    ${res}    Login User    ${data}[email]    ${data}[password]
    Assert Response Status    ${res}    400    CT-SEC-08

CT-SEC-09: Cadastrar Usuário Com Nome Contendo SQL Injection
    [Documentation]    SQL injection in the name field must be stored safely or rejected — must never return 500.
    [Tags]    injection    negativo
    Log Step    CT-SEC-09    SQL injection in user name
    ${data}    Get Test Data Field    users.json    sql_injection_name
    ${email}    Gerar Email Aleatório
    ${res}    Create User    ${data}[nome]    ${email}    ${data}[password]    ${data}[administrador]
    Should Be True    ${res.status_code} in [201, 400]
    ...    msg=SQL injection in name must not cause a 500. Got: ${res.status_code}
    IF    ${res.status_code} == 201
        Delete User By ID    ${res.json()['_id']}
    END

CT-SEC-10: Cadastrar Usuário Com Nome Contendo XSS Payload
    [Documentation]    XSS payload in the name field must be stored safely or rejected — must never return 500.
    [Tags]    injection    negativo
    Log Step    CT-SEC-10    XSS payload in user name
    ${data}    Get Test Data Field    users.json    xss_payload_name
    ${email}    Gerar Email Aleatório
    ${res}    Create User    ${data}[nome]    ${email}    ${data}[password]    ${data}[administrador]
    Should Be True    ${res.status_code} in [201, 400]
    ...    msg=XSS payload in name must not cause a 500. Got: ${res.status_code}
    IF    ${res.status_code} == 201
        ${body}    Set Variable    ${res.json()}
        Should Not Contain    str(${body})    <script>
        ...    msg=XSS payload was stored unescaped in the response body.
        Delete User By ID    ${res.json()['_id']}
    END

CT-SEC-11: Acessar Usuário Inexistente Deve Retornar 400
    [Documentation]    GET /usuarios/{id} with a non-existent ID must return 400.
    [Tags]    negativo
    Log Step    CT-SEC-11    Non-existent user ID
    ${res}    Get User By ID    id_inexistente_000
    Assert Response Status    ${res}    400    CT-SEC-11

CT-SEC-12: Acessar Produto Inexistente Deve Retornar 400
    [Documentation]    GET /produtos/{id} with a non-existent ID must return 400.
    [Tags]    negativo
    Log Step    CT-SEC-12    Non-existent product ID
    ${res}    Get Product By ID    id_inexistente_000
    Assert Response Status    ${res}    400    CT-SEC-12


*** Keywords ***
Security Suite Setup
    Log Suite Banner    Security Suite — Token, Authorization & Injection
    Create Authenticated Session
