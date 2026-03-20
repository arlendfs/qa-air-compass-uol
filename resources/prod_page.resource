*** Settings ***
Resource    common.resource

*** Keywords ***
Cadastrar Produto Novo
    [Documentation]    Cadastrar um produto com token de admin
    [Arguments]    ${nome_produto}    ${preco}    ${descricao}    ${quantidade}    ${token_admin}
    ${headers}    Create Dictionary    Authorization=${token_admin}
    ${body}    Create Dictionary    nome=${nome_produto}    preco=${preco}    descricao=${descricao}    quantidade=${quantidade}
    ${res}    POST On Session    serverest    /produtos    json=${body}    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Listar Todos Produtos
    [Documentation]    Retorna lista completa de produtos
    ${res}    GET On Session    serverest    /produtos    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Buscar Produto Por ID
    [Documentation]    Busca produto específico por ID
    [Arguments]    ${produto_id}
    ${res}    GET On Session    serverest    /produtos/${produto_id}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Gerar Nome de Produto Único
    [Documentation]    Gera um nome de produto único para testes
    ${aleatorio}    Generate Random String    length=8    chars=[LETTERS][NUMBERS]
    ${nome}    Set Variable    Produto Teste ${aleatorio}
    Log    Nome de produto gerado: ${nome}
    RETURN    ${nome}