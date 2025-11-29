# 🔐 Sistema Lógico de Controle de Acesso Baseado em Papéis (RBAC) em Prolog


Este projeto implementa um **Sistema de Controle de Acesso Baseado em Papéis (RBAC)** usando **Prolog**, com:

- Hierarquia de papéis e **herança transitiva** de permissões  
- **Permissões gerais** e **permissões com escopo** de recurso  
- Política de **deny-overrides** (negações têm precedência sobre permissões)  
- Normalização de ações (sinônimos)  
- Predicados **explicativos** de decisões de acesso  
- **Extensão obrigatória**: grupos/times propagando papéis para usuários  

Toda a inferência é **declarativa, rastreável e explicável** via predicados como `motivo/4` e `papeis_efetivos/2`.

---

## 🧠 Domínio: RBAC com Herança, Escopo e Exceções

O sistema modela:

- Papéis: `admin`, `gerente`, `usuario`, `analista`
- Hierarquia:  
  - `admin  ->  gerente  ->  usuario`  
  - `analista` é paralelo, sem herdar dos outros
- Usuários: `joao`, `maria`, `carla`, `pedro`, `alice`
- Permissões:
  - Gerais, como `criar_usuario`, `aprovar_despesa`, `ler_dashboard`…
  - Com escopo:
    - Por **classe**: `relatorio/*`, `planilha/*`
    - Por **instância**: `relatorio_q1`, `relatorio_q2`, `planilha_financeira` etc.
- Exceções (negações), por:
  - usuário (`nega/2`)
  - recurso (`nega_no/3`)
  - papel (`nega_papel/2`)
- Extensão:
  - **Grupos/Times** (`grupo/1`, `membro_de/2`, `grupo_tem_papel/2`)  
    Usuários herdam papéis também por meio dos grupos.

---

## 📂 Estrutura de Arquivos

```text
.
├── base_fatos.pl        % módulo para carregar a base (entrada.txt)
├── entrada.txt          % base de fatos (papéis, usuários, permissões, grupos, negações)
├── heranca.pl           % tem_superpapel/2 (herança transitiva de papéis)
├── extensao_grupos.pl   % EXTENSÃO: grupos/times -> tem_papel/2 via grupos
├── excecoes.pl          % negações gerais e com escopo (negacao_ativa/2, negacao_ativa_no/3)
├── permissoes.pl        % acao_base/2, tem_permissao/2, tem_permissao_no_recurso/3
├── explicacao.pl        % motivo/4, papeis_efetivos/2, explicacao_solucao/4, motivo_falha/4
├── principal.pl         % ponto de entrada: executa testes e gera saida.txt
└── saida.txt            % arquivo de saída gerado pelo sistema (resultados das consultas)
```
## ▶️ Como Executar o Sistema
- Requisitos:
   - SWI-Prolog instalado (swipl disponível no terminal)

Passo a passo

Na pasta do projeto:
```text
swipl principal.pl
```
O arquivo principal.pl:

1. Carrega a base de fatos (entrada.txt) via base_fatos.pl

2. Carrega os módulos de regras (heranca.pl, excecoes.pl, permissoes.pl, explicacao.pl, extensao_grupos.pl)

3. Executa uma bateria de consultas de teste

4. Grava os resultados e motivos em saida.txt

Depois da execução, basta abrir saida.txt para ver:

- Quais consultas foram feitas

- Se deram true ou false

- O motivo lógico de algumas decisões

- Os papéis efetivos de usuários
## 📥 Arquivo de Entrada vs 📤 Arquivo de Saída
entrada.txt – Base de Fatos
- É o único arquivo que você edita para mudar o cenário: usuários, papéis, permissões, negações, grupos…

- Sempre que alterar entrada.txt, execute de novo:
```text
swipl principal.pl
```
saida.txt – Resultados
- É gerado automaticamente por principal.pl.

- Contém, por exemplo:
```text
=== Resultados do Sistema RBAC em Prolog ===

tem_superpapel(gerente, usuario) => true
tem_superpapel(admin, usuario)   => true

tem_permissao(maria, criar_usuario) => true
tem_permissao(joao, criar_usuario)  => false
tem_permissao(joao, aprovar_despesa) => true

tem_permissao_no_recurso(joao, editar, relatorio_q1) => true
tem_permissao_no_recurso(joao, editar, relatorio_q2) => false
tem_permissao_no_recurso(joao, exportar, relatorio_q1) => true

tem_permissao(carla, editar_relatorio)   => true
tem_permissao(carla, deletar_relatorio)  => false

tem_permissao_no_recurso(pedro, ler, relatorio_q2) => true

Consulta: tem_permissao(Usuario, criar_usuario).
  Usuarios com permissao: [maria]

motivo(joao, criar_usuario, none, M)  => M = negado_por_excecao
motivo(joao, editar, relatorio_q2, M) => M = negado_no_recurso
motivo(maria, deletar, relatorio_q1, M) => M = permitido_por_classe_ou_instancia

papeis_efetivos(joao, P)  => P = [gerente,usuario]
papeis_efetivos(maria, P) => P = [admin,gerente,usuario]
```
## 🧩 Predicados Implementados

Base de fatos

- papel(Papel)

- herda_papel(Filho, Pai)

- tem_papel(User, Papel) – fatos diretos + regras da extensão de grupos

- permite(Papel, Acao) – permissões gerais

- permite_no(Papel, Acao, Escopo) – permissões com escopo (classe/1 ou recurso/1)

- pertence_a(Recurso, Classe) – mapeia recursos para classes

- nega(User, AcaoBase) – negação geral por usuário

