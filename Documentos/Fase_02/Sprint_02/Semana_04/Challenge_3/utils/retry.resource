*** Settings ***
Documentation    Retry and resilience utilities — handles flaky endpoints and improves error diagnostics.
Library    Collections
Library    String


*** Variables ***
${RETRY_MAX_ATTEMPTS}    3
${RETRY_INTERVAL}        2s


*** Keywords ***
Retry Request Until Success
    [Documentation]    Retries a service keyword until it returns the expected status code.
    ...    Fails with a full diagnostic log if all attempts are exhausted.
    ...
    ...    Arguments:
    ...      ${keyword}          — name of the keyword to call (must return a response object)
    ...      ${expected_status}  — HTTP status code considered a success (default: 200)
    ...      ${max_attempts}     — number of attempts before failing (default: ${RETRY_MAX_ATTEMPTS})
    ...      ${interval}         — wait time between attempts (default: ${RETRY_INTERVAL})
    ...      @{args}             — positional arguments forwarded to ${keyword}
    [Arguments]    ${keyword}    ${expected_status}=200    ${max_attempts}=${RETRY_MAX_ATTEMPTS}    ${interval}=${RETRY_INTERVAL}    @{args}
    ${attempt}    Set Variable    ${1}
    WHILE    ${attempt} <= ${max_attempts}
        ${res}    Run Keyword    ${keyword}    @{args}
        IF    ${res.status_code} == ${expected_status}
            Log    [Retry] '${keyword}' succeeded on attempt ${attempt}/${max_attempts}.    DEBUG
            RETURN    ${res}
        END
        Log    [Retry] Attempt ${attempt}/${max_attempts} — got ${res.status_code}, expected ${expected_status}. Retrying in ${interval}...    WARN
        Sleep    ${interval}
        ${attempt}    Evaluate    ${attempt} + 1
    END
    Log Response Diagnostics    ${res}    ${keyword}    ${max_attempts}
    Fail    [Retry] '${keyword}' failed after ${max_attempts} attempt(s). Last status: ${res.status_code}, expected: ${expected_status}.

Log Response Diagnostics
    [Documentation]    Logs full response details to aid debugging on failure.
    [Arguments]    ${res}    ${context}=unknown    ${attempts}=1
    Log    [Diagnostics] Context: ${context}    WARN
    Log    [Diagnostics] Attempts: ${attempts}    WARN
    IF    $res is not None
        Log    [Diagnostics] Status: ${res.status_code}    WARN
        Log    [Diagnostics] URL: ${res.url}    WARN
        Log    [Diagnostics] Body: ${res.text}    WARN
    ELSE
        Log    [Diagnostics] Response: None (no response received)    WARN
    END

Assert Response Status
    [Documentation]    Asserts the response status code with a diagnostic log on failure.
    [Arguments]    ${res}    ${expected_status}    ${context}=assertion
    IF    ${res.status_code} != ${expected_status}
        Log Response Diagnostics    ${res}    ${context}
        Fail    Expected status ${expected_status} but got ${res.status_code}. Context: ${context}
    END
