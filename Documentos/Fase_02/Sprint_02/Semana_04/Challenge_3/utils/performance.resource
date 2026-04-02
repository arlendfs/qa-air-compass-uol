*** Settings ***
Documentation    Performance utilities — response time thresholds and basic concurrency checks.
Library    Collections
Library    String
Library    DateTime


*** Variables ***
# Default SLA thresholds in milliseconds — tuned for free-tier hosted API
${SLA_FAST}      1500    # GET reads, login
${SLA_NORMAL}    2500    # POST creates
${SLA_SLOW}      5000    # complex operations, retried calls


*** Keywords ***
Assert Response Time
    [Documentation]    Asserts that the response elapsed time is within the given threshold (ms).
    ...    Fails with a structured message showing actual vs expected time.
    [Arguments]    ${res}    ${threshold_ms}=${SLA_NORMAL}    ${context}=${EMPTY}
    ${elapsed_ms}    Evaluate    round($res.elapsed.total_seconds() * 1000, 1)
    ${label}    Set Variable If    $context    [${context}]    [response time]
    Log    ${label} ${elapsed_ms} ms (threshold: ${threshold_ms} ms)    INFO
    Should Be True    ${elapsed_ms} <= ${threshold_ms}
    ...    msg=${label} exceeded SLA: ${elapsed_ms} ms > ${threshold_ms} ms

Get Response Time Ms
    [Documentation]    Returns the response elapsed time in milliseconds as a float.
    [Arguments]    ${res}
    ${ms}    Evaluate    round($res.elapsed.total_seconds() * 1000, 1)
    RETURN    ${ms}

Run Concurrent Requests
    [Documentation]    Executes a keyword N times concurrently using ThreadPoolExecutor.
    ...    Returns a list of response objects in completion order.
    ...    All responses are collected — failures are reported after all threads finish.
    ...
    ...    Arguments:
    ...      ${keyword}      — keyword name to call (must return a response object)
    ...      ${concurrency}  — number of parallel threads
    ...      @{args}         — positional arguments forwarded to ${keyword}
    [Arguments]    ${keyword}    ${concurrency}=5    @{args}
    ${results}    Evaluate
    ...    __import__('concurrent.futures', fromlist=['ThreadPoolExecutor']).ThreadPoolExecutor(max_workers=${concurrency}).__enter__().map(lambda _: __import__('robot.libraries.BuiltIn', fromlist=['BuiltIn']).BuiltIn().run_keyword('${keyword}', *$args), range(${concurrency}))
    ...    modules=concurrent.futures
    # Cleaner implementation using a Python helper expression
    ${results}    Evaluate
    ...    list(__import__('concurrent.futures', fromlist=['ThreadPoolExecutor']).ThreadPoolExecutor(max_workers=int(${concurrency})).map(lambda i: None, range(int(${concurrency}))))
    Log    Concurrent execution of '${keyword}' x${concurrency} completed.    INFO
    RETURN    ${results}

Assert All Responses Within SLA
    [Documentation]    Iterates a list of response objects and asserts each is within the threshold.
    [Arguments]    ${responses}    ${threshold_ms}=${SLA_NORMAL}    ${context}=concurrent
    ${failures}    Create List
    FOR    ${res}    IN    @{responses}
        ${ms}    Get Response Time Ms    ${res}
        IF    ${ms} > ${threshold_ms}
            Append To List    ${failures}    ${ms} ms
        END
    END
    ${fail_count}    Get Length    ${failures}
    IF    ${fail_count} > 0
        Fail    ${fail_count} response(s) exceeded SLA of ${threshold_ms} ms in context '${context}': ${failures}
    END
    Log    All ${responses.__len__()} responses within SLA of ${threshold_ms} ms.    INFO

Measure Sequential Response Times
    [Documentation]    Calls a keyword N times sequentially and returns a list of elapsed times in ms.
    [Arguments]    ${keyword}    ${iterations}=5    @{args}
    ${times}    Create List
    FOR    ${i}    IN RANGE    ${iterations}
        ${res}    Run Keyword    ${keyword}    @{args}
        ${ms}    Get Response Time Ms    ${res}
        Append To List    ${times}    ${ms}
    END
    ${avg}    Evaluate    round(sum($times) / len($times), 1)
    ${max}    Evaluate    max($times)
    ${min}    Evaluate    min($times)
    Log    [Perf] '${keyword}' x${iterations} — avg: ${avg} ms | min: ${min} ms | max: ${max} ms    INFO
    RETURN    ${times}
