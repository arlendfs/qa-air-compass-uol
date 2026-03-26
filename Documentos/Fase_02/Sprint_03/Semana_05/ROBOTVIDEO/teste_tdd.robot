*** Test Cases ***
Cenário: GET Todos Os Usuários 200
    GET    Endpoint    /usuarios
    Validar Todos Os Usuarios na Response
    Validar Status Code    200

Cenário: GET Usuário Específico
    GET    Endpoint    /usuarios/1
    Validar O Usuario Com ID "GGTtwearsdw223"
    Validar Status Code    200

Cenário: POST Criar Novo Usuário
    Criar Usuário Dinâmico
    POST    Usuário Dinâmico No Endpoint   /usuarios
    Validar Status Code    201
    Validar Mensagem    "Cadastro realizado com sucesso"
    
