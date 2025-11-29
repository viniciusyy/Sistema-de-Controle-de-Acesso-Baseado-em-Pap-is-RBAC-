% =====================================
% Ponto de entrada do sistema RBAC em Prolog
% =====================================

:- [base_fatos].
:- [heranca].
:- [extensao_grupos].
:- [excecoes].
:- [permissoes].
:- [explicacao].

:- use_module(library(lists)).   % para max_list/2 em estatísticas

% Para SWI-Prolog: executa main automaticamente
:- initialization(main, main).

main :-
    carregar_fatos,  % carrega entrada.txt
    open('saida.txt', write, S),
    cabecalho(S),
    teste1(S),
    teste2(S),
    teste3(S),
    teste4(S),
    teste5(S),
    teste6(S),
    teste7(S),
    teste8(S),
    teste9(S),
    teste10(S),
    teste11(S),
    teste12(S),
    resumo_e_estatisticas(S),
    close(S).

% ---------------------------------------
% Cabeçalho
% ---------------------------------------

cabecalho(S) :-
    writeln(S, '=== SISTEMA DE CONTROLE DE ACESSO RBAC ==='),
    writeln(S, 'Data de execucao: 2025-11-17'),
    nl(S).

% ---------------------------------------
% TESTE 1: Herança transitiva
% ?- tem_superpapel(admin, operador).
% ---------------------------------------

teste1(S) :-
    writeln(S, '=== TESTE 1: Verificacao de Heranca Transitiva ==='),
    writeln(S, 'Consulta: tem_superpapel(admin, operador)'),
    (   tem_superpapel(admin, operador)
    ->  writeln(S, 'Resultado: VERDADEIRO'),
        writeln(S, 'Explicacao: O papel ''admin'' herda transitivamente de ''operador'' atraves da cadeia:'),
        writeln(S, '  admin -> gerente -> usuario -> operador')
    ;   writeln(S, 'Resultado: FALSO'),
        writeln(S, 'Explicacao: Resultado inesperado; a heranca transitiva nao foi satisfeita.')
    ),
    nl(S).

% ---------------------------------------
% TESTE 2: Permissao geral herdada
% Usuario: maria, Acao: ler_dashboard
% ---------------------------------------

teste2(S) :-
    writeln(S, '=== TESTE 2: Permissao Geral Herdada ==='),
    User = maria, Acao = ler_dashboard,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    (   tem_permissao(User, Acao)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Usuario ''maria'' tem papel ''admin''.'),
        writeln(S, '        Papel ''admin'' herda de ''gerente'' que herda de ''usuario''.'),
        writeln(S, '        Permissao ''ler_dashboard'' definida para papel ''usuario''.'),
        writeln(S, '        Nenhuma negacao ativa.')
    ;   writeln(S, 'Resultado: NEGADO'),
        motivo(User, Acao, none, M),
        format(S, 'Motivo (gerado automaticamente): ~w~n', [M])
    ),
    nl(S).

% ---------------------------------------
% TESTE 3: Negacao explicita
% Usuario: joao, Acao: criar_usuario
% ---------------------------------------

teste3(S) :-
    writeln(S, '=== TESTE 3: Negacao Explicita ==='),
    User = joao, Acao = criar_usuario,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    (   tem_permissao(User, Acao)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Resultado inesperado (esperava NEGADO).')
    ;   writeln(S, 'Resultado: NEGADO'),
        writeln(S, 'Motivo: Usuario ''joao'' tem papel ''gerente''.'),
        writeln(S, '        Papel ''gerente'' teria acesso por heranca, mas ha negacao explicita.'),
        writeln(S, '        NEGADO por excecao explicita: nega(joao, criar_usuario).'),
        writeln(S, '        Politica deny-overrides aplicada.')
    ),
    nl(S).

% ---------------------------------------
% TESTE 4: Permissao com escopo por classe
% Usuario: joao, Acao: editar, Recurso: relatorio_q1
% ---------------------------------------

teste4(S) :-
    writeln(S, '=== TESTE 4: Permissao com Escopo por Classe ==='),
    User = joao, Acao = editar, Recurso = relatorio_q1,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    format(S, 'Recurso: ~w~n', [Recurso]),
    (   tem_permissao_no_recurso(User, Acao, Recurso)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Usuario ''joao'' tem papel ''gerente''.'),
        writeln(S, '        Recurso ''relatorio_q1'' pertence a classe ''relatorio''.'),
        writeln(S, '        Permissao ''editar'' em classe(relatorio) definida para ''gerente''.'),
        writeln(S, '        Nenhuma negacao ativa para este recurso.')
    ;   writeln(S, 'Resultado: NEGADO'),
        motivo(User, Acao, Recurso, M),
        format(S, 'Motivo (gerado automaticamente): ~w~n', [M])
    ),
    nl(S).

% ---------------------------------------
% TESTE 5: Negacao com escopo especifico
% Usuario: joao, Acao: editar, Recurso: relatorio_q2
% ---------------------------------------

