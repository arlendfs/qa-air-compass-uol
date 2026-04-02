*** Settings ***
Documentation    Data loader utility — reads JSON test data files and exposes them as Robot variables.
Library    Collections
Library    OperatingSystem
Library    String


*** Variables ***
${DATA_DIR}    ${CURDIR}/../data


*** Keywords ***
Load Test Data
    [Documentation]    Loads a JSON data file and returns it as a Robot dictionary.
    ...    Usage: ${data}    Load Test Data    users.json
    [Arguments]    ${filename}
    ${raw}    Get File    ${DATA_DIR}/${filename}
    ${data}   Evaluate    json.loads($raw)    modules=json
    RETURN    ${data}

Get Test Data Field
    [Documentation]    Loads a JSON file and returns a specific top-level key as a dictionary.
    ...    Usage: ${payload}    Get Test Data Field    users.json    valid_admin
    [Arguments]    ${filename}    ${key}
    ${data}     Load Test Data    ${filename}
    ${field}    Get From Dictionary    ${data}    ${key}
    RETURN      ${field}

Generate Dynamic User Payload
    [Documentation]    Builds a user payload from the data file, injecting a unique email at runtime.
    ...    Merges the static data key with a freshly generated email to avoid conflicts.
    [Arguments]    ${data_key}=valid_admin
    ${base}     Get Test Data Field    users.json    ${data_key}
    ${sufixo}    Generate Random String    length=8    chars=[LETTERS][NUMBERS]
    ${sufixo}    Convert To Lower Case    ${sufixo}
    ${email}     Set Variable    test_${sufixo}@emailteste.com
    Set To Dictionary    ${base}    email=${email}
    RETURN    ${base}

Generate Dynamic Product Payload
    [Documentation]    Builds a product payload from the data file, injecting a unique name at runtime.
    [Arguments]    ${data_key}=valid
    ${base}     Get Test Data Field    products.json    ${data_key}
    ${sufixo}   Generate Random String    length=8    chars=[LETTERS][NUMBERS]
    ${nome}     Set Variable    Produto ${sufixo}
    Set To Dictionary    ${base}    nome=${nome}
    RETURN    ${base}
