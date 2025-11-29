% =====================================
% excecoes.pl
% Negações gerais e com escopo (deny-overrides)
% =====================================

% NEGACAO_ATIVA/2
% negacao_ativa(User, AcaoBase)

negacao_ativa(User, AcaoBase) :-
    % 1) Negação direta no usuário
    nega(User, AcaoBase).

negacao_ativa(User, AcaoBase) :-
    % 2) Negação em qualquer papel efetivo do usuário
    tem_papel(User, Papel),
    tem_superpapel(Papel, PapelEfetivo),
    nega_papel(PapelEfetivo, AcaoBase).


% NEGACAO_ATIVA_NO/3
% negacao_ativa_no(User, AcaoBase, Recurso)

negacao_ativa_no(User, AcaoBase, Recurso) :-
    % 1) Negação específica no recurso
    nega_no(User, AcaoBase, recurso(Recurso)).

negacao_ativa_no(User, AcaoBase, Recurso) :-
    % 2) Negação na classe do recurso
    pertence_a(Recurso, Classe),
    nega_no(User, AcaoBase, classe(Classe)).

negacao_ativa_no(User, AcaoBase, _) :-
    % 3) Negação geral por papel (o recurso não importa aqui)
    tem_papel(User, Papel),
    tem_superpapel(Papel, PapelEfetivo),
    nega_papel(PapelEfetivo, AcaoBase).
