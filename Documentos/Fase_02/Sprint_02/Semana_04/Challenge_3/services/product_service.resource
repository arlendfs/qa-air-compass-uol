*** Settings ***
Documentation    Service layer — HTTP primitives for /produtos endpoint.
Resource    ../resources/common.resource
Resource    ../utils/logger.resource


*** Keywords ***
Create Product
    [Documentation]    POST /produtos (requires auth token). Returns the full response object.
    [Arguments]    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    &{body}    Create Dictionary    nome=${nome}    preco=${preco}
    ...    descricao=${descricao}    quantidade=${quantidade}
    Log Request    POST    /produtos    body=${body}    headers=${headers}
    ${res}    POST On Session    serverest    /produtos    json=${body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Create Product
    RETURN    ${res}

List Products
    [Documentation]    GET /produtos. Returns the full response object.
    Log Request    GET    /produtos
    ${res}    GET On Session    serverest    /produtos
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    List Products
    RETURN    ${res}

Get Product By ID
    [Documentation]    GET /produtos/{id}. Returns the full response object.
    [Arguments]    ${product_id}
    Log Request    GET    /produtos/${product_id}
    ${res}    GET On Session    serverest    /produtos/${product_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Get Product By ID
    RETURN    ${res}

Delete Product By ID
    [Documentation]    DELETE /produtos/{id} (requires auth token). Returns the full response object.
    [Arguments]    ${product_id}    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    Log Request    DELETE    /produtos/${product_id}    headers=${headers}
    ${res}    DELETE On Session    serverest    /produtos/${product_id}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Delete Product By ID
    RETURN    ${res}
