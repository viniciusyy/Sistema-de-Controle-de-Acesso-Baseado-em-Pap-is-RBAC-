**Tema:** 🔐 Sistema de Controle de Acesso Baseado em Papéis (RBAC)

---

## 🎯 Objetivo

Modelar em **Prolog** um sistema de controle de acesso com:

1. **Papéis hierárquicos** (ex.: `admin` > `gerente` > `usuario`)
2. **Permissões** por ação e **escopo de recurso**:
   - Permissões gerais: `permite(Papel, Acao)`
   - Permissões com escopo: `permite_no(Papel, Acao, RecursoOuClasse)`
3. **Herança de papéis** e **herança de permissões** (fecho transitivo)
4. **Exceções/negações** que podem **sobrepor** permissões herdadas (política **deny-overrides**)
5. **Escopos de recurso**: classes (ex.: `relatorio/*`) e instâncias (ex.: `relatorio_q1`)

O sistema deve responder consultas como:

```prolog
tem_permissao(joao, editar_relatorio).
tem_permissao_no_recurso(joao, editar, relatorio_q1).
motivo(joao, editar, relatorio_q2, Motivo).
```

---

## 🧩 Descrição do Problema

Você é o **arquiteto de segurança** responsável por implementar o controle de acesso de uma organização.

A organização possui uma hierarquia de papéis (admin, gerente, usuário, analista) onde papéis superiores herdam permissões de papéis inferiores. Cada papel tem permissões gerais (ex.: aprovar despesas) e permissões específicas por recurso (ex.: editar relatórios).

Implemente um sistema lógico que:
- Modele a hierarquia de papéis com herança transitiva
- Atribua papéis a usuários
- Defina permissões gerais e com escopo de recurso
- Implemente exceções (negações) que sobrepõem permissões herdadas
- Resolva consultas de acesso considerando toda a cadeia de herança
- Explique as decisões de acesso (por que foi permitido ou negado)

---

## 🎯 Objetivos de Aprendizagem

- Modelar hierarquias e herança usando o paradigma lógico
- Utilizar fatos e regras para expressar políticas de acesso
- Implementar recursão para fecho transitivo de herança
- Criar predicados explicativos para decisões de acesso
- Aplicar negação como falha para exceções
- Organizar o sistema em múltiplos arquivos

---

## 🧩 Base de Fatos (Exemplo Didático)

### Papéis e Herança
```prolog
% =========================
% PAPÉIS E HERANÇA
% =========================
papel(admin).
papel(gerente).
papel(usuario).
papel(analista).

% Hierarquia: admin > gerente > usuario ; analista é paralelo
herda_papel(admin, gerente).
herda_papel(gerente, usuario).
```

### Usuários
```prolog
% =========================
% USUÁRIOS
% =========================
tem_papel(joao, gerente).
tem_papel(maria, admin).
tem_papel(carla, analista).
tem_papel(pedro, usuario).
```

### Permissões Gerais
```prolog
% =========================
% PERMISSÕES GERAIS (sem escopo)
% permite(Papel, Acao)
% =========================
permite(usuario, ler_dashboard).
permite(gerente, aprovar_despesa).
permite(admin, criar_usuario).

% Analista tem leitura/edição de relatórios por função
permite(analista, ler_relatorio).
permite(analista, editar_relatorio).
```

### Permissões com Escopo
```prolog
% =========================
% PERMISSÕES COM ESCOPO
% permite_no(Papel, Acao, RecursoOuClasse)
% classe de recurso: relatorio/* ; instância: relatorio_q1
% =========================
permite_no(usuario, ler, classe(relatorio)).
permite_no(gerente, editar, classe(relatorio)).
permite_no(admin, deletar, classe(relatorio)).
permite_no(gerente, exportar, recurso(relatorio_q1)).   % exceção positiva pontual
```

### Recursos e Classes
```prolog
% =========================
% RECURSOS E SUAS CLASSES
% =========================
pertence_a(relatorio_q1, relatorio).
pertence_a(relatorio_q2, relatorio).
pertence_a(planilha_financeira, planilha).
```

