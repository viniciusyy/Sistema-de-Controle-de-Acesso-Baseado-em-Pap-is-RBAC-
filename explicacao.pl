% =====================================
% Predicados de explicação e auditoria
% =====================================

% MOTIVO/4
% motivo(User, AcaoOriginal, RecursoOuNone, Motivo).

motivo(User, Acao, none, Motivo) :-
    acao_base(Acao, Base),
    (   negacao_ativa(User, Base)
    ->  Motivo = negado_por_excecao
    ;   tem_permissao(User, Acao)
    ->  Motivo = permitido_por_papel
    ;   Motivo = ausente_de_permissao
    ).

motivo(User, Acao, Recurso, Motivo) :-
    Recurso \= none,
    acao_base(Acao, Base),
    (   negacao_ativa_no(User, Base, Recurso)
    ->  Motivo = negado_no_recurso
    ;   tem_permissao_no_recurso(User, Acao, Recurso)
    ->  Motivo = permitido_por_classe_ou_instancia
    ;   Motivo = ausente_de_permissao_no_escopo
    ).


% PAPEIS_EFETIVOS/2
% papeis_efetivos(Usuario, ListaPapeisOrdenada).

papeis_efetivos(Usuario, Lista) :-
    findall(PapelEf,
            ( tem_papel(Usuario, Papel),
              tem_superpapel(Papel, PapelEf)
            ),
            L),
    sort(L, Lista).


% EXPLICACAO_SOLUCAO/4
% explicacao_solucao(User, Acao, RecursoOuNone, Texto).
% Gera um texto amigável apenas quando o acesso é permitido.

explicacao_solucao(User, Acao, none, Texto) :-
    motivo(User, Acao, none, Motivo),
    (   Motivo = permitido_por_papel
    ->  format(atom(Texto),
               'Ação ~w foi PERMITIDA para ~w via papéis efetivos.',
               [Acao, User])
    ;   fail  % só sucesso quando permitido
    ).

explicacao_solucao(User, Acao, Recurso, Texto) :-
    Recurso \= none,
    motivo(User, Acao, Recurso, Motivo),
    (   Motivo = permitido_por_classe_ou_instancia
    ->  format(atom(Texto),
               'Ação ~w foi PERMITIDA para ~w no recurso ~w (classe/instância).',
               [Acao, User, Recurso])
    ;   fail
    ).


% MOTIVO_FALHA/4
% motivo_falha(User, Acao, RecursoOuNone, Texto).
% Gera texto amigável apenas quando o acesso é negado.

motivo_falha(User, Acao, none, Texto) :-
    motivo(User, Acao, none, Motivo),
    (   Motivo = negado_por_excecao
    ->  format(atom(Texto),
               'Ação ~w foi NEGADA para ~w devido a negação explícita (deny-overrides).',
               [Acao, User])
    ;   Motivo = ausente_de_permissao
    ->  format(atom(Texto),
               'Ação ~w foi NEGADA para ~w por ausência de permissão geral.',
               [Acao, User])
    ;   fail
    ).

motivo_falha(User, Acao, Recurso, Texto) :-
    Recurso \= none,
    motivo(User, Acao, Recurso, Motivo),
    (   Motivo = negado_no_recurso
    ->  format(atom(Texto),
               'Ação ~w foi NEGADA para ~w no recurso ~w por negação específica (deny-overrides).',
               [Acao, User, Recurso])
    ;   Motivo = ausente_de_permissao_no_escopo
    ->  format(atom(Texto),
               'Ação ~w foi NEGADA para ~w no recurso ~w por ausência de permissão nesse escopo.',
               [Acao, User, Recurso])
    ;   fail
    ).
