*** Settings ***
Documentation    Suite de testes de Usuários — fluxos de criação e busca no endpoint /usuarios.
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Suite Setup      Criar Sessão ServeRest
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-04: Cadastrar Novo Usuário Administrador Com Sucesso
    [Documentation]    Um novo usuário com dados válidos deve ser cadastrado com sucesso.
    [Tags]    usuarios    positivo    smoke
    Quando Cadastro Um Novo Usuário
    Então O Cadastro De Usuário Deve Ter Sucesso

CT-05: Tentar Cadastrar Usuário Com E-mail Já Existente
    [Documentation]    Tentar cadastrar com email já existente deve retornar erro de conflito.
    [Tags]    usuarios    negativo
    Dado Que Existe Um Usuário Cadastrado
    Quando Tento Cadastrar Um Usuário Com Email Já Existente
    Então O Cadastro De Usuário Deve Falhar Com    Este email já está sendo usado

CT-06: Buscar Usuário Por ID E Validar Campos Obrigatórios
    [Documentation]    Um usuário cadastrado deve ser encontrado por ID com todos os campos do contrato.
    [Tags]    usuarios    positivo    contrato
    Dado Que Existe Um Usuário Cadastrado
    Quando Busco O Usuário Por ID
    Então Os Dados Do Usuário Devem Estar Corretos
