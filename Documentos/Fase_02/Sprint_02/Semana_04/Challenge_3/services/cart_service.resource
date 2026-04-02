*** Settings ***
Documentation    Service layer — HTTP primitives for /carrinhos endpoint.
Resource    ../resources/common.resource
Resource    ../utils/logger.resource


*** Keywords ***
Create Cart
    [Documentation]    POST /carrinhos (requires auth token). Returns the full response object.
    [Arguments]    ${token}    ${product_id}    ${quantidade}
    ${headers}    Create Dictionary    Authorization=${token}
    ${qtd_int}    Convert To Integer    ${quantidade}
    ${item}       Create Dictionary    idProduto=${product_id}    quantidade=${qtd_int}
    ${produtos}   Create List    ${item}
    &{body}       Create Dictionary    produtos=${produtos}
    Log Request    POST    /carrinhos    body=${body}    headers=${headers}
    ${res}    POST On Session    serverest    /carrinhos    json=${body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Create Cart
    RETURN    ${res}

Get Cart By ID
    [Documentation]    GET /carrinhos/{id}. Returns the full response object.
    [Arguments]    ${cart_id}
    Log Request    GET    /carrinhos/${cart_id}
    ${res}    GET On Session    serverest    /carrinhos/${cart_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Get Cart By ID
    RETURN    ${res}

Checkout Cart
    [Documentation]    DELETE /carrinhos/concluir-compra (requires auth token). Returns the full response object.
    [Arguments]    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    Log Request    DELETE    /carrinhos/concluir-compra    headers=${headers}
    ${res}    DELETE On Session    serverest    /carrinhos/concluir-compra
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Checkout Cart
    RETURN    ${res}

Cancel Cart
    [Documentation]    DELETE /carrinhos/cancelar-compra (requires auth token). Returns the full response object.
    [Arguments]    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    Log Request    DELETE    /carrinhos/cancelar-compra    headers=${headers}
    ${res}    DELETE On Session    serverest    /carrinhos/cancelar-compra
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Cancel Cart
    RETURN    ${res}
