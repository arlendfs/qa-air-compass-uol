*** Settings ***
Documentation    Keywords de produtos — camadas Given/When/Then para o endpoint /produtos.
Resource    common.resource


*** Keywords ***
# ── Dado (Given) — pré-condições e estado inicial ───────────────────────────

Dado Que Existe Um Produto Cadastrado
    [Documentation]    Cria um produto via API e expõe ${ID_PRODUTO} e ${NOME_PRODUTO} como variáveis de teste.
    # Usado como pré-condição em cenários que dependem de um produto já existente (ex: duplicata, busca).
    [Arguments]    ${token}
    ${nome}    Gerar Nome Único    prefixo=Produto Teste
    ${res}     Cadastrar Produto    ${nome}    100    Produto de pré-condição    10    ${token}
    Então O Cadastro De Produto Deve Ter Sucesso    ${res}
    Set Test Variable    ${ID_PRODUTO}     ${res.json()['_id']}
    Set Test Variable    ${NOME_PRODUTO}   ${nome}

# ── Quando (When) — ações sobre o endpoint ──────────────────────────────────

Quando Cadastro Um Novo Produto
    [Documentation]    Envia POST /produtos com nome único e dados válidos.
    # Nome gerado dinamicamente — evita falha por produto duplicado entre execuções.
    [Arguments]    ${token}
    ${nome}    Gerar Nome Único    prefixo=Produto Teste
    ${res}     Cadastrar Produto    ${nome}    100    Produto para teste    50    ${token}
    Set Test Variable    ${NOME_PRODUTO}        ${nome}
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Quando Tento Cadastrar Um Produto Com Nome Já Existente
    [Documentation]    Reutiliza o nome de um produto já criado para forçar conflito 400.
    # Depende de "Dado Que Existe Um Produto Cadastrado" ter sido executado antes.
    [Arguments]    ${token}
    ${res}    Cadastrar Produto    ${NOME_PRODUTO}    150    Produto duplicado    30    ${token}
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

Quando Listo Todos Os Produtos
    [Documentation]    Envia GET /produtos e armazena a resposta em ${RESPOSTA_PRODUTO}.
    ${res}    Listar Produtos
    Set Test Variable    ${RESPOSTA_PRODUTO}    ${res}

# ── Então (Then) — asserções de resultado ───────────────────────────────────

Então O Cadastro De Produto Deve Ter Sucesso
    [Documentation]    Valida status 201, mensagem de sucesso e presença do _id na resposta.
    [Arguments]    ${res}=${RESPOSTA_PRODUTO}
    Should Be Equal As Integers    ${res.status_code}    201
    Dictionary Should Contain Key    ${res.json()}    _id
    Should Be Equal As Strings     ${res.json()['message']}    Cadastro realizado com sucesso

Então O Cadastro De Produto Deve Falhar Com
    [Documentation]    Valida status 400 e a mensagem de erro esperada.
    [Arguments]    ${mensagem_esperada}    ${res}=${RESPOSTA_PRODUTO}
    Validar Resposta Da API    ${res}    400    ${mensagem_esperada}

Então A Listagem De Produtos Deve Estar Correta
    [Documentation]    Valida status 200, campos do envelope e contrato do primeiro produto da lista.
    [Arguments]    ${res}=${RESPOSTA_PRODUTO}
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    produtos
    Dictionary Should Contain Key    ${res.json()}    quantidade
    ${produtos}    Get From Dictionary    ${res.json()}    produtos
    IF    len($produtos) > 0
        # Valida contrato apenas quando há dados — evita falso negativo em ambiente limpo.
        Validar Contrato Do Produto    ${produtos}[0]
    ELSE
        Log    Nenhum produto encontrado para validar contrato.    WARN
    END

Validar Contrato Do Produto
    [Documentation]    Valida que o objeto produto contém todos os campos obrigatórios do contrato.
    # Separado para ser reutilizável em outros cenários (ex: busca por ID).
    [Arguments]    ${produto}
    Dictionary Should Contain Key    ${produto}    nome
    Dictionary Should Contain Key    ${produto}    preco
    Dictionary Should Contain Key    ${produto}    descricao
    Dictionary Should Contain Key    ${produto}    quantidade

# ── Primitivas (baixo nível) — chamadas HTTP diretas ────────────────────────

Cadastrar Produto
    [Documentation]    Primitiva HTTP: POST /produtos. Usada pelas keywords Gherkin acima.
    [Arguments]    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    ${body}    Create Dictionary    nome=${nome}    preco=${preco}
    ...    descricao=${descricao}    quantidade=${quantidade}
    ${res}    POST On Session    serverest    /produtos    json=${body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Listar Produtos
    [Documentation]    Primitiva HTTP: GET /produtos.
    ${res}    GET On Session    serverest    /produtos    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Buscar Produto Por ID
    [Documentation]    Primitiva HTTP: GET /produtos/{id}.
    [Arguments]    ${produto_id}
    ${res}    GET On Session    serverest    /produtos/${produto_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}
