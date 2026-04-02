*** Settings ***
Documentation    Service layer — HTTP primitives for /usuarios endpoint.
Resource    ../resources/common.resource
Resource    ../utils/logger.resource


*** Keywords ***
Create User
    [Documentation]    POST /usuarios. Returns the full response object.
    [Arguments]    ${nome}    ${email}    ${password}    ${administrador}=${ADMINISTRADOR}
    &{body}    Create Dictionary    nome=${nome}    email=${email}
    ...    password=${password}    administrador=${administrador}
    Log Request    POST    /usuarios    body=${body}
    ${res}    POST On Session    serverest    /usuarios    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Create User
    RETURN    ${res}

Get User By ID
    [Documentation]    GET /usuarios/{id}. Returns the full response object.
    [Arguments]    ${user_id}
    Log Request    GET    /usuarios/${user_id}
    ${res}    GET On Session    serverest    /usuarios/${user_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Get User By ID
    RETURN    ${res}

Update User By ID
    [Documentation]    PUT /usuarios/{id}. Returns the full response object.
    [Arguments]    ${user_id}    ${nome}    ${email}    ${password}    ${administrador}
    &{body}    Create Dictionary    nome=${nome}    email=${email}
    ...    password=${password}    administrador=${administrador}
    Log Request    PUT    /usuarios/${user_id}    body=${body}
    ${res}    PUT On Session    serverest    /usuarios/${user_id}    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Update User By ID
    RETURN    ${res}

Delete User By ID
    [Documentation]    DELETE /usuarios/{id}. Returns the full response object.
    [Arguments]    ${user_id}
    Log Request    DELETE    /usuarios/${user_id}
    ${res}    DELETE On Session    serverest    /usuarios/${user_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Delete User By ID
    RETURN    ${res}
