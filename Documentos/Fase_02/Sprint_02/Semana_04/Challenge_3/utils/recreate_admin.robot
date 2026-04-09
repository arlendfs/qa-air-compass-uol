*** Settings ***
Documentation    Script utilitário — recria o usuário admin no ServeRest se ele não existir.
...              Execute antes da suite principal quando o login retornar 401.
...              Uso: robot utils/recreate_admin.robot
Library    RequestsLibrary
Library    Collections


*** Variables ***
${BASE_URL}       https://compassuol.serverest.dev
${ADMIN_EMAIL}    fulano@qa.com
${ADMIN_PASSWORD}    teste
${VERIFY_SSL}     ${False}


*** Test Cases ***
Recriar Usuário Admin
    [Documentation]    Tenta login; se falhar com 401, cria o usuário admin e confirma o login.
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json
    Create Session    serverest    ${BASE_URL}    headers=${headers}
    ...    verify=${VERIFY_SSL}    disable_warnings=1
    # Tenta login
    &{body_login}    Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASSWORD}
    ${res_login}    POST On Session    serverest    /login    json=${body_login}
    ...    expected_status=any    verify=${VERIFY_SSL}
    IF    ${res_login.status_code} == 200
        Log    Admin já existe e login OK — nenhuma ação necessária.    INFO
    ELSE
        Log    Login retornou ${res_login.status_code} — recriando usuário admin...    WARN
        &{body_user}    Create Dictionary
        ...    nome=Fulano    email=${ADMIN_EMAIL}
        ...    password=${ADMIN_PASSWORD}    administrador=true
        ${res_create}    POST On Session    serverest    /usuarios    json=${body_user}
        ...    expected_status=any    verify=${VERIFY_SSL}
        Log    Criação: status=${res_create.status_code} | body=${res_create.text}    INFO
        # Confirma login após criação
        ${res_confirm}    POST On Session    serverest    /login    json=${body_login}
        ...    expected_status=any    verify=${VERIFY_SSL}
        Should Be Equal As Integers    ${res_confirm.status_code}    200
        ...    msg=Falha ao confirmar login após recriar admin: ${res_confirm.text}
        Log    Admin recriado e login confirmado com sucesso.    INFO
    END
    Delete All Sessions