### Exceções e Negações
```prolog
% =========================
% EXCEÇÕES / NEGAÇÕES
% negam permissões (deny-overrides)
% =========================
nega(joao, criar_usuario).                         % joao não pode, mesmo que herde
nega_no(joao, editar, recurso(relatorio_q2)).     % joao não pode editar o q2
nega_papel(analista, deletar_relatorio).          % ninguém com analista pode deletar_relatorio
```

### Sinônimos de Ações (Opcional)
```prolog
% =========================
% SINÔNIMOS DE AÇÕES (opcional)
% =========================
acao_equivalente(editar_relatorio, editar).
acao_equivalente(ler_relatorio, ler).
acao_equivalente(deletar_relatorio, deletar).
```

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (papéis, usuários, permissões, exceções, recursos)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos e a base de dados
- **`heranca.pl`**: Predicados relacionados à herança de papéis
- **`permissoes.pl`**: Predicados de verificação de permissões
- **`excecoes.pl`**: Predicados de negação e deny-overrides
- **`explicacao.pl`**: Predicados explicativos

### Arquivo de Saída
- **`saida.txt`**: Resultados das consultas e explicações das decisões

---

## 🧱 Tarefas Obrigatórias

### 1. Herança de Papéis

#### 1.1. `tem_superpapel/2` - Fecho Transitivo de Herança
```prolog
% ============================================
% TEM_SUPERPAPEL/2
% ============================================
% Descrição: Implementa o fecho transitivo e reflexivo da relação de herança de
%            papéis. Um papel herda permissões de todos os seus ancestrais na
%            hierarquia.
%
% Parâmetros:
%   - P: átomo representando o papel
%   - S: átomo representando o superpapel (ancestral)
%
% Comportamento:
%   - Caso base (reflexivo): P é superpapel de si mesmo
%   - Caso recursivo (transitivo): P herda de Pai, Pai herda de S → P herda de S
%   - Permite navegar por toda a hierarquia de papéis
%   - Usa recursão para subir na árvore de herança
%
% Hierarquia típica:
%   admin → gerente → analista → usuario
%   admin herda permissões de todos abaixo
%
% Exemplos de uso:
%   ?- tem_superpapel(admin, admin).
%   true.  % reflexivo
%
%   ?- tem_superpapel(analista, gerente).
%   true.  % herança direta
%
%   ?- tem_superpapel(analista, admin).
%   true.  % herança transitiva
%
tem_superpapel(P, S).
```

### 2. Normalização de Ações

#### 2.1. `acao_base/2` - Normalização de Sinônimos
```prolog
% ============================================
% ACAO_BASE/2
% ============================================
% Descrição: Normaliza ações para sua forma base, tratando sinônimos. Permite
%            que diferentes nomes de ações sejam tratados como equivalentes.
%
% Parâmetros:
%   - Acao: átomo representando a ação original
%   - Base: átomo representando a ação normalizada (saída)
%
% Comportamento:
%   - Se existe acao_equivalente(Acao, B): retorna B
%   - Caso contrário: retorna a própria Acao
%   - Usa if-then-else (->)
%
% Sinônimos típicos:
%   - visualizar ≡ ler
%   - modificar ≡ editar
%   - remover ≡ deletar
%
% Exemplos de uso:
%   ?- acao_base(visualizar, B).
%   B = ler.  % normaliza sinônimo
%
%   ?- acao_base(ler, B).
%   B = ler.  % já é forma base
%
acao_base(Acao, Base).
```

### 3. Verificação de Exceções (Deny-Overrides)

