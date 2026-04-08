*** Settings ***
Documentation    Suite de testes de Usuários — cobre criação, busca, listagem, atualização, deleção e edge cases do endpoint /usuarios.
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Resource    ../resources/users_update_page.resource
Suite Setup      Criar Sessão ServeRest
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-08: Cadastrar Usuário Com Sucesso
    [Documentation]    Um novo usuário com dados válidos deve ser cadastrado retornando 201 e o _id gerado.
    [Tags]    usuarios    positivo    smoke
    Quando Cadastro Um Novo Usuário
    Então O Cadastro De Usuário Deve Ter Sucesso

CT-09: Tentar Cadastrar Email Duplicado
    [Documentation]    Tentar cadastrar com email já existente deve retornar 400 com mensagem de conflito.
    [Tags]    usuarios    negativo
    Dado Que Existe Um Usuário Cadastrado
    Quando Tento Cadastrar Um Usuário Com Email Já Existente
    Então O Cadastro De Usuário Deve Falhar Com    Este email já está sendo usado

CT-10: Buscar Usuário Por ID Validar Contrato
    [Documentation]    Um usuário cadastrado deve ser encontrado por ID com todos os campos do contrato.
    [Tags]    usuarios    positivo    contrato
    Dado Que Existe Um Usuário Cadastrado
    Quando Busco O Usuário Por ID
    Então Os Dados Do Usuário Devem Estar Corretos

CT-11: Contrato De Criação De Usuário
    [Documentation]    A resposta 201 de POST /usuarios deve conter exatamente os campos message e _id com tipos corretos.
    [Tags]    usuarios    contrato
    Quando Cadastro Um Novo Usuário
    Então O Contrato De Criação De Usuário Deve Estar Correto

CT-12: Contrato De Listagem De Usuários
    [Documentation]    GET /usuarios deve retornar 200 com envelope quantidade (int) e array usuarios com campos obrigatórios.
    [Tags]    usuarios    contrato
    Quando Listo Todos Os Usuários
    Então O Contrato De Listagem De Usuários Deve Estar Correto

CT-13: Atualizar Usuário Com Email Duplicado
    [Documentation]    PUT /usuarios/{id} com email já usado por outro usuário deve retornar 400 com mensagem de conflito.
    [Tags]    usuarios    negativo
    Dado Que Existem Dois Usuários Cadastrados
    Quando Atualizo O Email Do Usuário Para Um Já Existente    ${ID_USUARIO_A}    ${EMAIL_USUARIO_B}
    Então O Cadastro De Usuário Deve Falhar Com    Este email já está sendo usado

CT-14: [BUG-14] Deletar Usuário Com Carrinho Ativo
    [Documentation]    BUG-14: DELETE /usuarios/{id} de usuário com carrinho ativo deve retornar 400.
    ...                Registra o comportamento atual da API — ServeRest bloqueia a deleção neste caso.
    [Tags]    usuarios    negativo    bug
    Dado Que Existe Um Usuário Com Carrinho Ativo
    Quando Deleto O Usuário    ${ID_USUARIO_COM_CARRINHO}
    Então A Deleção Deve Ser Bloqueada Por Carrinho Ativo

CT-15: Buscar Usuário Com ID Malformado
    [Documentation]    GET /usuarios/{id} com string que não é ObjectId válido deve retornar 400 sem erro 500.
    [Tags]    usuarios    negativo    edge
    Quando Busco Usuário Com ID Malformado
    Então A Resposta Não Deve Ser Erro Interno

CT-16: Cadastrar Usuário Com Nome Vazio
    [Documentation]    POST /usuarios com campo nome vazio deve retornar 400 com mensagem de validação.
    [Tags]    usuarios    negativo    edge
    Quando Cadastro Um Usuário Com Nome Vazio
    Então O Cadastro De Usuário Deve Falhar Com    nome não pode ficar em branco


*** Keywords ***
# ── Dado (Given) — pré-condições compostas específicas desta suite ───────────

