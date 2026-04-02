*** Settings ***
Documentation    Service layer — HTTP primitives for POST /login.
Resource    ../resources/common.resource
Resource    ../utils/logger.resource


*** Keywords ***
Login User
    [Documentation]    POST /login. Returns the full response object.
    [Arguments]    ${email}    ${password}
    &{body}    Create Dictionary    email=${email}    password=${password}
    Log Request    POST    /login    body=${body}
    ${res}    POST On Session    serverest    /login    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log Response    ${res}    Login User
    RETURN    ${res}

Get Auth Token
    [Documentation]    Logs in and returns only the Bearer token string.
    [Arguments]    ${email}=${ADMIN_EMAIL}    ${password}=${ADMIN_PASSWORD}
    ${res}    Login User    ${email}    ${password}
    ${token}    Get From Dictionary    ${res.json()}    authorization
    RETURN    ${token}
