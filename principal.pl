% =====================================
% principal.pl
% Ponto de entrada do sistema RBAC em Prolog
% =====================================

:- [base_fatos].
:- [heranca].
:- [extensao_grupos].
:- [excecoes].
:- [permissoes].
:- [explicacao].

% Para SWI-Prolog: executa main automaticamente
:- initialization(main, main).

main :-
    carregar_fatos,  % carrega entrada.txt
    open('saida.txt', write, S),
    writeln(S, '=== Resultados do Sistema RBAC em Prolog ==='),
    writeln(S, ''),

    % 1) Herança de papéis
    testa(S, 'tem_superpapel(gerente, usuario)', tem_superpapel(gerente, usuario)),
    testa(S, 'tem_superpapel(admin, usuario)',   tem_superpapel(admin, usuario)),

    % 2) Permissões gerais
    testa(S, 'tem_permissao(maria, criar_usuario)',  tem_permissao(maria, criar_usuario)),
    testa(S, 'tem_permissao(joao, criar_usuario)',   tem_permissao(joao, criar_usuario)),
    testa(S, 'tem_permissao(joao, aprovar_despesa)', tem_permissao(joao, aprovar_despesa)),

    % 3) Permissões com escopo em relatório
    testa(S,
          'tem_permissao_no_recurso(joao, editar, relatorio_q1)',
          tem_permissao_no_recurso(joao, editar, relatorio_q1)),
    testa(S,
          'tem_permissao_no_recurso(joao, editar, relatorio_q2)',
          tem_permissao_no_recurso(joao, editar, relatorio_q2)),
    testa(S,
          'tem_permissao_no_recurso(joao, exportar, relatorio_q1)',
          tem_permissao_no_recurso(joao, exportar, relatorio_q1)),

    % 4) Permissões do analista
    testa(S,
          'tem_permissao(carla, editar_relatorio)',
          tem_permissao(carla, editar_relatorio)),
    testa(S,
          'tem_permissao(carla, deletar_relatorio)',
          tem_permissao(carla, deletar_relatorio)),

    % 5) Usuário básico herdando leitura de classe
    testa(S,
          'tem_permissao_no_recurso(pedro, ler, relatorio_q2)',
          tem_permissao_no_recurso(pedro, ler, relatorio_q2)),

    % 6) Quem pode criar usuário?
    writeln(S, 'Consulta: tem_permissao(Usuario, criar_usuario).'),
    findall(Usuario, tem_permissao(Usuario, criar_usuario), ListaUsuarios),
    format(S, '  Usuarios com permissao: ~w~n~n', [ListaUsuarios]),

    % 7) Motivos
    escreve_motivo(S, joao,  criar_usuario, none),
    escreve_motivo(S, joao,  editar, relatorio_q2),
    escreve_motivo(S, maria, deletar, relatorio_q1),

    % 8) Papéis efetivos
    escreve_papeis(S, joao),
    escreve_papeis(S, maria),

    close(S).

% -------------------------------------------------
% Utilitários de escrita em saida.txt
% -------------------------------------------------

testa(S, NomeConsulta, Goal) :-
    (   call(Goal)
    ->  Resultado = true
    ;   Resultado = false
    ),
    format(S, '~w => ~w~n', [NomeConsulta, Resultado]).

escreve_motivo(S, User, Acao, Recurso) :-
    motivo(User, Acao, Recurso, Motivo),
    format(S, 'motivo(~w, ~w, ~w, M) => M = ~w~n',
           [User, Acao, Recurso, Motivo]).

escreve_papeis(S, User) :-
    papeis_efetivos(User, Papeis),
    format(S, 'papeis_efetivos(~w, P) => P = ~w~n',
           [User, Papeis]).


% ------------------------------------------
% Exemplos de consultas usadas para testes:
%
% ?- tem_superpapel(gerente, usuario).
% true.
%
% ?- tem_superpapel(admin, usuario).
% true.
%
% ?- tem_permissao(maria, criar_usuario).
% true.   % maria é admin
%
% ?- tem_permissao(joao, criar_usuario).
% false.  % nega(joao, criar_usuario)
%
% ?- tem_permissao_no_recurso(joao, editar, relatorio_q1).
% true.   % gerente, classe(relatorio)
%
% ?- tem_permissao_no_recurso(joao, editar, relatorio_q2).
% false.  % nega_no(joao, editar, recurso(relatorio_q2))
%
% ?- motivo(joao, editar, relatorio_q2, M).
% M = negado_no_recurso.
%
% ?- papeis_efetivos(maria, P).
% P = [admin,gerente,usuario].
% ------------------------------------------
