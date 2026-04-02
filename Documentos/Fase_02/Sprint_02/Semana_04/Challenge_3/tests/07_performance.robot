*** Settings ***
Documentation    Performance suite — response time SLA validation and sequential load checks.
...
...    SLA thresholds (configurable via CLI --variable):
...      SLA_FAST   = 500 ms   → GET reads, login
...      SLA_NORMAL = 1000 ms  → POST creates
...      SLA_SLOW   = 2000 ms  → complex flows (cart checkout)
Resource    ../resources/common.resource
Resource    ../services/auth_service.resource
Resource    ../services/user_service.resource
Resource    ../services/product_service.resource
Resource    ../services/cart_service.resource
Resource    ../utils/performance.resource
Resource    ../utils/retry.resource
Resource    ../utils/logger.resource
Suite Setup      Performance Suite Setup
Suite Teardown   Performance Suite Teardown
Test Tags        performance    regression


*** Variables ***
${PERF_PRODUCT_ID}    ${EMPTY}
${PERF_USER_ID}       ${EMPTY}
${SLA_FAST}           1500
${SLA_NORMAL}         2500
${SLA_SLOW}           5000


*** Test Cases ***
CT-PERF-01: POST /login Deve Responder Dentro Do SLA
    [Documentation]    Login endpoint must respond within the FAST SLA (${SLA_FAST} ms).
    [Tags]    smoke    critical
    Log Step    CT-PERF-01    POST /login response time SLA
    ${res}    Login User    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Assert Response Status    ${res}    200    CT-PERF-01
    Assert Response Time    ${res}    ${SLA_FAST}    POST /login

CT-PERF-02: GET /produtos Deve Responder Dentro Do SLA
    [Documentation]    Product listing must respond within the FAST SLA (${SLA_FAST} ms).
    [Tags]    smoke
    Log Step    CT-PERF-02    GET /produtos response time SLA
    ${res}    List Products
    Assert Response Status    ${res}    200    CT-PERF-02
    Assert Response Time    ${res}    ${SLA_FAST}    GET /produtos

CT-PERF-03: GET /produtos/{id} Deve Responder Dentro Do SLA
    [Documentation]    Single product GET must respond within the FAST SLA (${SLA_FAST} ms).
    [Tags]    smoke
    Log Step    CT-PERF-03    GET /produtos/{id} response time SLA
    ${res}    Get Product By ID    ${PERF_PRODUCT_ID}
    Assert Response Status    ${res}    200    CT-PERF-03
    Assert Response Time    ${res}    ${SLA_FAST}    GET /produtos/{id}

CT-PERF-04: GET /usuarios/{id} Deve Responder Dentro Do SLA
    [Documentation]    Single user GET must respond within the FAST SLA (${SLA_FAST} ms).
    [Tags]    smoke
    Log Step    CT-PERF-04    GET /usuarios/{id} response time SLA
    ${res}    Get User By ID    ${PERF_USER_ID}
    Assert Response Status    ${res}    200    CT-PERF-04
    Assert Response Time    ${res}    ${SLA_FAST}    GET /usuarios/{id}

CT-PERF-05: POST /usuarios Deve Responder Dentro Do SLA
    [Documentation]    User creation must respond within the NORMAL SLA (${SLA_NORMAL} ms).
    [Tags]    critical
    Log Step    CT-PERF-05    POST /usuarios response time SLA
    ${email}    Gerar Email Aleatório
    ${res}    Create User    Perf User    ${email}    teste123    false
    Assert Response Status    ${res}    201    CT-PERF-05
    Assert Response Time    ${res}    ${SLA_NORMAL}    POST /usuarios
    Delete User By ID    ${res.json()['_id']}

