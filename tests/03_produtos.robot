*** Settings ***
Resource    ../resources/common.resource
Resource    ../resources/login_page.resource
Resource    ../resources/prod_page.resource
Suite Setup    Criar Sessão ServeRest
Suite Teardown    Log    Testes de Produtos Concluídos

*** Variables ***
${TOKEN_ADMIN}    ${EMPTY}
${ID_PRODUTO}    ${EMPTY}
${NOME_PRODUTO}    ${EMPTY}

*** Test Cases ***
CT-07: Cadastrar Novo Produto Com Sucesso
    [Documentation]    Verifica se é possível cadastrar um novo produto com dados válidos
    ${TOKEN_ADMIN}    Pegar Token de Autenticação    fulano@qa.com    teste
    Set Suite Variable    ${TOKEN_ADMIN}
    ${NOME_PRODUTO}    Gerar Nome de Produto Único
    Set Suite Variable    ${NOME_PRODUTO}
    ${res}      Cadastrar Produto Novo   ${NOME_PRODUTO}    100    Produto para teste    50    ${TOKEN_ADMIN}
    Status Should Be    201    ${res}
    Dictionary Should Contain Key    ${res.json()}    message
    Dictionary Should Contain Key    ${res.json()}    _id
    Should Be Equal As Strings    ${res.json()['message']}    Cadastro realizado com sucesso
    ${ID_PRODUTO}    Set Variable    ${res.json()['_id']}
    Set Suite Variable    ${ID_PRODUTO}

CT-08: Tentar Cadastrar Produto Com Nome Duplicado
    [Documentation]    Verifica se o sistema impede o cadastro de um produto com nome já existente
    ${res}    Cadastrar Produto Novo   ${NOME_PRODUTO}    150    Produto para teste duplicado    30    ${TOKEN_ADMIN}
    Status Should Be    400    ${res}
    Dictionary Should Contain Key    ${res.json()}    message
    Should Be Equal As Strings    ${res.json()['message']}    Já existe produto com esse nome