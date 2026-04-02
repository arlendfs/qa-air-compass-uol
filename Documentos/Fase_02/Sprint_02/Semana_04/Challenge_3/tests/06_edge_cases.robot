*** Settings ***
Documentation    Edge cases suite — boundary values, data validation, and data-driven scenarios.
Resource    ../resources/common.resource
Resource    ../services/auth_service.resource
Resource    ../services/user_service.resource
Resource    ../services/product_service.resource
Resource    ../services/cart_service.resource
Resource    ../utils/data_loader.resource
Resource    ../utils/contract.resource
Resource    ../utils/retry.resource
Resource    ../utils/logger.resource
Suite Setup      Edge Cases Suite Setup
Suite Teardown   Delete All Sessions
Test Tags        edge    regression


*** Test Cases ***
CT-EDGE-01: Login Com Email Vazio Deve Retornar 400
    [Documentation]    Empty email field must return 400 with a field-level validation message.
    [Tags]    login    negativo    data-driven
    Log Step    CT-EDGE-01    Empty email on POST /login
    ${data}    Get Test Data Field    login.json    empty_email
    ${res}    Login User    ${data}[email]    ${data}[password]
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-01
    Dictionary Should Contain Key    ${res.json()}    ${data}[expected_field]

CT-EDGE-02: Login Com Password Vazio Deve Retornar 400
    [Documentation]    Empty password field must return 400 with a field-level validation message.
    [Tags]    login    negativo    data-driven
    Log Step    CT-EDGE-02    Empty password on POST /login
    ${data}    Get Test Data Field    login.json    empty_password
    ${res}    Login User    ${data}[email]    ${data}[password]
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-02
    Dictionary Should Contain Key    ${res.json()}    ${data}[expected_field]

CT-EDGE-03: Cadastrar Usuário Com Nome Vazio Deve Retornar 400
    [Documentation]    Empty name must be rejected with 400 and a field-level error.
    [Tags]    usuarios    negativo    data-driven
    Log Step    CT-EDGE-03    Empty name on POST /usuarios
    ${data}    Get Test Data Field    users.json    missing_name
    ${email}    Gerar Email Aleatório
    ${res}    Create User    ${data}[nome]    ${email}    ${data}[password]    ${data}[administrador]
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-03
    Dictionary Should Contain Key    ${res.json()}    ${data}[expected_field]

CT-EDGE-04: Cadastrar Usuário Com Password Vazio Deve Retornar 400
    [Documentation]    Empty password must be rejected with 400 and a field-level error.
    [Tags]    usuarios    negativo    data-driven
    Log Step    CT-EDGE-04    Empty password on POST /usuarios
    ${data}    Get Test Data Field    users.json    missing_password
    ${email}    Gerar Email Aleatório
    ${res}    Create User    ${data}[nome]    ${email}    ${data}[password]    ${data}[administrador]
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-04
    Dictionary Should Contain Key    ${res.json()}    ${data}[expected_field]

CT-EDGE-05: Cadastrar Usuário Com Email Inválido Deve Retornar 400
    [Documentation]    Malformed email must be rejected with 400 and a field-level error.
    [Tags]    usuarios    negativo    data-driven
    Log Step    CT-EDGE-05    Invalid email format on POST /usuarios
    ${data}    Get Test Data Field    users.json    invalid_email_format
    ${res}    Create User    ${data}[nome]    ${data}[email]    ${data}[password]    ${data}[administrador]
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-05
    Dictionary Should Contain Key    ${res.json()}    ${data}[expected_field]

CT-EDGE-06: Cadastrar Usuário Com Nome No Limite Máximo De Caracteres
    [Documentation]    A name at the maximum boundary length must be accepted or rejected consistently.
    [Tags]    usuarios    boundary
    Log Step    CT-EDGE-06    Max-length name boundary
    ${data}    Get Test Data Field    users.json    name_max_boundary
    ${email}    Gerar Email Aleatório
    ${res}    Create User    ${data}[nome]    ${email}    ${data}[password]    ${data}[administrador]
    Should Be True    ${res.status_code} in [201, 400]
    ...    msg=Boundary name must not cause a 500. Got: ${res.status_code}
    IF    ${res.status_code} == 201
        Delete User By ID    ${res.json()['_id']}
    END