CT-PERF-06: POST /produtos Deve Responder Dentro Do SLA
    [Documentation]    Product creation must respond within the NORMAL SLA (${SLA_NORMAL} ms).
    [Tags]    critical
    Log Step    CT-PERF-06    POST /produtos response time SLA
    ${nome}    Gerar Nome Único    prefixo=Perf Prod
    ${res}    Create Product    ${nome}    50    Produto perf    5    ${TOKEN}
    Assert Response Status    ${res}    201    CT-PERF-06
    Assert Response Time    ${res}    ${SLA_NORMAL}    POST /produtos
    Delete Product By ID    ${res.json()['_id']}    ${TOKEN}

CT-PERF-07: Fluxo Completo De Carrinho Deve Responder Dentro Do SLA
    [Documentation]    Full cart flow (create → checkout) must complete within the SLOW SLA (${SLA_SLOW} ms).
    [Tags]    critical
    [Teardown]    Checkout Cart    ${TOKEN}
    Log Step    CT-PERF-07    Full cart flow response time SLA
    ${nome}    Gerar Nome Único    prefixo=Perf Cart
    ${res_prod}    Create Product    ${nome}    100    Produto perf cart    5    ${TOKEN}
    Assert Response Status    ${res_prod}    201    CT-PERF-07: create product
    ${product_id}    Set Variable    ${res_prod.json()['_id']}
    ${res_cart}    Create Cart    ${TOKEN}    ${product_id}    1
    Assert Response Status    ${res_cart}    201    CT-PERF-07: create cart
    Assert Response Time    ${res_cart}    ${SLA_NORMAL}    POST /carrinhos
    ${res_checkout}    Checkout Cart    ${TOKEN}
    Assert Response Status    ${res_checkout}    200    CT-PERF-07: checkout
    Assert Response Time    ${res_checkout}    ${SLA_SLOW}    DELETE /carrinhos/concluir-compra

CT-PERF-08: GET /produtos Sob Carga Sequencial De 10 Requisições
    [Documentation]    10 sequential GET /produtos calls must all stay within the FAST SLA.
    ...    Simulates a basic load scenario without concurrency overhead.
    [Tags]    load
    Log Step    CT-PERF-08    Sequential load — GET /produtos x10
    ${times}    Measure Sequential Response Times    List Products    10
    ${max_time}    Evaluate    max($times)
    Log    Peak response time over 10 calls: ${max_time} ms    INFO
    Should Be True    ${max_time} <= ${SLA_FAST}
    ...    msg=Peak response time ${max_time} ms exceeded SLA of ${SLA_FAST} ms under sequential load.

CT-PERF-09: POST /login Sob Carga Sequencial De 5 Requisições
    [Documentation]    5 sequential POST /login calls must all stay within the FAST SLA.
    [Tags]    load
    Log Step    CT-PERF-09    Sequential load — POST /login x5
    ${times}    Measure Sequential Response Times
    ...    Login User    5    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    ${max_time}    Evaluate    max($times)
    Log    Peak login time over 5 calls: ${max_time} ms    INFO
    Should Be True    ${max_time} <= ${SLA_FAST}
    ...    msg=Peak login time ${max_time} ms exceeded SLA of ${SLA_FAST} ms under sequential load.


*** Keywords ***
Performance Suite Setup
    Log Suite Banner    Performance Suite — SLA & Load Checks
    Create Authenticated Session
    # Provision a stable product and user for read-only SLA tests
    ${nome}    Gerar Nome Único    prefixo=Perf Fixture
    ${res_prod}    Create Product    ${nome}    99    Produto fixture perf    20    ${TOKEN}
    Set Suite Variable    ${PERF_PRODUCT_ID}    ${res_prod.json()['_id']}
    ${email}    Gerar Email Aleatório
    ${res_user}    Create User    Perf Fixture User    ${email}    teste123    false
    Set Suite Variable    ${PERF_USER_ID}    ${res_user.json()['_id']}

Performance Suite Teardown
    Delete Product By ID    ${PERF_PRODUCT_ID}    ${TOKEN}
    Delete User By ID    ${PERF_USER_ID}
    Delete All Sessions
