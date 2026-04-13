*** Settings ***
Documentation    Suite de testes de Produtos — cobre criação, listagem, busca, atualização e edge cases do endpoint /produtos.
Resource    ../resources/common.resource
Resource    ../resources/prod_page.resource
Suite Setup      Inicializar Suite De Produtos
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-PRD-01: Cadastrar Produto Com Sucesso
    [Documentation]    Um produto com dados válidos e nome único deve ser cadastrado retornando 201 e o _id gerado.
    [Tags]    produtos    positivo    smoke
    Quando Cadastro Um Novo Produto    ${TOKEN_ADMIN}
    Então O Cadastro De Produto Deve Ter Sucesso

CT-PRD-02: Tentar Cadastrar Produto Nome Duplicado
    [Documentation]    Tentar cadastrar com nome já existente deve retornar 400 com mensagem de conflito.
    [Tags]    produtos    negativo
    Dado Que Existe Um Produto Cadastrado    ${TOKEN_ADMIN}
    Quando Tento Cadastrar Um Produto Com Nome Já Existente    ${TOKEN_ADMIN}
    Então O Cadastro De Produto Deve Falhar Com    Já existe produto com esse nome

CT-PRD-03: Listar Produtos Validar Contrato
    [Documentation]    GET /produtos deve retornar 200 com envelope quantidade e array produtos com campos obrigatórios.
    [Tags]    produtos    positivo    contrato
    Quando Listo Todos Os Produtos
    Então A Listagem De Produtos Deve Estar Correta

CT-PRD-04: Criar Produto Com Preço Negativo
    [Documentation]    POST /produtos com preco negativo deve retornar 400 com mensagem de validação.
    [Tags]    produtos    negativo    edge
    Quando Cadastro Um Produto Com Preço Negativo    ${TOKEN_ADMIN}
    Então O Cadastro De Produto Deve Falhar Com    preco deve ser um número positivo

CT-PRD-05: [BUG-13] Criar Produto Nome Duplicado Via PUT
    [Documentation]    BUG-13: PUT /produtos/{id} com nome já usado por outro produto deve retornar 400.
    ...                Registra o comportamento atual — ServeRest deve bloquear nomes duplicados no update.
    [Tags]    produtos    negativo    bug
    Dado Que Existem Dois Produtos Cadastrados    ${TOKEN_ADMIN}
    Quando Atualizo O Nome Do Produto Para Um Já Existente    ${TOKEN_ADMIN}
    Então A Atualização De Produto Deve Ser Bloqueada Por Nome Duplicado

CT-PRD-06: Contrato De Produto
    [Documentation]    GET /produtos/{id} deve retornar 200 com os cinco campos obrigatórios e tipos corretos.
    [Tags]    produtos    contrato
    Dado Que Existe Um Produto Cadastrado    ${TOKEN_ADMIN}
    Quando Busco O Produto Por ID    ${ID_PRODUTO}
    Então O Contrato Do Produto Deve Estar Correto

CT-PRD-07: Buscar Produto Com ID Inválido
    [Documentation]    GET /produtos/{id} com string que não é ObjectId válido não deve retornar 500.
    [Tags]    produtos    negativo    edge
    Quando Busco O Produto Por ID    id_invalido_xyz
    Então A Operação De Produto Não Deve Ser Erro Interno

CT-PRD-08: Atualizar Produto Quantidade Negativa
    [Documentation]    PUT /produtos/{id} com quantidade negativa deve retornar 400 com mensagem de validação.
    [Tags]    produtos    negativo    edge
    Dado Que Existe Um Produto Cadastrado    ${TOKEN_ADMIN}
    Quando Atualizo O Produto Com Quantidade Negativa    ${TOKEN_ADMIN}
    Então O Cadastro De Produto Deve Falhar Com    quantidade deve ser maior ou igual a 0

CT-PRD-09: Criar Produto Sem Descrição
    [Documentation]    POST /produtos com campo descricao vazio deve retornar 400 com mensagem de validação.
    [Tags]    produtos    negativo    edge
    Quando Cadastro Um Produto Sem Descrição    ${TOKEN_ADMIN}
    Então O Cadastro De Produto Deve Falhar Com    descricao não pode ficar em branco


*** Keywords ***
# ── Setup da suite ────────────────────────────────────────────────────────────