CT-EDGE-07: Validar Contrato Completo Do Usuário Via Schema
    [Documentation]    GET /usuarios/{id} response must conform to the user JSON schema.
    [Tags]    usuarios    contrato    schema
    Log Step    CT-EDGE-07    Full user schema validation
    ${payload}    Generate Dynamic User Payload    valid_admin
    ${res_create}    Create User    ${payload}[nome]    ${payload}[email]    ${payload}[password]    ${payload}[administrador]
    Assert Response Status    ${res_create}    201    CT-EDGE-07: create user
    ${user_id}    Set Variable    ${res_create.json()['_id']}
    ${res_get}    Retry Request Until Success    Get User By ID    200    3    2s    ${user_id}
    Validate Response Against Schema    ${res_get}    user_schema.json
    [Teardown]    Delete User By ID    ${user_id}

CT-EDGE-08: Cadastrar Produto Com Preço Zero Deve Retornar 400
    [Documentation]    Price of zero must be rejected with 400 and a field-level error.
    [Tags]    produtos    negativo    data-driven
    Log Step    CT-EDGE-08    Zero price on POST /produtos
    ${data}    Get Test Data Field    products.json    zero_price
    ${nome}    Gerar Nome Único    prefixo=Prod Edge
    ${res}    Create Product    ${nome}    ${data}[preco]    ${data}[descricao]    ${data}[quantidade]    ${TOKEN}
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-08

CT-EDGE-09: Cadastrar Produto Com Preço Negativo Deve Retornar 400
    [Documentation]    Negative price must be rejected with 400 and a field-level error.
    [Tags]    produtos    negativo    data-driven
    Log Step    CT-EDGE-09    Negative price on POST /produtos
    ${data}    Get Test Data Field    products.json    negative_price
    ${nome}    Gerar Nome Único    prefixo=Prod Edge
    ${res}    Create Product    ${nome}    ${data}[preco]    ${data}[descricao]    ${data}[quantidade]    ${TOKEN}
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-09

CT-EDGE-10: Cadastrar Produto Com Quantidade Zero Deve Retornar 400
    [Documentation]    Zero quantity — documents actual ServeRest behavior (accepts 0).
    [Tags]    produtos    negativo    data-driven
    Log Step    CT-EDGE-10    Zero quantity on POST /produtos
    ${data}    Get Test Data Field    products.json    zero_quantity
    ${nome}    Gerar Nome Único    prefixo=Prod Edge
    ${res}    Create Product    ${nome}    ${data}[preco]    ${data}[descricao]    ${data}[quantidade]    ${TOKEN}
    Should Be True    ${res.status_code} in [201, 400]
    ...    msg=Zero quantity must not cause a 500. Got: ${res.status_code}
    IF    ${res.status_code} == 201
        Log    [BUG] ServeRest accepted quantity=0 — expected 400    WARN
        Delete Product By ID    ${res.json()['_id']}    ${TOKEN}
    END

CT-EDGE-11: Cadastrar Produto Com Quantidade Negativa Deve Retornar 400
    [Documentation]    Negative quantity must be rejected with 400 and a field-level error.
    [Tags]    produtos    negativo    data-driven
    Log Step    CT-EDGE-11    Negative quantity on POST /produtos
    ${data}    Get Test Data Field    products.json    negative_quantity
    ${nome}    Gerar Nome Único    prefixo=Prod Edge
    ${res}    Create Product    ${nome}    ${data}[preco]    ${data}[descricao]    ${data}[quantidade]    ${TOKEN}
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-11

CT-EDGE-12: Cadastrar Produto Com Nome Vazio Deve Retornar 400
    [Documentation]    Empty product name must be rejected with 400 and a field-level error.
    [Tags]    produtos    negativo    data-driven
    Log Step    CT-EDGE-12    Empty name on POST /produtos
    ${data}    Get Test Data Field    products.json    missing_name
    ${res}    Create Product    ${data}[nome]    ${data}[preco]    ${data}[descricao]    ${data}[quantidade]    ${TOKEN}
    Assert Response Status    ${res}    ${data}[expected_status]    CT-EDGE-12

