*** Settings ***
Documentation    Contract testing utilities — JSON Schema validation via jsonschema.
Library    Collections
Library    OperatingSystem
Library    String


*** Variables ***
${SCHEMAS_DIR}    ${CURDIR}/../schemas


*** Keywords ***
Validate Response Against Schema
    [Documentation]    Validates a response body dict against a JSON Schema file.
    ...    Fails with a descriptive message listing every schema violation found.
    [Arguments]    ${response}    ${schema_filename}
    ${schema_path}    Set Variable    ${SCHEMAS_DIR}/${schema_filename}
    ${schema_raw}     Get File    ${schema_path}
    ${schema}         Evaluate    json.loads($schema_raw)    modules=json
    ${body}           Set Variable    ${response.json()}
    ${errors}         Evaluate
    ...    [str(e.message) for e in __import__('jsonschema').Draft7Validator($schema).iter_errors($body)]
    ...    modules=jsonschema
    ${error_count}    Get Length    ${errors}
    IF    ${error_count} > 0
        ${error_summary}    Evaluate    "\\n  - ".join($errors)
        Fail    Schema validation failed for '${schema_filename}' with ${error_count} error(s):\n  - ${error_summary}
    END
    Log    Schema '${schema_filename}' validated successfully.    DEBUG

Validate Required Fields
    [Documentation]    Asserts that every field in the given list exists in the response body.
    [Arguments]    ${response}    @{fields}
    ${body}    Set Variable    ${response.json()}
    FOR    ${field}    IN    @{fields}
        Dictionary Should Contain Key    ${body}    ${field}
        ...    msg=Required field '${field}' is missing from the response body.
    END

Validate No Unexpected Fields
    [Documentation]    Asserts that the response body contains no keys outside the allowed set.
    [Arguments]    ${response}    @{allowed_fields}
    ${body}         Set Variable    ${response.json()}
    ${body_keys}    Get Dictionary Keys    ${body}
    FOR    ${key}    IN    @{body_keys}
        Should Contain    ${allowed_fields}    ${key}
        ...    msg=Unexpected field '${key}' found in response body.
    END

Validate Field Type
    [Documentation]    Asserts that a specific field in the response body matches the expected Python type name.
    ...    Supported type names: str, int, float, bool, list, dict
    [Arguments]    ${response}    ${field}    ${expected_type}
    ${body}     Set Variable    ${response.json()}
    ${value}    Get From Dictionary    ${body}    ${field}
    ${actual}   Evaluate    type($value).__name__
    Should Be Equal As Strings    ${actual}    ${expected_type}
    ...    msg=Field '${field}' expected type '${expected_type}' but got '${actual}'.
