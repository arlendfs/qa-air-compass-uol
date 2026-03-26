*** Settings ***
Documentation     Base Robot Framework Test Suite
Library           RequestsLibrary
Library           String

*** Variables ***
${BASE_URL}    https://serverest.dev


*** Test Cases ***
Cenario: GET Todos Os Usuários 200
    [Tags]    GET
    GET Usuarios
    Validar Status Code "200"

Cenario: POST Cadastrar Usuario 201
    [Tags]    POST
    POST Usuarios
    Validar Status Code "201"

Cenario: PUT Editar Usuario 200
    [Tags]    PUT
    PUT Usuarios
    Validar Status Code "200"

Cenario: DELETE Usuario 200
    [Tags]    DELETE
    DELETE Usuarios
    Validar Status Code "200"


*** Keywords ***
POST Usuarios
    ${random}         Generate Random String    6    [LETTERS]
    &{payload}        Create Dictionary
    ...               nome=Usuario Teste
    ...               email=teste_${random}@gmail.com
    ...               password=123456
    ...               administrador=true
    ${response}       POST    ${BASE_URL}/usuarios    json=${payload}    verify=${False}
    Set Suite Variable    ${response}
    Set Suite Variable    ${usuario_id}    ${response.json()}[_id]

GET Usuarios
    ${response}    GET    ${BASE_URL}/usuarios    verify=${False}
    Set Suite Variable    ${response}

PUT Usuarios
    &{payload}    Create Dictionary
    ...           nome=Usuario Editado
    ...           email=editado@gmail.com
    ...           password=123456
    ...           administrador=false
    ${response}    PUT    ${BASE_URL}/usuarios/${usuario_id}    json=${payload}    verify=${False}
    Set Suite Variable    ${response}

DELETE Usuarios
    ${response}    DELETE    ${BASE_URL}/usuarios/${usuario_id}    verify=${False}
    Set Suite Variable    ${response}

Validar Status Code "${statuscode}"
    Should Be Equal As Integers    ${response.status_code}    ${statuscode}


