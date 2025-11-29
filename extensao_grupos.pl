:- multifile tem_papel/2.
:- dynamic  tem_papel/2.

% =====================================
% EXTENSÃO: Grupos / Times
% Usuário herda papéis do(s) seu(s) grupo(s)
% =====================================

% Os fatos:
%   grupo/1, membro_de/2, grupo_tem_papel/2
% estão em entrada.txt.
% Aqui só definimos a regra adicional para tem_papel/2.

% Regra adicional:
% se User é membro de Grupo, e Grupo tem Papel,
% então User também tem esse Papel.

tem_papel(User, Papel) :-
    membro_de(User, Grupo),
    grupo_tem_papel(Grupo, Papel).
