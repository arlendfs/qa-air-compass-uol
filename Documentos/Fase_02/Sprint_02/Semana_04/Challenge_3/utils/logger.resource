*** Settings ***
Documentation    Structured logging utility — consistent, readable request/response diagnostics.
Library    Collections
Library    String
Library    DateTime


*** Keywords ***
Log Request
    [Documentation]    Logs the outgoing HTTP request in a structured block.
    [Arguments]    ${method}    ${endpoint}    ${body}=${None}    ${headers}=${None}
    ${ts}    Get Current Date    result_format=%H:%M:%S
    Log    [REQUEST] ${method} ${endpoint} @ ${ts}    INFO
    IF    $headers is not None
        ${safe_headers}    Evaluate
        ...    {k: ("***" if k.lower() == "authorization" else v) for k, v in $headers.items()}
        Log    [REQUEST] Headers: ${safe_headers}    INFO
    END
    IF    $body is not None
        Log    [REQUEST] Body: ${body}    INFO
    END

Log Response
    [Documentation]    Logs the incoming HTTP response in a structured block.
    ...    Guards against None response (e.g. when called from a failed teardown).
    [Arguments]    ${res}    ${context}=${EMPTY}
    IF    $res is None
        Log    [RESPONSE] No response object available — skipping log.    WARN
        RETURN
    END
    ${ts}    Get Current Date    result_format=%H:%M:%S
    ${elapsed}    Evaluate    round($res.elapsed.total_seconds() * 1000, 1)
    Log    [RESPONSE] ${res.status_code} — ${elapsed} ms @ ${ts}    INFO
    IF    $context
        Log    [RESPONSE] Context: ${context}    INFO
    END
    ${body_preview}    Evaluate    str($res.json())[:300] if $res.text else "(empty)"
    Log    [RESPONSE] Body: ${body_preview}    INFO

Log Step
    [Documentation]    Logs a named test step with an optional detail message.
    [Arguments]    ${step}    ${detail}=${EMPTY}
    ${ts}    Get Current Date    result_format=%H:%M:%S
    IF    $detail
        Log    [STEP] ${step} — ${detail} @ ${ts}    INFO
    ELSE
        Log    [STEP] ${step} @ ${ts}    INFO
    END

Log Suite Banner
    [Documentation]    Logs a prominent banner at suite start for easy log navigation.
    [Arguments]    ${suite_name}
    Log    ===================================================    INFO
    Log    SUITE: ${suite_name}    INFO
    Log    ===================================================    INFO

Log Assertion
    [Documentation]    Logs a named assertion before it runs — makes failures self-describing.
    [Arguments]    ${description}
    Log    [ASSERT] ${description}    DEBUG