#### 3.1. `negacao_ativa/2` - Negação Geral
```prolog
% ============================================
% NEGACAO_ATIVA/2
% ============================================
% Descrição: Verifica se há uma negação ativa (deny) para uma ação, sem escopo
%            de recurso. Implementa política deny-overrides: negações têm
%            precedência sobre permissões.
%
% Parâmetros:
%   - User: átomo identificando o usuário
%   - AcaoBase: átomo representando a ação normalizada
%
% Comportamento:
%   - Verifica duas fontes de negação:
%     1. Negação direta no usuário: nega(User, AcaoBase)
%     2. Negação no papel do usuário: nega_papel(P, AcaoBase)
%   - Usa disjunção (;) - basta uma fonte para negar
%   - Sucede se houver qualquer negação ativa
%
% Política deny-overrides:
%   - Negações sempre prevalecem sobre permissões
%   - Usado para revogar permissões específicas
%   - Essencial para segurança
%
% Exemplos de uso:
%   ?- negacao_ativa(alice, deletar).
%   true.  % alice tem negação para deletar
%
%   ?- negacao_ativa(bob, ler).
%   false.  % bob não tem negação para ler
%
negacao_ativa(User, AcaoBase).
```

#### 3.2. `negacao_ativa_no/3` - Negação com Escopo de Recurso
```prolog
% ============================================
% NEGACAO_ATIVA_NO/3
% ============================================
% Descrição: Verifica se há uma negação ativa para uma ação em um recurso
%            específico. Considera negações em três níveis: recurso, classe e papel.
%
% Parâmetros:
%   - User: átomo identificando o usuário
%   - AcaoBase: átomo representando a ação normalizada
%   - Recurso: átomo identificando o recurso específico
%
% Comportamento:
%   - Verifica três fontes de negação (em ordem de especificidade):
%     1. Negação no recurso específico: nega_no(User, AcaoBase, recurso(Recurso))
%     2. Negação na classe do recurso: nega_no(User, AcaoBase, classe(Classe))
%     3. Negação no papel (global): nega_papel(P, AcaoBase)
%   - Usa disjunção (;) - basta uma fonte para negar
%   - Negações mais específicas têm precedência
%
% Hierarquia de especificidade:
%   1. Recurso específico (mais específico)
%   2. Classe de recursos
%   3. Papel (mais geral)
%
% Exemplos de uso:
%   ?- negacao_ativa_no(alice, deletar, doc1).
%   true.  % alice não pode deletar doc1
%
%   ?- negacao_ativa_no(bob, editar, doc2).
%   false.  % bob não tem negação para editar doc2
%
negacao_ativa_no(User, AcaoBase, Recurso).
```

### 4. Permissão Geral (Sem Escopo)

#### 4.1. `tem_permissao/2` - Verificação de Permissão Geral
```prolog
% ============================================
% TEM_PERMISSAO/2
% ============================================
% Descrição: Verifica se um usuário tem permissão para executar uma ação geral
%            (sem escopo de recurso específico). Implementa política deny-overrides
%            e herança de papéis.
%
% Parâmetros:
%   - User: átomo identificando o usuário
%   - Acao: átomo representando a ação
%
% Comportamento:
%   - Passo 1: Normaliza a ação (trata sinônimos)
%   - Passo 2: Verifica que NÃO há negação ativa (deny-overrides)
%   - Passo 3: Obtém papel do usuário
%   - Passo 4: Verifica permissão:
%     * Permissão direta no papel: permite(P, A)
%     * OU permissão em superpapel: permite(S, A) onde P herda de S
%   - Todas as condições devem ser satisfeitas
%
% Política de acesso:
%   - Deny-overrides: negações prevalecem
%   - Herança: papéis herdam permissões de ancestrais
%   - Least privilege: sem permissão explícita = negado
%
% Exemplos de uso:
%   ?- tem_permissao(alice, ler).
%   true.  % alice tem permissão para ler
%
%   ?- tem_permissao(alice, deletar).
%   false.  % alice tem negação para deletar
%
%   ?- tem_permissao(bob, editar).
%   true.  % bob herda permissão de seu papel
%
tem_permissao(User, Acao).
```

### 5. Permissão com Escopo de Recurso