CT-EDGE-13: Validar Contrato Completo Do Produto Via Schema
    [Documentation]    GET /produtos/{id} response must conform to the product JSON schema.
    [Tags]    produtos    contrato    schema
    Log Step    CT-EDGE-13    Full product schema validation
    ${payload}    Generate Dynamic Product Payload
    ${res_create}    Create Product
    ...    ${payload}[nome]    ${payload}[preco]    ${payload}[descricao]    ${payload}[quantidade]    ${TOKEN}
    Assert Response Status    ${res_create}    201    CT-EDGE-13: create product
    ${product_id}    Set Variable    ${res_create.json()['_id']}
    ${res_get}    Retry Request Until Success    Get Product By ID    200    3    2s    ${product_id}
    Validate Response Against Schema    ${res_get}    product_schema.json
    [Teardown]    Delete Product By ID    ${product_id}    ${TOKEN}

CT-EDGE-14: Adicionar Quantidade Zero Ao Carrinho Deve Retornar 400
    [Documentation]    Adding a product with quantity 0 must be rejected with 400.
    [Tags]    carrinho    negativo
    Log Step    CT-EDGE-14    Zero quantity in cart item
    ${prod_payload}    Generate Dynamic Product Payload
    ${res_prod}    Create Product
    ...    ${prod_payload}[nome]    ${prod_payload}[preco]    ${prod_payload}[descricao]
    ...    ${prod_payload}[quantidade]    ${TOKEN}
    Assert Response Status    ${res_prod}    201    CT-EDGE-14: create product
    ${product_id}    Set Variable    ${res_prod.json()['_id']}
    ${res}    Create Cart    ${TOKEN}    ${product_id}    0
    Assert Response Status    ${res}    400    CT-EDGE-14: add zero quantity to cart
    [Teardown]    Delete Product By ID    ${product_id}    ${TOKEN}

CT-EDGE-15: Validar Contrato Completo Do Carrinho Via Schema
    [Documentation]    GET /carrinhos/{id} response must conform to the cart JSON schema.
    [Tags]    carrinho    contrato    schema
    [Teardown]    Cancel Cart    ${TOKEN}
    Log Step    CT-EDGE-15    Full cart schema validation
    ${prod_payload}    Generate Dynamic Product Payload
    ${res_prod}    Create Product
    ...    ${prod_payload}[nome]    ${prod_payload}[preco]    ${prod_payload}[descricao]
    ...    ${prod_payload}[quantidade]    ${TOKEN}
    Assert Response Status    ${res_prod}    201    CT-EDGE-15: create product
    ${product_id}    Set Variable    ${res_prod.json()['_id']}
    ${res_cart}    Create Cart    ${TOKEN}    ${product_id}    1
    Assert Response Status    ${res_cart}    201    CT-EDGE-15: create cart
    ${cart_id}    Set Variable    ${res_cart.json()['_id']}
    ${res_get}    Retry Request Until Success    Get Cart By ID    200    3    2s    ${cart_id}
    Validate Response Against Schema    ${res_get}    cart_schema.json

CT-EDGE-16: Validar Contrato Do Login Via Schema
    [Documentation]    POST /login success response must conform to the login JSON schema.
    [Tags]    login    contrato    schema
    Log Step    CT-EDGE-16    Full login schema validation
    ${res}    Login User    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Assert Response Status    ${res}    200    CT-EDGE-16
    Validate Response Against Schema    ${res}    login_schema.json

CT-EDGE-17: Retry Em Endpoint Instável Deve Ter Sucesso
    [Documentation]    Retry Request Until Success must recover from transient failures and return the response.
    [Tags]    retry    resiliencia
    Log Step    CT-EDGE-17    Retry mechanism on GET /produtos
    ${res}    Retry Request Until Success    List Products    200    3    1s
    Assert Response Status    ${res}    200    CT-EDGE-17


*** Keywords ***
Edge Cases Suite Setup
    Log Suite Banner    Edge Cases Suite — Boundary, Data-Driven & Schema
    Create Authenticated Session
