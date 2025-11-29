% =====================================
% Normalização de ações e verificação de permissão
% =====================================

% ACAO_BASE/2
% acao_base(AcaoOriginal, AcaoBase).
% Se existir acao_equivalente/2, normaliza para a base; senão, mantém.

acao_base(Acao, Base) :-
    (   acao_equivalente(Acao, B)
    ->  Base = B
    ;   Base = Acao
    ).


% TEM_PERMISSAO/2
% tem_permissao(User, AcaoOriginal).
% Verifica permissão geral (sem recurso), com:
% - normalização de ação
% - herança de papéis
% - deny-overrides (depois que o usuário já está ligado)

tem_permissao(User, Acao) :-
    acao_base(Acao, Base),
    % 1) liga o usuário aos papéis (diretos ou via grupo)
    tem_papel(User, Papel),
    tem_superpapel(Papel, PapelEfetivo),
    % 2) agora sim checa se NÃO há negação para ESTE usuário
    \+ negacao_ativa(User, Base),
    % 3) procura uma permissão cujo "Base" coincida
    permite(PapelEfetivo, AcaoPerm),
    acao_base(AcaoPerm, Base).


% TEM_PERMISSAO_NO_RECURSO/3
% tem_permissao_no_recurso(User, AcaoOriginal, Recurso)
% Verifica permissão com escopo, considerando 3 níveis:
% 1) recurso específico
% 2) classe do recurso
% 3) permissão geral (fallback)

tem_permissao_no_recurso(User, Acao, Recurso) :-
    acao_base(Acao, Base),
    % 1) liga o usuário a pelo menos um papel (para garantir User ligado)
    tem_papel(User, _AlgumPapel),
    % 2) deny-overrides geral e específico para ESTE usuário
    \+ negacao_ativa(User, Base),
    \+ negacao_ativa_no(User, Base, Recurso),
    % 3) tenta permissões em três níveis
    (
        % (a) permissão específica no recurso
        tem_papel(User, Papel1),
        tem_superpapel(Papel1, PapelEf1),
        permite_no(PapelEf1, AcaoPerm1, recurso(Recurso)),
        acao_base(AcaoPerm1, Base)
    ;
        % (b) permissão por classe do recurso
        pertence_a(Recurso, Classe),
        tem_papel(User, Papel2),
        tem_superpapel(Papel2, PapelEf2),
        permite_no(PapelEf2, AcaoPerm2, classe(Classe)),
        acao_base(AcaoPerm2, Base)
    ;
        % (c) fallback: permissão geral (já usa deny-overrides internamente)
        tem_permissao(User, Acao)
    ).
