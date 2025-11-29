% =====================================
% Responsável por carregar a base de fatos de entrada.txt
% =====================================

carregar_fatos :-
    % carrega os fatos do arquivo de entrada
    consult('entrada.txt').

