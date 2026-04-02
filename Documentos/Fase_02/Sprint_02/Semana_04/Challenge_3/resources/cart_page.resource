*** Settings ***
Documentation    Cart keywords — Gherkin Given/When/Then for /carrinhos endpoint.
Resource    common.resource
Resource    ../services/auth_service.resource
Resource    ../services/product_service.resource
Resource    ../services/cart_service.resource


*** Keywords ***
Dado Que Estou Autenticado Como Admin
    [Documentation]    Obtains an admin token, exposes ${TOKEN}, and cancels any stale cart.
    ${token}    Get Auth Token
    Set Test Variable    ${TOKEN}    ${token}
    # Cancel any leftover cart from a previous run — ServeRest allows only 1 cart per user.
    Cancel Cart    ${token}

Dado Que Existe Um Produto Disponível No Estoque
    [Documentation]    Creates a product with stock > 0 and exposes ${ID_PRODUTO_CARRINHO}.
    ${nome}    Gerar Nome Único    prefixo=Produto Carrinho
    ${res}     Create Product    ${nome}    150    Produto para teste de carrinho    5    ${TOKEN}
    Should Be Equal As Integers    ${res.status_code}    201
    Set Test Variable    ${ID_PRODUTO_CARRINHO}    ${res.json()['_id']}

Dado Que Tenho Um Carrinho Ativo
    [Documentation]    Creates a cart with 1 unit of the available product and exposes ${ID_CARRINHO}.
    ${res}    Create Cart    ${TOKEN}    ${ID_PRODUTO_CARRINHO}    1
    Should Be Equal As Integers    ${res.status_code}    201
    Set Test Variable    ${ID_CARRINHO}    ${res.json()['_id']}

Quando Adiciono Um Produto Ao Carrinho
    [Documentation]    Creates a cart with 1 unit of the available product.
    ${res}    Create Cart    ${TOKEN}    ${ID_PRODUTO_CARRINHO}    1
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Finalizo A Compra
    [Documentation]    Sends DELETE /carrinhos/concluir-compra to close the active cart.
    ${res}    Checkout Cart    ${TOKEN}
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Cancelo A Compra
    [Documentation]    Sends DELETE /carrinhos/cancelar-compra to cancel and restock.
    ${res}    Cancel Cart    ${TOKEN}
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Tento Finalizar Sem Ter Um Carrinho
    [Documentation]    Attempts checkout with an isolated user who has no active cart.
    ${email}       Gerar Email Aleatório
    &{body_user}   Create Dictionary
    ...    nome=User Isolado CT16    email=${email}    password=teste123    administrador=false
    POST On Session    serverest    /usuarios    json=${body_user}
    ...    expected_status=any    verify=${VERIFY_SSL}
    ${token_isolado}    Get Auth Token    ${email}    teste123
    ${res}    Checkout Cart    ${token_isolado}
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Tento Adicionar Um Produto Com ID Inválido
    [Documentation]    Attempts to create a cart with a non-existent product ID to force 400.
    ${res}    Create Cart    ${TOKEN}    id_produto_invalido_xyz    1
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Busco O Carrinho Por ID
    [Documentation]    Sends GET /carrinhos/{id} using the ID exposed by the Given.
    ${res}    Get Cart By ID    ${ID_CARRINHO}
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Então O Carrinho Deve Ser Criado Com Sucesso
    [Documentation]    Asserts status 201, success message, and presence of _id.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    201
    Dictionary Should Contain Key    ${res.json()}    _id
    Should Be Equal As Strings      ${res.json()['message']}    Cadastro realizado com sucesso

Então A Compra Deve Ser Finalizada Com Sucesso
    [Documentation]    Asserts status 200 and checkout success message.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    200
    Should Be Equal As Strings     ${res.json()['message']}    Registro excluído com sucesso

Então A Compra Deve Ser Cancelada Com Sucesso
    [Documentation]    Asserts status 200 and cancellation message with stock restock.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    200
    Should Be Equal As Strings     ${res.json()['message']}    Registro excluído com sucesso. Estoque dos produtos reabastecido

Então A Operação Deve Falhar Com
    [Documentation]    Asserts error status and expected message. Reusable for 400, 401, 404.
    [Arguments]    ${status_esperado}    ${mensagem_esperada}    ${res}=${RESPOSTA_CARRINHO}
    Validar Resposta Da API    ${res}    ${status_esperado}    ${mensagem_esperada}

Então O Contrato Do Carrinho Deve Estar Correto
    [Documentation]    Asserts the full structure of the cart object from GET /carrinhos/{id}.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    200
    ${carrinho}    Set Variable    ${res.json()}
    Dictionary Should Contain Key    ${carrinho}    _id
    Dictionary Should Contain Key    ${carrinho}    idUsuario
    Dictionary Should Contain Key    ${carrinho}    produtos
    Dictionary Should Contain Key    ${carrinho}    precoTotal
    Dictionary Should Contain Key    ${carrinho}    quantidadeTotal
    ${preco_total}    Get From Dictionary    ${carrinho}    precoTotal
    ${qtd_total}      Get From Dictionary    ${carrinho}    quantidadeTotal
    Should Be True    isinstance($preco_total, (int, float))
    Should Be True    isinstance($qtd_total, (int, float))
    ${itens}    Get From Dictionary    ${carrinho}    produtos
    Should Not Be Empty    ${itens}
    Validar Contrato Do Item De Carrinho    ${itens}[0]

Validar Contrato Do Item De Carrinho
    [Documentation]    Asserts mandatory fields of each item inside the cart's product list.
    [Arguments]    ${item}
    Dictionary Should Contain Key    ${item}    idProduto
    Dictionary Should Contain Key    ${item}    quantidade
    Dictionary Should Contain Key    ${item}    precoUnitario
    ${qtd_item}    Get From Dictionary    ${item}    quantidade
    ${preco_item}  Get From Dictionary    ${item}    precoUnitario
    Should Be True    isinstance($qtd_item, (int, float))
    Should Be True    isinstance($preco_item, (int, float))

Cancelar Carrinho Se Existir
    [Documentation]    Teardown helper: cancels the active cart, ignores error if none exists.
    ${res}    Cancel Cart    ${TOKEN}
    Run Keyword If    ${res.status_code} != 200
    ...    Log    Nenhum carrinho ativo para cancelar (status: ${res.status_code}).    DEBUG
