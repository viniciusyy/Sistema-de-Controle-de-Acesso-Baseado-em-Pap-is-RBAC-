% =====================================
% Negações gerais e com escopo (deny-overrides)
% =====================================

% NEGACAO_ATIVA/2
% negacao_ativa(User, AcaoBase)
% Verdadeiro se há alguma negação geral (por usuário ou por papel).

negacao_ativa(User, AcaoBase) :-
    % 1) Negação direta no usuário (já em forma base ou não)
    nega(User, AcaoBase).

negacao_ativa(User, AcaoBase) :-
    % 2) Negação em qualquer papel efetivo do usuário.
    %    Aqui permitimos que a negação esteja em forma "criar_relatorio"
    %    e normalizamos para comparar com AcaoBase.
    tem_papel(User, Papel),
    tem_superpapel(Papel, PapelEfetivo),
    nega_papel(PapelEfetivo, AcaoNegada),
    acao_base(AcaoNegada, AcaoBase).


% NEGACAO_ATIVA_NO/3
% negacao_ativa_no(User, AcaoBase, Recurso)
% Verdadeiro se há negação no recurso específico, na classe do recurso
% ou no papel.

negacao_ativa_no(User, AcaoBase, Recurso) :-
    % 1) Negação específica no recurso
    nega_no(User, AcaoBase, recurso(Recurso)).

negacao_ativa_no(User, AcaoBase, Recurso) :-
    % 2) Negação na classe do recurso
    pertence_a(Recurso, Classe),
    nega_no(User, AcaoBase, classe(Classe)).

negacao_ativa_no(User, AcaoBase, _) :-
    % 3) Negação geral por papel (recurso não importa aqui)
    tem_papel(User, Papel),
    tem_superpapel(Papel, PapelEfetivo),
    nega_papel(PapelEfetivo, AcaoNegada),
    acao_base(AcaoNegada, AcaoBase).