#### 5.1. `tem_permissao_no_recurso/3` - Verificação com Escopo
```prolog
% ============================================
% TEM_PERMISSAO_NO_RECURSO/3
% ============================================
% Descrição: Verifica se um usuário tem permissão para executar uma ação em um
%            recurso específico. Considera permissões em três níveis: recurso,
%            classe e geral. Implementa deny-overrides e herança.
%
% Parâmetros:
%   - User: átomo identificando o usuário
%   - Acao: átomo representando a ação
%   - Recurso: átomo identificando o recurso específico
%
% Comportamento:
%   - Passo 1: Normaliza a ação
%   - Passo 2: Verifica que NÃO há negação geral
%   - Passo 3: Verifica que NÃO há negação específica no recurso
%   - Passo 4: Obtém papel do usuário
%   - Passo 5: Verifica permissão em três níveis (ordem de especificidade):
%     a) Permissão específica para o recurso: permite_no(P, A, recurso(Recurso))
%     b) Permissão por classe do recurso: permite_no(P, A, classe(Classe))
%        - Considera herança de papéis
%     c) Fallback: permissão geral: permite(P, A)
%        - Considera herança de papéis
%
% Hierarquia de permissões:
%   1. Recurso específico (mais específico)
%   2. Classe de recursos
%   3. Permissão geral (mais geral)
%
% Política de acesso:
%   - Deny-overrides em dois níveis (geral e recurso)
%   - Herança de papéis em todos os níveis
%   - Fallback para permissão geral se não houver específica
%
% Exemplos de uso:
%   ?- tem_permissao_no_recurso(alice, ler, doc1).
%   true.  % alice pode ler doc1
%
%   ?- tem_permissao_no_recurso(alice, deletar, doc1).
%   false.  % alice tem negação para deletar doc1
%
%   ?- tem_permissao_no_recurso(bob, editar, doc2).
%   true.  % bob pode editar doc2 (via classe ou geral)
%
tem_permissao_no_recurso(User, Acao, Recurso).
```

### 6. Predicados Explicativos

#### 6.1. `motivo/4` - Explicação de Decisão de Acesso
```prolog
% ============================================
% MOTIVO/4
% ============================================
% Descrição: Explica por que uma decisão de acesso foi permitida ou negada,
%            fornecendo um motivo estruturado. Essencial para auditoria e debugging.
%
% Parâmetros:
%   - User: átomo identificando o usuário
%   - Acao: átomo representando a ação
%   - Recurso: átomo identificando o recurso (ou 'none' para acesso geral)
%   - Motivo: átomo representando o motivo da decisão (saída)
%
% Comportamento:
%   - Normaliza a ação
%   - Verifica se é acesso geral (Recurso == none) ou específico
%   - **Caso 1: Acesso geral (Recurso == none)**
%     * Se há negação ativa → negado_por_excecao
%     * Senão, se tem permissão → permitido_por_papel
%     * Senão → ausente_de_permissao
%   - **Caso 2: Acesso a recurso específico**
%     * Se há negação no recurso → negado_no_recurso
%     * Senão, se tem permissão no recurso → permitido_por_classe_ou_instancia
%     * Senão → ausente_de_permissao_no_escopo
%
% Motivos possíveis:
%   - negado_por_excecao: negação explícita (deny-overrides)
%   - negado_no_recurso: negação específica no recurso
%   - permitido_por_papel: permissão via papel (geral)
%   - permitido_por_classe_ou_instancia: permissão via recurso/classe
%   - ausente_de_permissao: sem permissão geral
%   - ausente_de_permissao_no_escopo: sem permissão no recurso
%
% Uso para auditoria:
%   - Permite rastrear decisões de acesso
%   - Facilita debugging de políticas
%   - Essencial para compliance
%
% Exemplos de uso:
%   ?- motivo(alice, deletar, none, M).
%   M = negado_por_excecao.  % alice tem negação para deletar
%
%   ?- motivo(bob, ler, doc1, M).
%   M = permitido_por_classe_ou_instancia.  % bob pode ler doc1
%
%   ?- motivo(charlie, editar, doc2, M).
%   M = ausente_de_permissao_no_escopo.  % charlie não tem permissão
%
motivo(User, Acao, Recurso, Motivo).
```

