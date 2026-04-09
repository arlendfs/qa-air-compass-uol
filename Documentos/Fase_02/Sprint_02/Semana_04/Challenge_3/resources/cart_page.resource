*** Settings ***
Documentation    Keywords de carrinho — camadas Given/When/Then para os endpoints /carrinhos.
# Depende de prod_page.resource para criação dinâmica de produto como pré-condição.
Resource    common.resource
Resource    prod_page.resource


*** Keywords ***
# ── Dado (Given) — pré-condições e estado inicial ───────────────────────────

Dado Que Estou Autenticado Como Admin
    [Documentation]    Obtém token de admin e expõe ${TOKEN} como variável de teste.
    # Separado de "Pegar Token de Autenticação" para deixar o Given semântico no test case.
    ${token}    Pegar Token de Autenticação
    Set Test Variable    ${TOKEN}    ${token}

Dado Que Existe Um Produto Disponível No Estoque
    [Documentation]    Cria um produto com estoque > 0 e expõe ${ID_PRODUTO_CARRINHO} como variável de teste.
    # Produto criado dinamicamente — elimina dependência de IDs fixos no ambiente.
    # Quantidade 5 garante margem para múltiplos testes sem esgotar estoque.
    ${nome}    Gerar Nome Único    prefixo=Produto Carrinho
    ${res}     Cadastrar Produto    ${nome}    150    Produto para teste de carrinho    5    ${TOKEN}
    Should Be Equal As Integers    ${res.status_code}    201
    Set Test Variable    ${ID_PRODUTO_CARRINHO}    ${res.json()['_id']}

Dado Que Tenho Um Carrinho Ativo
    [Documentation]    Cria um carrinho com 1 unidade do produto disponível e expõe ${ID_CARRINHO}.
    # Usado como pré-condição para cenários de checkout e cancelamento.
    # Depende de "Dado Que Existe Um Produto Disponível No Estoque" ter sido executado antes.
    ${res}    Criar Carrinho    ${TOKEN}    ${ID_PRODUTO_CARRINHO}    1
    Should Be Equal As Integers    ${res.status_code}    201
    Set Test Variable    ${ID_CARRINHO}    ${res.json()['_id']}

# ── Quando (When) — ações sobre o endpoint ──────────────────────────────────

