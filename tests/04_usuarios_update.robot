*** Settings ***
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Resource    ../resources/users_update_page.resource
Suite Setup    Criar Sessão ServeRest E Criar Usuario Teste
Suite Teardown       Limpar Usuario Teste

*** Test Cases ***
CT-10: Atualizar Usuário Com Sucesso
    [Documentation]    Validar atualização de um usuário com dados válidos
    
    ${novo_nome}    Set Variable    Arlen Atualizado
    ${novo_email}    Gerar Email Aleatório
    ${nova_senha}    Set Variable    teste123

    ${res}    Atualizar Usuário Por ID    ${ID_USUARIO_TESTE}    ${novo_nome}    ${novo_email}    ${nova_senha}    true
    Status Should Be    200    ${res}

    Dictionary Should Contain Key    ${res.json()}    message
    Should Be Equal As Strings    ${res.json()['message']}    Registro alterado com sucesso

    ${res_busca}    Pesquisar Usuário Por ID    ${ID_USUARIO_TESTE}
    Should Be Equal As Strings    ${res_busca.json()['nome']}    ${novo_nome}
    Should Be Equal As Strings    ${res_busca.json()['email']}    ${novo_email}