#### 6.2. `papeis_efetivos/2` - Lista de Papéis com Herança
```prolog
% ============================================
% PAPEIS_EFETIVOS/2
% ============================================
% Descrição: Lista todos os papéis efetivos de um usuário, incluindo papéis
%            diretos e todos os papéis herdados via hierarquia. Remove duplicatas.
%
% Parâmetros:
%   - Usuario: átomo identificando o usuário
%   - ListaPapeis: lista ordenada de átomos representando papéis (saída)
%
% Comportamento:
%   - Coleta todos os papéis diretos do usuário
%   - Para cada papel direto, coleta todos os superpapéis (via tem_superpapel/2)
%   - Usa findall/3 para coletar (pode gerar duplicatas)
%   - Remove duplicatas e ordena com sort/2
%   - Retorna lista ordenada e sem duplicatas
%
% Uso:
%   - Visualizar todos os papéis efetivos de um usuário
%   - Debugging de hierarquia de papéis
%   - Auditoria de permissões
%
% Exemplos de uso:
%   ?- papeis_efetivos(alice, P).
%   P = [admin, analista, gerente, usuario].  % alice é admin, herda todos
%
%   ?- papeis_efetivos(bob, P).
%   P = [analista, gerente, usuario].  % bob é analista, herda gerente e usuario
%
%   ?- papeis_efetivos(charlie, P).
%   P = [usuario].  % charlie é apenas usuario (sem herança)
%
papeis_efetivos(Usuario, ListaPapeis).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Conceito | Extensão |
|----------|----------|
| **Grupos/Times** | Implementar `membro_de(User, Grupo)` + `grupo_tem_papel(Grupo, Papel)` + propagação de papéis via grupo. Usuários herdam papéis de seus grupos. |
| **Conflitos e Precedências** | Estratégias de resolução: *deny-overrides*, *permit-overrides*, *first-applicable*. Implementar `estrategia_resolucao/1` configurável. |
| **ABAC Leve** | Atributos do usuário/recurso (ex.: `departamento(User, D)`, `dono(Recurso, User)`), e regras do tipo "`gerente` do mesmo departamento pode `editar`". |
| **Janela Temporal** | `permite_durante(Papel, Acao, Janela)` e checagem de tempo. Permissões válidas apenas em horários específicos. |
| **Auditoria/Explicação** | `justifica(User, Acao, Recurso, ListaDeMotivos)` com trilha completa de por que permitiu/negou, incluindo papéis e regras acionadas. |
| **Delegação** | `delegado(Owner, Delegate, Acao, Recurso, Ate)` criando concessões temporárias. Proprietário pode delegar permissões a outros usuários. |

### Exemplo de Extensão: Grupos e Times
```prolog
% Grupos e membros
grupo(ti).
grupo(financeiro).
grupo(rh).

membro_de(joao, ti).
membro_de(maria, ti).
membro_de(carla, financeiro).
membro_de(pedro, rh).

% Papéis atribuídos a grupos
grupo_tem_papel(ti, gerente).
grupo_tem_papel(financeiro, analista).
grupo_tem_papel(rh, usuario).

% Usuário herda papéis de seus grupos
tem_papel(User, Papel) :-
    membro_de(User, Grupo),
    grupo_tem_papel(Grupo, Papel).

% Exemplo de uso:
% ?- tem_papel(joao, gerente).
% true.  % joao herda gerente do grupo ti
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Herança de papéis
?- tem_superpapel(gerente, usuario).
true.

?- tem_superpapel(admin, usuario).
true.

% 2) Permissões gerais
?- tem_permissao(maria, criar_usuario).    % maria é admin
true.

?- tem_permissao(joao, criar_usuario).     % negado explicitamente
false.