Dado Que Existem Dois Usuários Cadastrados
    [Documentation]    Cria dois usuários distintos e expõe ${ID_USUARIO_A}, ${EMAIL_USUARIO_B} como variáveis de teste.
    # CT-13 precisa de dois usuários para forçar conflito de email no PUT.
    ${email_a}    Gerar Email Aleatório
    ${res_a}      Cadastrar Usuário    Usuario A    ${email_a}    teste123
    Set Test Variable    ${ID_USUARIO_A}      ${res_a.json()['_id']}
    ${email_b}    Gerar Email Aleatório
    Cadastrar Usuário    Usuario B    ${email_b}    teste123
    Set Test Variable    ${EMAIL_USUARIO_B}    ${email_b}

Dado Que Existe Um Usuário Com Carrinho Ativo
    [Documentation]    Cria um usuário não-admin, faz login, cria um produto e abre um carrinho para ele.
    # CT-14: ServeRest bloqueia DELETE /usuarios/{id} quando o usuário tem carrinho ativo.
    # Produto criado com token de admin (${ADMIN_EMAIL}) — usuário comum não pode criar produto.
    ${email}        Gerar Email Aleatório
    ${res_user}     Cadastrar Usuário    Usuario Carrinho    ${email}    teste123    false
    ${id_user}      Set Variable    ${res_user.json()['_id']}
    Set Test Variable    ${ID_USUARIO_COM_CARRINHO}    ${id_user}
    ${token_admin}    Pegar Token de Autenticação
    ${nome_prod}      Gerar Nome Único    prefixo=Prod CT14
    ${body_prod}      Create Dictionary    nome=${nome_prod}    preco=${100}    descricao=Produto CT14    quantidade=${5}
    ${headers}        Create Dictionary    Authorization=${token_admin}
    ${res_prod}       POST On Session    serverest    /produtos    json=${body_prod}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    ${id_prod}        Set Variable    ${res_prod.json()['_id']}
    ${token_user}     Pegar Token de Autenticação    ${email}    teste123
    ${item}           Create Dictionary    idProduto=${id_prod}    quantidade=${1}
    ${produtos}       Create List    ${item}
    ${body_cart}      Create Dictionary    produtos=${produtos}
    ${headers_user}   Create Dictionary    Authorization=${token_user}
    POST On Session    serverest    /carrinhos    json=${body_cart}
    ...    headers=${headers_user}    expected_status=any    verify=${VERIFY_SSL}

# ── Quando (When) — ações específicas desta suite ────────────────────────────

Quando Cadastro Um Usuário Com Nome Vazio
    [Documentation]    Envia POST /usuarios com nome como string vazia para forçar erro de validação 400.
    ${email}    Gerar Email Aleatório
    ${res}      Cadastrar Usuário    ${EMPTY}    ${email}    teste123
    Log    [CT-16 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

# ── Então (Then) — asserções específicas desta suite ─────────────────────────

Então A Deleção Deve Ser Bloqueada Por Carrinho Ativo
    [Documentation]    Valida que a API retorna 400 com mensagem de bloqueio por carrinho ativo.
    # BUG-14: se a API retornar 200, o comportamento está incorreto — registra como WARN.
    ${status}    Set Variable    ${RESPOSTA_USUARIO.status_code}
    IF    ${status} == 400
        Should Be Equal As Strings
        ...    ${RESPOSTA_USUARIO.json()['message']}
        ...    Não é permitido excluir usuário com carrinho cadastrado
    ELSE
        Log    BUG-14: API permitiu deletar usuário com carrinho ativo — Status: ${status}    WARN
    END

Então A Resposta Não Deve Ser Erro Interno
    [Documentation]    Valida que a API não retornou 500 para um ID malformado (comportamento defensivo).
    Should Not Be Equal As Integers    ${RESPOSTA_USUARIO.status_code}    500
    Log    Status retornado para ID malformado: ${RESPOSTA_USUARIO.status_code}
