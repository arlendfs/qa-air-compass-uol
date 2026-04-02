*** Settings ***
Documentation    Cart suite — create, checkout, and cancel flows for /carrinhos endpoint.
Resource    ../resources/common.resource
Resource    ../resources/cart_page.resource
Resource    ../utils/logger.resource
Suite Setup      Cart Suite Setup
Suite Teardown   Delete All Sessions
Test Tags        carrinho    regression


*** Test Cases ***
CT-13: Adicionar Produto Ao Carrinho Com Sucesso
    [Documentation]    A valid product must be added to the cart returning 201 and the cart _id.
    [Tags]    smoke    critical    positivo
    [Teardown]    Cancelar Carrinho Se Existir
    Log Step    CT-13    Add product to cart
    Dado Que Estou Autenticado Como Admin
    Dado Que Existe Um Produto Disponível No Estoque
    Quando Adiciono Um Produto Ao Carrinho
    Então O Carrinho Deve Ser Criado Com Sucesso

CT-14: Finalizar Compra Com Sucesso
    [Documentation]    An active cart must be checked out successfully returning 200.
    [Tags]    smoke    critical    positivo
    Log Step    CT-14    Checkout active cart
    Dado Que Estou Autenticado Como Admin
    Dado Que Existe Um Produto Disponível No Estoque
    Dado Que Tenho Um Carrinho Ativo
    Quando Finalizo A Compra
    Então A Compra Deve Ser Finalizada Com Sucesso

CT-15: Cancelar Compra E Repor Estoque Com Sucesso
    [Documentation]    Cancelling an active cart must return 200 and restock the product.
    [Tags]    positivo
    Log Step    CT-15    Cancel cart and restock
    Dado Que Estou Autenticado Como Admin
    Dado Que Existe Um Produto Disponível No Estoque
    Dado Que Tenho Um Carrinho Ativo
    Quando Cancelo A Compra
    Então A Compra Deve Ser Cancelada Com Sucesso

CT-16: Tentar Finalizar Compra Sem Carrinho Ativo
    [Documentation]    Attempting checkout without an active cart must return the not-found message.
    [Tags]    negativo
    Log Step    CT-16    Checkout with no active cart
    Dado Que Estou Autenticado Como Admin
    Quando Tento Finalizar Sem Ter Um Carrinho
    Então A Operação Deve Falhar Com    200    Não foi encontrado carrinho para esse usuário

CT-17: Tentar Adicionar Produto Com ID Inválido Ao Carrinho
    [Documentation]    Adding a product with a non-existent ID must return 400.
    [Tags]    negativo    edge
    [Teardown]    Cancelar Carrinho Se Existir
    Log Step    CT-17    Add invalid product ID to cart
    Dado Que Estou Autenticado Como Admin
    Quando Tento Adicionar Um Produto Com ID Inválido
    Então A Operação Deve Falhar Com    400    Produto não encontrado

CT-18: Validar Contrato Da Resposta Do Carrinho
    [Documentation]    GET /carrinhos/{id} must return an object with all contract fields.
    [Tags]    contrato
    [Teardown]    Cancelar Carrinho Se Existir
    Log Step    CT-18    Validate cart response contract
    Dado Que Estou Autenticado Como Admin
    Dado Que Existe Um Produto Disponível No Estoque
    Dado Que Tenho Um Carrinho Ativo
    Quando Busco O Carrinho Por ID
    Então O Contrato Do Carrinho Deve Estar Correto


*** Keywords ***
Cart Suite Setup
    Log Suite Banner    Cart Suite — /carrinhos
    Criar Sessão ServeRest
