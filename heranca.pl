% =====================================
% Hierarquia e fecho transitivo de papéis
% =====================================

% tem_superpapel(Papel, SuperPapel).
% - Reflexivo: um papel é superpapel de si mesmo
% - Transitivo: herda_papel(P, Pai), tem_superpapel(Pai, S)

tem_superpapel(P, S) :-
    % caso base: reflexivo
    P = S.

tem_superpapel(P, S) :-
    % caso recursivo: P herda de Pai, e Pai tem superpapel S
    herda_papel(P, Pai),
    tem_superpapel(Pai, S).
