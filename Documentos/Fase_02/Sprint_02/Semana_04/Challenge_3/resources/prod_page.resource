*** Settings ***
Documentation    Product keywords — Gherkin Given/When/Then for /produtos endpoint.
Resource    common.resource
Resource    ../services/product_service.resource


*** Keywords ***
Dado Que Existe Um Produto Cadastrado
    [Documentation]    Creates a product via API and exposes ${ID_PRODUTO} and ${NOME_PRODUTO}.
    [Arguments]    ${token}
    ${nome}    Gerar Nome Único    prefixo=Produto Teste
    ${res}     Create Product    ${nome}    100    Produto de pré-condição    10    ${token}
    Então O Cadastro De Produto Deve Ter Sucesso    ${res}
    Set Test Variable    ${ID_PRODUTO}     ${res.json()['_id']}
    Set Test Variable    ${NOME_PRODUTO}   ${nome}

Quando Cadastro Um Novo Produto
    [Documentation]    Sends POST /produtos with a unique name and valid data.
    [Arguments]    ${token}
    ${nome}    Gerar Nome Único    prefixo=Produto Teste
    ${res}     Create Product    ${nome}    100    Produto para teste    50    ${token}
    Set Test Variable    ${NOME_PRODUTO}        ${nome}
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Quando Tento Cadastrar Um Produto Com Nome Já Existente
    [Documentation]    Reuses an existing product name to force a 400 conflict.
    [Arguments]    ${token}
    ${res}    Create Product    ${NOME_PRODUTO}    150    Produto duplicado    30    ${token}
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Quando Listo Todos Os Produtos
    [Documentation]    Sends GET /produtos and stores the response.
    ${res}    List Products
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Então O Cadastro De Produto Deve Ter Sucesso
    [Documentation]    Asserts status 201, success message, and presence of _id.
    [Arguments]    ${res}=${RESPOSTA_PRODUTO}
    Should Be Equal As Integers    ${res.status_code}    201
    Dictionary Should Contain Key    ${res.json()}    _id
    Should Be Equal As Strings     ${res.json()['message']}    Cadastro realizado com sucesso

Então O Cadastro De Produto Deve Falhar Com
    [Documentation]    Asserts status 400 and the expected error message.
    [Arguments]    ${mensagem_esperada}    ${res}=${RESPOSTA_PRODUTO}
    Validar Resposta Da API    ${res}    400    ${mensagem_esperada}

Então A Listagem De Produtos Deve Estar Correta
    [Documentation]    Asserts status 200, envelope fields, and contract of the first product.
    [Arguments]    ${res}=${RESPOSTA_PRODUTO}
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    produtos
    Dictionary Should Contain Key    ${res.json()}    quantidade
    ${produtos}    Get From Dictionary    ${res.json()}    produtos
    IF    len($produtos) > 0
        Validar Contrato Do Produto    ${produtos}[0]
    ELSE
        Log    Nenhum produto encontrado para validar contrato.    WARN
    END

Validar Contrato Do Produto
    [Documentation]    Asserts all mandatory fields of a product object.
    [Arguments]    ${produto}
    Dictionary Should Contain Key    ${produto}    nome
    Dictionary Should Contain Key    ${produto}    preco
    Dictionary Should Contain Key    ${produto}    descricao
    Dictionary Should Contain Key    ${produto}    quantidade