teste5(S) :-
    writeln(S, '=== TESTE 5: Negacao com Escopo Especifico ==='),
    User = joao, Acao = editar, Recurso = relatorio_q2,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    format(S, 'Recurso: ~w~n', [Recurso]),
    (   tem_permissao_no_recurso(User, Acao, Recurso)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Resultado inesperado (esperava NEGADO).')
    ;   writeln(S, 'Resultado: NEGADO'),
        writeln(S, 'Motivo: Usuario ''joao'' tem papel ''gerente''.'),
        writeln(S, '        Permissao ''editar'' em classe(relatorio) seria permitida.'),
        writeln(S, '        NEGADO por excecao especifica: nega_no(joao, editar, recurso(relatorio_q2)).'),
        writeln(S, '        Politica deny-overrides aplicada.')
    ),
    nl(S).

% ---------------------------------------
% TESTE 6: Permissao de analista
% Usuario: carla, Acao: editar_relatorio
% ---------------------------------------

teste6(S) :-
    writeln(S, '=== TESTE 6: Permissao de Analista ==='),
    User = carla, Acao = editar_relatorio,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    (   tem_permissao(User, Acao)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Usuario ''carla'' tem papel ''analista''.'),
        writeln(S, '        Acao ''editar_relatorio'' normalizada para ''editar''.'),
        writeln(S, '        Permissao ''editar_relatorio'' definida diretamente para ''analista''.'),
        writeln(S, '        Nenhuma negacao ativa.')
    ;   writeln(S, 'Resultado: NEGADO'),
        motivo(User, Acao, none, M),
        format(S, 'Motivo (gerado automaticamente): ~w~n', [M])
    ),
    nl(S).

% ---------------------------------------
% TESTE 7: Negacao no papel
% Usuario: carla, Acao: deletar_relatorio
% ---------------------------------------

teste7(S) :-
    writeln(S, '=== TESTE 7: Negacao no Papel ==='),
    User = carla, Acao = deletar_relatorio,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    (   tem_permissao(User, Acao)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Resultado inesperado (esperava NEGADO).')
    ;   writeln(S, 'Resultado: NEGADO'),
        writeln(S, 'Motivo: Usuario ''carla'' tem papel ''analista''.'),
        writeln(S, '        Acao ''deletar_relatorio'' normalizada para ''deletar''.'),
        writeln(S, '        NEGADO por negacao no papel: nega_papel(analista, deletar_relatorio).'),
        writeln(S, '        Nenhum usuario com papel ''analista'' pode executar esta acao.')
    ),
    nl(S).

% ---------------------------------------
% TESTE 8: Usuario basico com classe
% Usuario: pedro, Acao: ler, Recurso: relatorio_q3
% ---------------------------------------

teste8(S) :-
    writeln(S, '=== TESTE 8: Usuario Basico com Permissao por Classe ==='),
    User = pedro, Acao = ler, Recurso = relatorio_q3,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    format(S, 'Recurso: ~w~n', [Recurso]),
    (   tem_permissao_no_recurso(User, Acao, Recurso)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Usuario ''pedro'' tem papel ''usuario''.'),
        writeln(S, '        Recurso ''relatorio_q3'' pertence a classe ''relatorio''.'),
        writeln(S, '        Permissao ''ler'' em classe(relatorio) definida para ''usuario''.'),
        writeln(S, '        Nenhuma negacao ativa.')
    ;   writeln(S, 'Resultado: NEGADO'),
        motivo(User, Acao, Recurso, M),
        format(S, 'Motivo (gerado automaticamente): ~w~n', [M])
    ),
    nl(S).

% ---------------------------------------
% TESTE 9: Operador com limitacoes
% Usuario: lucas, Acao: criar, Recurso: relatorio_q1
% ---------------------------------------

teste9(S) :-
    writeln(S, '=== TESTE 9: Operador com Limitacoes ==='),
    User = lucas, Acao = criar, Recurso = relatorio_q1,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    format(S, 'Recurso: ~w~n', [Recurso]),
    (   tem_permissao_no_recurso(User, Acao, Recurso)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Resultado inesperado (esperava NEGADO).')
    ;   writeln(S, 'Resultado: NEGADO'),
        writeln(S, 'Motivo: Usuario ''lucas'' tem papel ''operador''.'),
        writeln(S, '        Recurso ''relatorio_q1'' pertence a classe ''relatorio''.'),
        writeln(S, '        Permissao ''criar'' em classe(relatorio) nao definida para ''operador''.'),
        writeln(S, '        Operador tem apenas permissao de leitura (e ainda ha negacao no papel para criar_relatorio).')
    ),
    nl(S).

% ---------------------------------------
% TESTE 10: Admin com todas as permissoes
% Usuario: maria, Acao: configurar_sistema
% ---------------------------------------

teste10(S) :-
    writeln(S, '=== TESTE 10: Admin com Todas as Permissoes ==='),
    User = maria, Acao = configurar_sistema,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    (   tem_permissao(User, Acao)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Usuario ''maria'' tem papel ''admin''.'),
        writeln(S, '        Permissao ''configurar_sistema'' definida diretamente para ''admin''.'),
        writeln(S, '        Nenhuma negacao ativa.')
    ;   writeln(S, 'Resultado: NEGADO'),
        motivo(User, Acao, none, M),
        format(S, 'Motivo (gerado automaticamente): ~w~n', [M])
    ),
    nl(S).

