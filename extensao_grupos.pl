% =====================================
% Extensao obrigatoria: grupos / times
% Usuarios herdam papeis dos grupos
% =====================================

:- multifile tem_papel/2.


:- dynamic grupo/1.
:- dynamic membro_de/2.
:- dynamic grupo_tem_papel/2.

% -------------------------------------
% Exemplos de grupos (extensao)
% (podem ser usados na apresentacao)
% -------------------------------------

grupo(ti).
grupo(financeiro).
grupo(rh).

membro_de(joao, ti).
membro_de(maria, ti).
membro_de(carla, financeiro).
membro_de(pedro, rh).
membro_de(ana, financeiro).
% lucas e roberto ficam apenas com os papeis diretos de entrada.txt

grupo_tem_papel(ti,         gerente).
grupo_tem_papel(financeiro, analista).
grupo_tem_papel(rh,         usuario).

% Usuario herda papeis de seus grupos
tem_papel(User, Papel) :-
    membro_de(User, Grupo),
    grupo_tem_papel(Grupo, Papel).