?- tem_permissao(joao, aprovar_despesa).   % joao é gerente
true.

% 3) Escopo por classe (relatorio/*)
?- tem_permissao_no_recurso(joao, editar, relatorio_q1).
true.   % gerente pode editar classe(relatorio), sem negação específica

?- tem_permissao_no_recurso(joao, editar, relatorio_q2).
false.  % nega_no para q2

% 4) Permissão específica de instância
?- tem_permissao_no_recurso(joao, exportar, relatorio_q1).
true.   % gerente tem permite_no(gerente, exportar, recurso(relatorio_q1))

% 5) Permissões do analista (e negação no papel)
?- tem_permissao(carla, editar_relatorio).
true.

?- tem_permissao(carla, deletar_relatorio).
false.  % nega_papel(analista, deletar_relatorio)

% 6) Usuário básico herdando leitura de classe
?- tem_permissao_no_recurso(pedro, ler, relatorio_q2).
true.  % usuario pode ler classe(relatorio)

% 7) Listar todos os usuários que podem criar usuário
?- tem_permissao(Usuario, criar_usuario).
Usuario = maria.  % apenas maria (admin) pode

% 8) Verificar motivos
?- motivo(joao, criar_usuario, none, Motivo).
Motivo = negado_por_excecao.

?- motivo(joao, editar, relatorio_q2, Motivo).
Motivo = negado_no_recurso.

?- motivo(maria, deletar, relatorio_q1, Motivo).
Motivo = permitido_por_classe_ou_instancia.

% 9) Listar papéis efetivos de um usuário
?- papeis_efetivos(joao, Papeis).
Papeis = [gerente, usuario].  % joao tem gerente e herda usuario

?- papeis_efetivos(maria, Papeis).
Papeis = [admin, gerente, usuario].  % maria tem admin e herda gerente e usuario

% 10) Verificar normalização de ações
?- acao_base(editar_relatorio, Base).
Base = editar.

?- acao_base(ler_relatorio, Base).
Base = ler.

% 11) Listar todas as permissões de um usuário em um recurso
?- tem_permissao_no_recurso(joao, Acao, relatorio_q1).
Acao = ler ;
Acao = editar ;
Acao = exportar.

% 12) Verificar herança transitiva
?- tem_superpapel(admin, P).
P = admin ;
P = gerente ;
P = usuario.
```

---

## � Conceitos Aplicados

- **Recursão**: Fecho transitivo de herança de papéis (`tem_superpapel/2`)
- **Modelagem Hierárquica**: Papéis organizados em hierarquia com herança de permissões
- **Combinação de Fatos**: Busca por permissões diretas e herdadas através de múltiplos papéis
- **Negação como Falha**: Verificação de ausência de negações (`\+ negacao_ativa/2`)
- **Política Deny-Overrides**: Negações explícitas sobrepõem permissões herdadas
- **Normalização**: Tratamento de sinônimos de ações (`acao_base/2`)
- **Findall e Agregação**: Coleta de todos os papéis efetivos de um usuário
- **Explicabilidade**: Geração automática de motivos para decisões de acesso

---

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

---

## 📝 Observações Importantes

1. A base de dados deve conter **pelo menos 5 usuários**, **4 papéis**, **10 permissões** e **3 exceções**
2. Teste casos de **herança transitiva** (ex.: admin → gerente → usuario)
3. Teste casos de **conflito** (permissão herdada vs. negação explícita) - negação deve vencer
4. Documente claramente a **política de resolução** (deny-overrides)
5. Todas as decisões devem ser **explicáveis** através do predicado `motivo/4`
6. Implemente **permissões gerais** e **permissões com escopo** (classe e instância)
7. Use **normalização de ações** para tratar sinônimos (ex.: `editar_relatorio` = `editar`)
8. Teste **herança de permissões** (papel filho herda permissões do pai)
9. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
10. Organize o código em **múltiplos arquivos** conforme a estrutura sugerida