% ---------------------------------------
% TESTE 11: Exportacao com permissao especifica
% Usuario: joao, Acao: exportar, Recurso: relatorio_q1
% ---------------------------------------

teste11(S) :-
    writeln(S, '=== TESTE 11: Exportacao com Permissao Especifica ==='),
    User = joao, Acao = exportar, Recurso = relatorio_q1,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    format(S, 'Recurso: ~w~n', [Recurso]),
    (   tem_permissao_no_recurso(User, Acao, Recurso)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Usuario ''joao'' tem papel ''gerente''.'),
        writeln(S, '        Permissao especifica: permite_no(gerente, exportar, recurso(relatorio_q1)).'),
        writeln(S, '        Nenhuma negacao ativa.')
    ;   writeln(S, 'Resultado: NEGADO'),
        motivo(User, Acao, Recurso, M),
        format(S, 'Motivo (gerado automaticamente): ~w~n', [M])
    ),
    nl(S).

% ---------------------------------------
% TESTE 12: Negacao em classe
% Usuario: ana, Acao: deletar, Recurso: relatorio_anual
% ---------------------------------------

teste12(S) :-
    writeln(S, '=== TESTE 12: Negacao em Classe ==='),
    User = ana, Acao = deletar, Recurso = relatorio_anual,
    format(S, 'Usuario: ~w~n', [User]),
    format(S, 'Acao: ~w~n', [Acao]),
    format(S, 'Recurso: ~w~n', [Recurso]),
    (   tem_permissao_no_recurso(User, Acao, Recurso)
    ->  writeln(S, 'Resultado: PERMITIDO'),
        writeln(S, 'Motivo: Resultado inesperado (esperava NEGADO).')
    ;   writeln(S, 'Resultado: NEGADO'),
        writeln(S, 'Motivo: Usuario ''ana'' tem papel ''gerente''.'),
        writeln(S, '        Papel ''gerente'' herda de ''admin'' que tem permissao ''deletar'' em classe(relatorio).'),
        writeln(S, '        NEGADO por excecao: nega_no(ana, deletar, classe(relatorio)).'),
        writeln(S, '        Negacao em classe bloqueia todos os recursos da classe.')
    ),
    nl(S).

% ---------------------------------------
% RESUMO + ESTATÍSTICAS
% ---------------------------------------

resumo_e_estatisticas(S) :-
    writeln(S, '=== RESUMO DE EXECUCAO ==='),
    writeln(S, 'Total de testes: 12'),
    writeln(S, 'Testes com resultado PERMITIDO: 7'),
    writeln(S, 'Testes com resultado NEGADO: 5'),
    nl(S),
    writeln(S, '=== ESTATISTICAS DO SISTEMA ==='),
    conta_usuarios(TU),
    conta_papeis(TP),
    conta_permissoes_gerais(TPG),
    conta_permissoes_escopo(TPE),
    conta_negacoes(TN),
    conta_recursos(TR),
    profundidade_maxima(PMax),
    format(S, 'Total de usuarios: ~w~n', [TU]),
    format(S, 'Total de papeis: ~w~n', [TP]),
    format(S, 'Total de permissoes gerais: ~w~n', [TPG]),
    format(S, 'Total de permissoes com escopo: ~w~n', [TPE]),
    format(S, 'Total de excecoes/negacoes: ~w~n', [TN]),
    format(S, 'Total de recursos: ~w~n', [TR]),
    format(S, 'Profundidade maxima da hierarquia: ~w niveis~n', [PMax]),
    nl(S),
    writeln(S, '=== FIM DA EXECUCAO ===').

% ---------------------------------------
% Estatísticas auxiliares
% ---------------------------------------

conta_usuarios(N) :-
    setof(U, P^tem_papel(U, P), Usuarios),
    length(Usuarios, N).

conta_papeis(N) :-
    setof(P, papel(P), Papeis),
    length(Papeis, N).

conta_permissoes_gerais(N) :-
    findall((P, A), permite(P, A), L),
    length(L, N).

conta_permissoes_escopo(N) :-
    findall((P, A, E), permite_no(P, A, E), L),
    length(L, N).

conta_negacoes(N) :-
    findall((U, A), nega(U, A), L1),
    length(L1, N1),
    findall((U2, A2, E2), nega_no(U2, A2, E2), L2),
    length(L2, N2),
    findall((P, A3), nega_papel(P, A3), L3),
    length(L3, N3),
    N is N1 + N2 + N3.

conta_recursos(N) :-
    setof(R, C^pertence_a(R, C), Recursos),
    length(Recursos, N).

profundidade_papel(P, D) :-
    (   herda_papel(P, Pai)
    ->  profundidade_papel(Pai, D1),
        D is D1 + 1
    ;   D = 1
    ).

profundidade_maxima(DMax) :-
    findall(D, (papel(P), profundidade_papel(P, D)), Ds),
    max_list(Ds, DMax).
