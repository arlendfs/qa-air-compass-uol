*** Settings ***
Documentation    Keywords de usuários — camadas Given/When/Then para o endpoint /usuarios.
Resource    common.resource


*** Keywords ***
# ── Dado (Given) — pré-condições e estado inicial ───────────────────────────

Dado Que Existe Um Usuário Cadastrado
    [Documentation]    Cria um usuário via API e expõe ${ID_USUARIO} e ${EMAIL_USUARIO} como variáveis de teste.
    # Usado como pré-condição em cenários que dependem de um usuário já existente (ex: busca, duplicata).
    ${email}    Gerar Email Aleatório
    ${res}      Cadastrar Usuário    ${USER_NAME}    ${email}    ${ADMIN_PASSWORD}
    Então O Cadastro De Usuário Deve Ter Sucesso    ${res}
    Set Test Variable    ${ID_USUARIO}     ${res.json()['_id']}
    Set Test Variable    ${EMAIL_USUARIO}  ${email}

# ── Quando (When) — ações sobre o endpoint ──────────────────────────────────

Quando Cadastro Um Novo Usuário
    [Documentation]    Envia POST /usuarios com dados válidos e únicos.
    # Email gerado dinamicamente — elimina dependência de dados fixos no ambiente.
    ${email}    Gerar Email Aleatório
    ${res}      Cadastrar Usuário    ${USER_NAME}    ${email}    ${ADMIN_PASSWORD}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Tento Cadastrar Um Usuário Com Email Já Existente
    [Documentation]    Reutiliza o email de um usuário já criado para forçar conflito 400.
    # Depende de "Dado Que Existe Um Usuário Cadastrado" ter sido executado antes.
    ${res}    Cadastrar Usuário    ${USER_NAME}    ${EMAIL_USUARIO}    ${ADMIN_PASSWORD}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Busco O Usuário Por ID
    [Documentation]    Envia GET /usuarios/{id} usando o ID exposto pelo Given.
    ${res}    Pesquisar Usuário Por ID    ${ID_USUARIO}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

# ── Então (Then) — asserções de resultado ───────────────────────────────────

Então O Cadastro De Usuário Deve Ter Sucesso
    [Documentation]    Valida status 201 e mensagem de sucesso no cadastro.
    [Arguments]    ${res}=${RESPOSTA_USUARIO}
    Validar Resposta Da API    ${res}    201    Cadastro realizado com sucesso

Então O Cadastro De Usuário Deve Falhar Com
    [Documentation]    Valida status 400 e mensagem de erro. Loga body completo para debug.
    # ServeRest retorna erros de validação de campo com a chave sendo o nome do campo
    # (ex: {"nome": "nome não pode ficar em branco"}), não "message".
    # Valida status antes de acessar qualquer campo para evitar KeyError.
    [Arguments]    ${mensagem_esperada}    ${res}=${RESPOSTA_USUARIO}
    ${status}    Set Variable    ${res.status_code}
    ${body}      Set Variable    ${res.json()}
    Log    [DEBUG] Status: ${status} | Body: ${body}    DEBUG
    IF    ${status} == 200
        ${tem_message}    Run Keyword And Return Status    Dictionary Should Contain Key    ${body}    message
        IF    ${tem_message}
            Log    BUG: API aceitou dado inválido e retornou 200 — message: ${body}[message]    WARN
        ELSE
            Log    BUG: API aceitou dado inválido e retornou 200 sem campo message — body: ${body}    WARN
        END
        Fail    BUG: API retornou 200 para dado inválido — esperado 400
    END
    Should Be Equal As Integers    ${status}    400
    # Tenta campo "message" primeiro; se não existir, busca pelo nome do campo de validação
    ${tem_message}    Run Keyword And Return Status    Dictionary Should Contain Key    ${body}    message
    IF    ${tem_message}
        Should Be Equal As Strings    ${body}[message]    ${mensagem_esperada}
    ELSE
        ${chaves}    Get Dictionary Keys    ${body}
        Log    [DEBUG] Campos retornados no erro 400: ${chaves}    DEBUG
        ${campo_validacao}    Set Variable    ${chaves}[0]
        ${valor_validacao}    Get From Dictionary    ${body}    ${campo_validacao}
        Should Be Equal As Strings    ${valor_validacao}    ${mensagem_esperada}
    END

Então Os Dados Do Usuário Devem Estar Corretos
    [Documentation]    Valida status 200 e presença dos campos obrigatórios do contrato /usuarios/{id}.
    [Arguments]    ${res}=${RESPOSTA_USUARIO}
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    nome
    Dictionary Should Contain Key    ${res.json()}    email
    Dictionary Should Contain Key    ${res.json()}    password
    Dictionary Should Contain Key    ${res.json()}    administrador
    Dictionary Should Contain Key    ${res.json()}    _id

