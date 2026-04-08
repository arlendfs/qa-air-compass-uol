*** Settings ***
Documentation    Suite de testes de Carrinho — cobre criação, checkout, cancelamento, contrato e edge cases em /carrinhos.
# Cada teste que cria carrinho tem [Teardown] próprio para garantir isolamento.
# Regra ServeRest: um usuário só pode ter 1 carrinho ativo por vez.
Resource    ../resources/common.resource
Resource    ../resources/cart_page.resource
Suite Setup      Inicializar Suite De Carrinho
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-26: Adicionar Produto Ao Carrinho Com Sucesso
    [Documentation]    Um produto válido deve ser adicionado ao carrinho retornando 201 e o _id do carrinho.
    [Tags]    carrinho    positivo    smoke
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    Quando Adiciono Um Produto Ao Carrinho
    Então O Carrinho Deve Ser Criado Com Sucesso

CT-27: Finalizar Compra Com Sucesso
    [Documentation]    Um carrinho ativo deve ser concluído com sucesso retornando 200.
    [Tags]    carrinho    positivo    smoke
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    E Dado Que Tenho Um Carrinho Ativo
    Quando Finalizo A Compra
    Então A Compra Deve Ser Finalizada Com Sucesso

CT-28: Cancelar Compra E Repor Estoque Com Sucesso
    [Documentation]    Cancelar um carrinho ativo deve retornar 200 e repor o estoque do produto.
    [Tags]    carrinho    positivo
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    E Dado Que Tenho Um Carrinho Ativo
    Quando Cancelo A Compra
    Então A Compra Deve Ser Cancelada Com Sucesso

CT-29: Finalizar Compra Sem Carrinho Ativo
    [Documentation]    Tentar concluir compra sem carrinho ativo deve retornar 200 com mensagem de não encontrado.
    # ServeRest retorna 200 (não 404) com mensagem de "não encontrado" nesta rota.
    [Tags]    carrinho    negativo
    Dado Que Estou Autenticado Como Admin
    Quando Tento Finalizar Sem Ter Um Carrinho
    Então A Operação Deve Falhar Com    200    Não foi encontrado carrinho para esse usuário

CT-30: Adicionar Produto Com ID Inválido Ao Carrinho
    [Documentation]    Tentar adicionar produto com ID malformado deve retornar 400.
    [Tags]    carrinho    negativo
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    Quando Tento Adicionar Um Produto Com ID Inválido
    Então A Operação Deve Falhar Com    400    Produto não encontrado

CT-31: Contrato Do Carrinho
    [Documentation]    GET /carrinhos/{id} deve retornar 200 com todos os campos do contrato e tipos corretos.
    [Tags]    carrinho    contrato
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    E Dado Que Tenho Um Carrinho Ativo
    Quando Busco O Carrinho Por ID
    Então O Contrato Do Carrinho Deve Estar Correto

CT-32: Adicionar Produto Sem Estoque
    [Documentation]    Tentar adicionar ao carrinho produto com quantidade=0 deve retornar 400.
    [Tags]    carrinho    negativo    edge
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    Quando Tento Adicionar Produto Sem Estoque
    Então A Operação Deve Falhar Com    400    Produto não possui quantidade suficiente

CT-33: Contrato De Criação De Carrinho
    [Documentation]    A resposta 201 de POST /carrinhos deve conter exatamente os campos message e _id.
    [Tags]    carrinho    contrato
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    E Dado Que Existe Um Produto Disponível No Estoque
    Quando Adiciono Um Produto Ao Carrinho
    Então O Contrato De Criação De Carrinho Deve Estar Correto

CT-34: Cancelar Carrinho Vazio
    [Documentation]    Tentar cancelar compra sem carrinho ativo deve retornar 200 com mensagem de não encontrado.
    # ServeRest retorna 200 (não 404) também no cancelar — comportamento simétrico ao concluir.
    [Tags]    carrinho    negativo    edge
    Dado Que Estou Autenticado Como Admin
    Quando Tento Cancelar Sem Ter Um Carrinho
    Então A Operação Deve Falhar Com    200    Não foi encontrado carrinho para esse usuário

CT-35: Adicionar Produto Inexistente
    [Documentation]    Tentar adicionar produto com ID de formato válido mas inexistente deve retornar 400.
    # Diferente de CT-30 (ID malformado): aqui o ID tem 24 chars hex mas não existe no banco.
    [Tags]    carrinho    negativo    edge
    [Teardown]    Cancelar Carrinho Se Existir
    Dado Que Estou Autenticado Como Admin
    Quando Tento Adicionar Produto Inexistente
    Então A Operação Deve Falhar Com    400    Produto não encontrado

CT-36: Finalizar Compra Sem Autenticação
    [Documentation]    DELETE /carrinhos/concluir-compra sem token deve retornar 401.
    [Tags]    carrinho    negativo    segurança
    Quando Tento Finalizar Compra Sem Autenticação
    Então A Operação Deve Retornar Não Autorizado


*** Keywords ***
# ── Setup da suite ────────────────────────────────────────────────────────────

Inicializar Suite De Carrinho
    [Documentation]    Cria sessão HTTP reutilizável para toda a suite.
    # Token não é obtido aqui — cada teste chama "Dado Que Estou Autenticado Como Admin"
    # para manter o escopo do token no nível de teste (Set Test Variable), evitando
    # que um token expirado em testes longos quebre toda a suite.
    Criar Sessão ServeRest

# ── Aliases "E Dado Que" para múltiplos Givens legíveis ──────────────────────

E Dado Que Existe Um Produto Disponível No Estoque
    Dado Que Existe Um Produto Disponível No Estoque

E Dado Que Tenho Um Carrinho Ativo
    Dado Que Tenho Um Carrinho Ativo