- nega_no(User, AcaoBase, Escopo) – negação por recurso ou classe

- nega_papel(Papel, AcaoBase) – negação por papel

- acao_equivalente(Acao, Base) – sinônimos

- grupo(Nome), membro_de(User, Grupo), grupo_tem_papel(Grupo, Papel) – extensão

Herança de papéis (heranca.pl)
- tem_superpapel(P, S)
  - Fecho reflexivo e transitivo da herança de papéis.
Exceções (excecoes.pl)
- negacao_ativa(User, AcaoBase)
  - Verdadeiro se o usuário tem alguma negação geral (por usuário ou por papel).
- negacao_ativa_no(User, AcaoBase, Recurso)
   - Verdadeiro se há negação:
     - No recurso específico
    - Na classe do recurso
    - No papel do usuário
 Implementa a política deny-overrides.

Permissões (permissoes.pl)
- acao_base(Acao, Base)
  - Normaliza ações usando acao_equivalente/2.
- tem_permissao(User, Acao)
  - Permissão geral (sem recurso), considerando:
     - normalização de ação
     - papéis diretos e herdados (via tem_superpapel/2)
     - negações gerais (deny-overrides)
- tem_permissao_no_recurso(User, Acao, Recurso)
  - Permissão com escopo, em três níveis:
     - permite_no(Papel, Acao, recurso(Recurso))
     - permite_no(Papel, Acao, classe(Classe))
     - fallback: permissão geral tem_permissao/2
Sempre respeitando negações gerais e específicas.

Predicados explicativos (explicacao.pl)
- motivo(User, Acao, RecursoOuNone, Motivo)
   - Explica por que uma permissão foi concedida ou negada.
   - Motivos possíveis:
     - negado_por_excecao
     - negado_no_recurso
     - permitido_por_papel
     - permitido_por_classe_ou_instancia
     - ausente_de_permissao
     - ausente_de_permissao_no_escopo
- papeis_efetivos(User, ListaPapeis)
   - Lista todos os papéis efetivos do usuário, usando findall/3 e sort/2.
- explicacao_solucao(User, Acao, RecursoOuNone, Texto)
   - Gera texto amigável explicando decisões permitidas.
- motivo_falha(User, Acao, RecursoOuNone, Texto)
   - Gera texto amigável explicando decisões negadas.
 
## 🧪 Exemplos de Consultas e Resultados Esperados

A seguir, alguns exemplos para serem usados no REPL do Prolog:

1) Herança de Papéis
```text
?- tem_superpapel(gerente, usuario).
true.

?- tem_superpapel(admin, usuario).
true.

?- tem_superpapel(analista, usuario).
false.
```
2) Permissões Gerais
```text
?- tem_permissao(maria, criar_usuario).
true.   % maria é admin, e admin tem permite(admin, criar_usuario)

?- tem_permissao(joao, criar_usuario).
false.  % há nega(joao, criar_usuario) -> deny-overrides

?- tem_permissao(joao, aprovar_despesa).
true.   % joao é gerente, gerente tem permite(gerente, aprovar_despesa)
```
3) Permissões com Escopo (Relatórios)
```text
?- tem_permissao_no_recurso(joao, editar, relatorio_q1).
true.   % gerente + permite_no(gerente, editar, classe(relatorio))

?- tem_permissao_no_recurso(joao, editar, relatorio_q2).
false.  % nega_no(joao, editar, recurso(relatorio_q2))

?- tem_permissao_no_recurso(joao, exportar, relatorio_q1).
true.   % permite_no(gerente, exportar, recurso(relatorio_q1))
```
4) Analista e negação por papel
```text
?- tem_permissao(carla, editar_relatorio).
true.   % analista tem permite(analista, editar_relatorio)

?- tem_permissao(carla, deletar_relatorio).
false.  % nega_papel(analista, deletar)
```
5) Usuário básico herdando leitura por classe
```text
?- tem_permissao_no_recurso(pedro, ler, relatorio_q2).
true.  % usuario tem permite_no(usuario, ler, classe(relatorio))
```
6) Listar todos os usuários que podem criar usuário 
```text
?- tem_permissao(Usuario, criar_usuario).
Usuario = maria.
```
7) Motivos de Decisão
```text
?- motivo(joao, criar_usuario, none, M).
M = negado_por_excecao.

?- motivo(joao, editar, relatorio_q2, M).
M = negado_no_recurso.

?- motivo(maria, deletar, relatorio_q1, M).
M = permitido_por_classe_ou_instancia.
```
8) Papéis Efetivos (com herança e grupos)  
```text
?- papeis_efetivos(joao, P).
P = [gerente, usuario].

?- papeis_efetivos(maria, P).
P = [admin, gerente, usuario].
```
9) Normalização de Ações  
```text
?- acao_base(editar_relatorio, B).
B = editar.

?- acao_base(remover, B).
B = deletar.

?- acao_base(ler, B).
B = ler.
```

## ⭐ Extensão Obrigatória: Grupos / Times

A extensão implementada é o modelo de grupos:
- grupo(ti).
- membro_de(joao, ti).
- grupo_tem_papel(ti, gerente).

A regra em extensao_grupos.pl:
```text
tem_papel(User, Papel) :-
    membro_de(User, Grupo),
    grupo_tem_papel(Grupo, Papel).
```
Isso faz com que usuários possam herdar papéis dos grupos aos quais pertencem.
Exemplo:
```text
?- tem_papel(joao, gerente).
true.   % joao é gerente direto + herda de grupo 'ti'

?- papeis_efetivos(joao, P).
P = [gerente, usuario].
```