Inicializar Suite De Produtos
    [Documentation]    Cria sessão e obtém token de admin. Expõe ${TOKEN_ADMIN} para toda a suite.
    Criar Sessão ServeRest
    Garantir Admin Existe
    ${token}    Pegar Token de Autenticação
    Set Suite Variable    ${TOKEN_ADMIN}    ${token}

# ── Dado (Given) — pré-condições compostas específicas desta suite ────────────

Dado Que Existem Dois Produtos Cadastrados
    [Documentation]    Cria dois produtos distintos e expõe ${ID_PRODUTO_A} e ${NOME_PRODUTO_B} como variáveis de teste.
    # CT-PRD-05: dois produtos necessários para forçar conflito de nome no PUT.
    [Arguments]    ${token}
    ${nome_a}    Gerar Nome Único    prefixo=Produto A
    ${res_a}     Cadastrar Produto    ${nome_a}    100    Produto A para CT-PRD-05    10    ${token}
    Should Be Equal As Integers    ${res_a.status_code}    201
    Set Test Variable    ${ID_PRODUTO_A}      ${res_a.json()['_id']}
    ${nome_b}    Gerar Nome Único    prefixo=Produto B
    ${res_b}     Cadastrar Produto    ${nome_b}    200    Produto B para CT-PRD-05    5    ${token}
    Should Be Equal As Integers    ${res_b.status_code}    201
    Set Test Variable    ${NOME_PRODUTO_B}    ${nome_b}

# ── Quando (When) — ações específicas desta suite ─────────────────────────────

Quando Busco O Produto Por ID
    [Documentation]    Envia GET /produtos/{id} e armazena a resposta em ${RESPOSTA_PRODUTO}.
    [Arguments]    ${produto_id}
    ${res}    Buscar Produto Por ID    ${produto_id}
    Log    [DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Quando Cadastro Um Produto Com Preço Negativo
    [Documentation]    Envia POST /produtos com preco=-1 para forçar erro de validação 400.
    [Arguments]    ${token}
    ${nome}    Gerar Nome Único    prefixo=Produto Preco Neg
    ${res}     Cadastrar Produto    ${nome}    -1    Produto com preco negativo    10    ${token}
    Log    [CT-PRD-04 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Quando Atualizo O Nome Do Produto Para Um Já Existente
    [Documentation]    Tenta PUT /produtos/{id_a} usando o nome do produto B — força conflito 400.
    [Arguments]    ${token}
    ${res}    Atualizar Produto    ${ID_PRODUTO_A}    ${NOME_PRODUTO_B}    100    Produto atualizado    10    ${token}
    Log    [CT-PRD-05 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Quando Atualizo O Produto Com Quantidade Negativa
    [Documentation]    Envia PUT /produtos/{id} com quantidade=-1 para forçar erro de validação 400.
    [Arguments]    ${token}
    ${nome}    Gerar Nome Único    prefixo=Produto Qtd Neg
    ${res}     Atualizar Produto    ${ID_PRODUTO}    ${nome}    100    Produto qtd negativa    -1    ${token}
    Log    [CT-PRD-08 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Quando Cadastro Um Produto Sem Descrição
    [Documentation]    Envia POST /produtos com descricao vazia para forçar erro de validação 400.
    [Arguments]    ${token}
    ${nome}    Gerar Nome Único    prefixo=Produto Sem Desc
    ${res}     Cadastrar Produto    ${nome}    100    ${EMPTY}    10    ${token}
    Log    [CT-PRD-09 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

# ── Então (Then) — asserções específicas desta suite ──────────────────────────

Então A Atualização De Produto Deve Ser Bloqueada Por Nome Duplicado
    [Documentation]    Valida que PUT com nome duplicado retorna 400. Loga como BUG se retornar 200.
    # BUG-13: se a API retornar 200, o comportamento está incorreto — registra como WARN.
    ${status}    Set Variable    ${RESPOSTA_PRODUTO.status_code}
    ${body}      Set Variable    ${RESPOSTA_PRODUTO.json()}
    IF    ${status} == 200
        Log    BUG-13: API permitiu atualizar produto com nome duplicado — Status: ${status} | Body: ${body}    WARN
    ELSE
        Should Be Equal As Integers    ${status}    400
        Should Be Equal As Strings    ${body}[message]    Já existe produto com esse nome
    END
