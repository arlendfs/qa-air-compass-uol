*** Settings ***
Documentation     Dynamics Robot Framework Test Suite
Library           FakerLibrary


*** Keywords ***
Criar Dados Uusuario Valido
    ${nome}    FakerLibrary.Name
    ${email}   FakerLibrary.Email
    ${payload}    Create Dictionary    nome=${nome}    email=${email}    password=123456    administrador=true

Criar Usuario 