Quando Adiciono Um Produto Ao Carrinho
    [Documentation]    Cria um carrinho com 1 unidade do produto disponível.
    # Quantidade 1 é suficiente para validar o fluxo de criação.
    ${res}    Criar Carrinho    ${TOKEN}    ${ID_PRODUTO_CARRINHO}    1
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Finalizo A Compra
    [Documentation]    Envia DELETE /carrinhos/concluir-compra para fechar o carrinho ativo.
    # "Concluir" remove o carrinho e mantém o estoque deduzido (compra efetivada).
    ${res}    Concluir Compra    ${TOKEN}
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Cancelo A Compra
    [Documentation]    Envia DELETE /carrinhos/cancelar-compra para cancelar e repor estoque.
    # "Cancelar" remove o carrinho e devolve as quantidades ao estoque.
    ${res}    Cancelar Compra    ${TOKEN}
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Tento Finalizar Sem Ter Um Carrinho
    [Documentation]    Tenta concluir compra sem carrinho ativo para forçar status de "não encontrado".
    # Usa usuário dedicado criado na hora — nunca teve carrinho, isolamento garantido.
    # A ServeRest retorna 200 (não 404) com mensagem de "não encontrado" nesta rota.
    ${email}       Gerar Email Aleatório
    &{body_user}   Create Dictionary
    ...    nome=User Isolado CT29    email=${email}    password=teste123    administrador=false
    POST On Session    serverest    /usuarios    json=${body_user}
    ...    expected_status=any    verify=${VERIFY_SSL}
    ${token_isolado}    Pegar Token de Autenticação    ${email}    teste123
    ${res}    Concluir Compra    ${token_isolado}
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Tento Adicionar Um Produto Com ID Inválido
    [Documentation]    Tenta criar carrinho com ID de produto malformado para forçar erro 400.
    ${res}    Criar Carrinho    ${TOKEN}    id_produto_invalido_xyz    1
    Log    [CT-30 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Busco O Carrinho Por ID
    [Documentation]    Envia GET /carrinhos/{id} usando o ID exposto pelo Given.
    ${res}    Buscar Carrinho Por ID    ${ID_CARRINHO}
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Tento Adicionar Produto Sem Estoque
    [Documentation]    Cria produto com quantidade=0 e tenta adicioná-lo ao carrinho — força erro 400.
    # ServeRest rejeita adição de produto sem estoque disponível.
    ${nome}        Gerar Nome Único    prefixo=Produto Sem Estoque
    ${res_prod}    Cadastrar Produto    ${nome}    100    Produto sem estoque    0    ${TOKEN}
    Should Be Equal As Integers    ${res_prod.status_code}    201
    ${id_sem_estoque}    Set Variable    ${res_prod.json()['_id']}
    ${res}    Criar Carrinho    ${TOKEN}    ${id_sem_estoque}    1
    Log    [CT-32 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Tento Cancelar Sem Ter Um Carrinho
    [Documentation]    Tenta cancelar compra sem carrinho ativo usando usuário isolado.
    # ServeRest retorna 200 com mensagem "não encontrado" também no cancelar — mesmo comportamento do concluir.
    ${email}       Gerar Email Aleatório
    &{body_user}   Create Dictionary
    ...    nome=User Isolado CT34    email=${email}    password=teste123    administrador=false
    POST On Session    serverest    /usuarios    json=${body_user}
    ...    expected_status=any    verify=${VERIFY_SSL}
    ${token_isolado}    Pegar Token de Autenticação    ${email}    teste123
    ${res}    Cancelar Compra    ${token_isolado}
    Log    [CT-34 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Tento Adicionar Produto Inexistente
    [Documentation]    Tenta criar carrinho com ID de formato válido mas inexistente no banco — força erro 400.
    # Diferente de CT-30 (ID malformado): aqui o ID tem 24 chars hex mas não existe.
    ${res}    Criar Carrinho    ${TOKEN}    000000000000000000000000    1
    Log    [CT-35 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

Quando Tento Finalizar Compra Sem Autenticação
    [Documentation]    Envia DELETE /carrinhos/concluir-compra sem token de autorização — força 401.
    ${headers}    Create Dictionary    accept=application/json
    ${res}    DELETE On Session    serverest    /carrinhos/concluir-compra
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    Log    [CT-36 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Set Test Variable    ${RESPOSTA_CARRINHO}    ${res}

# ── Então (Then) — asserções de resultado ───────────────────────────────────

Então O Carrinho Deve Ser Criado Com Sucesso
    [Documentation]    Valida status 201, mensagem de sucesso e presença do _id no contrato de criação.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    201
    Dictionary Should Contain Key    ${res.json()}    _id
    Should Be Equal As Strings      ${res.json()['message']}    Cadastro realizado com sucesso

Então A Compra Deve Ser Finalizada Com Sucesso
    [Documentation]    Valida status 200 e mensagem de conclusão no contrato de checkout.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    200
    Should Be Equal As Strings     ${res.json()['message']}    Registro excluído com sucesso

Então A Compra Deve Ser Cancelada Com Sucesso
    [Documentation]    Valida status 200 e mensagem de cancelamento com reposição de estoque.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    200
    # Mensagem real da API ServeRest — sem "com sucesso" no final desta rota específica.
    Should Be Equal As Strings     ${res.json()['message']}    Registro excluído com sucesso. Estoque dos produtos reabastecido

Então A Operação Deve Falhar Com
    [Documentation]    Valida status de erro e mensagem esperada. Reutilizável para 400, 401 e 200 com erro.
    [Arguments]    ${status_esperado}    ${mensagem_esperada}    ${res}=${RESPOSTA_CARRINHO}
    Validar Resposta Da API    ${res}    ${status_esperado}    ${mensagem_esperada}

Então O Contrato De Criação De Carrinho Deve Estar Correto
    [Documentation]    Valida schema completo da resposta 201: campos message e _id com tipos corretos.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    201
    ${body}    Set Variable    ${res.json()}
    Dictionary Should Contain Key    ${body}    message
    Dictionary Should Contain Key    ${body}    _id
    ${id}    Get From Dictionary    ${body}    _id
    Should Not Be Empty    ${id}
    Should Be Equal As Strings    ${body}[message]    Cadastro realizado com sucesso

Então A Operação Deve Retornar Não Autorizado
    [Documentation]    Valida que a API retornou 401 para requisição sem token de autenticação.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    401
    Log    [DEBUG] Body 401: ${res.text}    DEBUG

Então O Contrato Do Carrinho Deve Estar Correto
    [Documentation]    Valida a estrutura completa do objeto carrinho retornado por GET /carrinhos/{id}.
    # Contrato ServeRest: _id, produtos (lista), quantidadeTotal, precoTotal, idUsuario.
    [Arguments]    ${res}=${RESPOSTA_CARRINHO}
    Should Be Equal As Integers    ${res.status_code}    200
    ${carrinho}    Set Variable    ${res.json()}
    Dictionary Should Contain Key    ${carrinho}    _id
    Dictionary Should Contain Key    ${carrinho}    idUsuario
    Dictionary Should Contain Key    ${carrinho}    produtos
    Dictionary Should Contain Key    ${carrinho}    precoTotal
    Dictionary Should Contain Key    ${carrinho}    quantidadeTotal
    # Validação de tipos via variáveis intermediárias — Should Be True não expande
    # aspas simples dentro de expressões Python (ex: $dict['key'] quebra o parser do RF).
    ${preco_total}    Get From Dictionary    ${carrinho}    precoTotal
    ${qtd_total}      Get From Dictionary    ${carrinho}    quantidadeTotal
    Should Be True    isinstance($preco_total, (int, float))
    Should Be True    isinstance($qtd_total, (int, float))
    # Validação do contrato do item dentro da lista de produtos
    ${itens}    Get From Dictionary    ${carrinho}    produtos
    Should Not Be Empty    ${itens}
    Validar Contrato Do Item De Carrinho    ${itens}[0]

Validar Contrato Do Item De Carrinho
    [Documentation]    Valida os campos obrigatórios de cada item dentro da lista produtos do carrinho.
    # Contrato ServeRest por item: idProduto, quantidade, precoUnitario (sem nome/descricao).
    [Arguments]    ${item}
    Dictionary Should Contain Key    ${item}    idProduto
    Dictionary Should Contain Key    ${item}    quantidade
    Dictionary Should Contain Key    ${item}    precoUnitario
    ${qtd_item}    Get From Dictionary    ${item}    quantidade
    ${preco_item}  Get From Dictionary    ${item}    precoUnitario
    Should Be True    isinstance($qtd_item, (int, float))
    Should Be True    isinstance($preco_item, (int, float))

# ── Teardown helpers — limpeza de estado entre testes ───────────────────────

Cancelar Carrinho Se Existir
    [Documentation]    Tenta cancelar o carrinho ativo. Resiliente quando ${TOKEN} não está definido.
    # Usado como [Teardown] individual nos testes que criam carrinho.
    # ${TOKEN} pode não existir se o teste falhou antes de "Dado Que Estou Autenticado Como Admin".
    # Nesse caso obtém um token fresco para garantir a limpeza.
    ${token_definido}    Run Keyword And Return Status    Variable Should Exist    ${TOKEN}
    IF    not ${token_definido}
        ${TOKEN}    Pegar Token de Autenticação
        Set Test Variable    ${TOKEN}
    END
    ${res}    Cancelar Compra    ${TOKEN}
    Run Keyword If    ${res.status_code} != 200
    ...    Log    Nenhum carrinho ativo para cancelar (status: ${res.status_code}).    DEBUG

Limpar Carrinho Residual Do Admin
    [Documentation]    Cancela qualquer carrinho ativo do admin antes da suite iniciar.
    # Garante estado limpo mesmo que a execução anterior tenha terminado sem teardown.
    # Chamado no Suite Setup — falha silenciosa é esperada quando não há carrinho.
    ${token}    Pegar Token de Autenticação
    ${res}      Cancelar Compra    ${token}
    Log    Limpeza inicial de carrinho residual — Status: ${res.status_code}    DEBUG

# ── Primitivas (baixo nível) — chamadas HTTP diretas ────────────────────────

Criar Carrinho
    [Documentation]    Primitiva HTTP: POST /carrinhos. Usada pelas keywords Gherkin acima.
    [Arguments]    ${token}    ${id_produto}    ${quantidade}
    ${headers}    Create Dictionary    Authorization=${token}
    # quantidade deve ser int — Create Dictionary trata tudo como string por padrão.
    ${qtd_int}    Convert To Integer    ${quantidade}
    ${item}       Create Dictionary    idProduto=${id_produto}    quantidade=${qtd_int}
    ${produtos}   Create List    ${item}
    ${body}       Create Dictionary    produtos=${produtos}
    ${res}    POST On Session    serverest    /carrinhos    json=${body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Buscar Carrinho Por ID
    [Documentation]    Primitiva HTTP: GET /carrinhos/{id}.
    [Arguments]    ${carrinho_id}
    ${res}    GET On Session    serverest    /carrinhos/${carrinho_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Concluir Compra
    [Documentation]    Primitiva HTTP: DELETE /carrinhos/concluir-compra.
    [Arguments]    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    ${res}    DELETE On Session    serverest    /carrinhos/concluir-compra
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Cancelar Compra
    [Documentation]    Primitiva HTTP: DELETE /carrinhos/cancelar-compra.
    [Arguments]    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    ${res}    DELETE On Session    serverest    /carrinhos/cancelar-compra
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}