Então O Contrato De Criação De Usuário Deve Estar Correto
    [Documentation]    Valida schema completo da resposta 201: campos message e _id com tipos corretos.
    [Arguments]    ${res}=${RESPOSTA_USUARIO}
    Should Be Equal As Integers    ${res.status_code}    201
    ${body}    Set Variable    ${res.json()}
    Dictionary Should Contain Key    ${body}    message
    Dictionary Should Contain Key    ${body}    _id
    ${id}    Get From Dictionary    ${body}    _id
    Should Not Be Empty    ${id}

Então O Contrato De Listagem De Usuários Deve Estar Correto
    [Documentation]    Valida schema do envelope GET /usuarios: quantidade (int) e array usuarios com campos obrigatórios.
    [Arguments]    ${res}=${RESPOSTA_USUARIO}
    Should Be Equal As Integers    ${res.status_code}    200
    ${body}    Set Variable    ${res.json()}
    Dictionary Should Contain Key    ${body}    quantidade
    Dictionary Should Contain Key    ${body}    usuarios
    ${qtd}       Get From Dictionary    ${body}    quantidade
    ${lista}     Get From Dictionary    ${body}    usuarios
    Should Be True    isinstance($qtd, int)
    Should Be True    isinstance($lista, list)
    IF    len($lista) > 0
        ${item}    Set Variable    ${lista}[0]
        Dictionary Should Contain Key    ${item}    nome
        Dictionary Should Contain Key    ${item}    email
        Dictionary Should Contain Key    ${item}    password
        Dictionary Should Contain Key    ${item}    administrador
        Dictionary Should Contain Key    ${item}    _id
    END

# ── Quando (When) — ações adicionais ───────────────────────────────────────

Quando Listo Todos Os Usuários
    [Documentation]    Envia GET /usuarios sem filtros e armazena a resposta em ${RESPOSTA_USUARIO}.
    ${res}    Listar Usuários
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Atualizo O Email Do Usuário Para Um Já Existente
    [Documentation]    Tenta PUT /usuarios/{id} usando o email de outro usuário já cadastrado — força conflito 400.
    # Depende de ${ID_USUARIO} e ${EMAIL_USUARIO_B} expostos pelo Given de pré-condição dupla.
    [Arguments]    ${id}    ${email_duplicado}
    ${res}    Atualizar Usuário    ${id}    Usuario Teste    ${email_duplicado}    teste123    true
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Deleto O Usuário
    [Documentation]    Envia DELETE /usuarios/{id} usando o ID exposto pelo Given.
    [Arguments]    ${id}
    ${res}    Deletar Usuário    ${id}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Busco Usuário Com ID Malformado
    [Documentation]    Envia GET /usuarios/{id} com string que não é um ObjectId válido.
    ${res}    Pesquisar Usuário Por ID    id_malformado_xyz
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

# ── Primitivas (baixo nível) — chamadas HTTP diretas ────────────────────────

Cadastrar Usuário
    [Documentation]    Primitiva HTTP: POST /usuarios. Usada pelas keywords Gherkin acima.
    [Arguments]    ${nome}    ${email}    ${password}    ${administrador}=${ADMINISTRADOR}
    &{body}    Create Dictionary    nome=${nome}    email=${email}
    ...    password=${password}    administrador=${administrador}
    ${res}    POST On Session    serverest    /usuarios    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Pesquisar Usuário Por ID
    [Documentation]    Primitiva HTTP: GET /usuarios/{id}. Usada pelas keywords Gherkin acima.
    [Arguments]    ${user_id}
    ${res}    GET On Session    serverest    /usuarios/${user_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Listar Usuários
    [Documentation]    Primitiva HTTP: GET /usuarios sem filtros.
    ${res}    GET On Session    serverest    /usuarios
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Atualizar Usuário
    [Documentation]    Primitiva HTTP: PUT /usuarios/{id}.
    [Arguments]    ${user_id}    ${nome}    ${email}    ${password}    ${administrador}
    ${body}    Create Dictionary    nome=${nome}    email=${email}
    ...    password=${password}    administrador=${administrador}
    ${res}    PUT On Session    serverest    /usuarios/${user_id}    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Deletar Usuário
    [Documentation]    Primitiva HTTP: DELETE /usuarios/{id}.
    [Arguments]    ${user_id}
    ${res}    DELETE On Session    serverest    /usuarios/${user_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}
