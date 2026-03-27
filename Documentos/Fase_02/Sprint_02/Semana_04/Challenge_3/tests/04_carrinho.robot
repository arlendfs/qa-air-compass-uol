*** Settings ***
Documentation    Suite de testes de Carrinho — fluxos de criação, checkout e cancelamento em /carrinhos.
# Cada teste que cria carrinho tem [Teardown] próprio para garantir isolamento.
# Regra ServeRest: um usuário só pode ter 1 carrinho ativo por vez.
Resource    ../resources/common.resource
Resource    ../resources/cart_page.resource
Suite Setup      Inicializar Suite De Carrinho
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-13: Adicionar Produto Ao Carrinho Com Sucesso
    [Documentation]    Um produto válido deve ser adicionado ao carrinho retornando 201 e o _id do carrinho.
    [Tags]    carrinho    positivo    smoke
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    Quando Adiciono Um Produto Ao Carrinho
    Então O Carrinho Deve Ser Criado Com Sucesso

CT-14: Finalizar Compra Com Sucesso
    [Documentation]    Um carrinho ativo deve ser concluído com sucesso retornando 200.
    [Tags]    carrinho    positivo    smoke
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    E Dado Que Tenho Um Carrinho Ativo
    Quando Finalizo A Compra
    Então A Compra Deve Ser Finalizada Com Sucesso

CT-15: Cancelar Compra E Repor Estoque Com Sucesso
    [Documentation]    Cancelar um carrinho ativo deve retornar 200 e repor o estoque do produto.
    [Tags]    carrinho    positivo
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    E Dado Que Tenho Um Carrinho Ativo
    Quando Cancelo A Compra
    Então A Compra Deve Ser Cancelada Com Sucesso

CT-16: Tentar Finalizar Compra Sem Carrinho Ativo
    [Documentation]    Tentar concluir compra sem carrinho ativo deve retornar mensagem de não encontrado.
    # ServeRest retorna 200 (não 404) com mensagem de "não encontrado" nesta rota.
    [Tags]    carrinho    negativo
    Dado Que Estou Autenticado Como Admin
    Quando Tento Finalizar Sem Ter Um Carrinho
    Então A Operação Deve Falhar Com    200    Não foi encontrado carrinho para esse usuário

CT-17: Tentar Adicionar Produto Com ID Inválido Ao Carrinho
    [Documentation]    Tentar adicionar produto com ID inexistente deve retornar 400.
    [Tags]    carrinho    negativo
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    Quando Tento Adicionar Um Produto Com ID Inválido
    Então A Operação Deve Falhar Com    400    Produto não encontrado

CT-18: Validar Contrato Da Resposta Do Carrinho
    [Documentation]    O objeto retornado por GET /carrinhos/{id} deve conter todos os campos do contrato.
    [Tags]    carrinho    contrato
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    E Dado Que Tenho Um Carrinho Ativo
    Quando Busco O Carrinho Por ID
    Então O Contrato Do Carrinho Deve Estar Correto


*** Keywords ***
Inicializar Suite De Carrinho
    [Documentation]    Cria sessão HTTP reutilizável para toda a suite.
    # Token não é obtido aqui — cada teste chama "Dado Que Estou Autenticado Como Admin"
    # para manter o escopo do token no nível de teste (Set Test Variable), evitando
    # que um token expirado em testes longos quebre toda a suite.
    Criar Sessão ServeRest

# Alias "E Dado Que" para permitir múltiplos Givens legíveis sem repetir a palavra "Dado"
E Dado Que Existe Um Produto Disponível No Estoque
    Dado Que Existe Um Produto Disponível No Estoque

E Dado Que Tenho Um Carrinho Ativo
    Dado Que Tenho Um Carrinho Ativo
