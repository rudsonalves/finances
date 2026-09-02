# Backlog 03: Parser e Managers OFX (Open Financial Exchange)

## Contexto
O recurso de importação OFX permite ao usuário carregar extratos bancários de múltiplas instituições. Erros no parser podem gerar transações duplicadas, valores com sinais invertidos ou falhas de leitura por variações no formato dos bancos.

## Prioridade
**P0 (Crítica)**

## Módulos Alvo
- `lib/packages/ofx/`
- [lib/manager/ofx_account_manager.dart](../../lib/manager/ofx_account_manager.dart)
- [lib/manager/ofx_relationship_manager.dart](../../lib/manager/ofx_relationship_manager.dart)
- [lib/manager/ofx_trans_template_manager.dart](../../lib/manager/ofx_trans_template_manager.dart)

---

## Tarefas

- [x] **3.1. Criação de Fixtures OFX de Teste**
  - **Diretório**: `test/helpers/fixtures/ofx/`
  - Preferir arquivos sintéticos; qualquer arquivo real deve passar por uma lista de anonimização de nomes, documentos, contas, agências e identificadores:
    - OFX padrão v1.02 (SGML/Header antigo).
    - OFX v2.x (XML format).
    - OFX de bancos comuns no Brasil (Itaú, Bradesco, Santander, Nubank, Inter, Banco do Brasil).
    - OFX com caracteres especiais, acentuação e diferentes encodings (ISO-8859-1 / UTF-8).
    - OFX corrompido / truncado / sem tags obrigatórias.

- [x] **3.2. Testes Unitários do Parser OFX (`packages/ofx`)**
  - **Arquivo**: `test/unit/packages/ofx/ofx_parser_test.dart`
  - Casos de teste:
    - Extração correta de dados da conta (Bank ID, Account ID, Account Type).
    - Extração e conversão de transações: FITID, data/hora (`DTPOSTED`), valor numérico (`TRNAMT`), tipo (`TRNTYPE`), descrição/memo (`MEMO`/`NAME`).
    - Validação de sinal monetário (débitos negativos, créditos positivos).
    - Resiliência a tags ausentes e extratos sem transações.

- [x] **3.3. Testes dos Managers OFX**
  - **Arquivos**:
    - `test/unit/manager/ofx_account_manager_test.dart`
    - `test/unit/manager/ofx_relationship_manager_test.dart`
    - `test/unit/manager/ofx_trans_template_manager_test.dart`
  - Casos de teste:
    - Mapeamento e associação de contas OFX com contas internas da aplicação.
    - Aplicação de regras e templates de categorização automática para transações importadas.
    - Prevenção de duplicidade usando `fitid` no contexto da instituição e conta, sem presumir unicidade global.
    - Reimportação, arquivos sobrepostos e concorrência sem criar lançamentos duplicados.

## Critérios de Aceite
- O parser suporta os principais formatos OFX emitidos pelos bancos brasileiros sem lançar exceções não tratadas.
- Transações importadas resultam em objetos válidos prontos para inclusão via `TransactionManager`.

## Resultado

- Parser coberto para XML 2.x, SGML 1.02, conta bancária, cartão de crédito,
  uma ou várias transações e extratos vazios.
- Leitura de arquivos UTF-8 e ISO-8859-1, datas com fuso, campos opcionais e
  documentos inválidos cobertos por testes.
- Managers de conta, relacionamento e templates desacoplados dos repositórios
  concretos e cobertos por testes unitários.
- Duplicidade protegida por chave persistente composta por instituição, conta
  bancária e `FITID`, com índice único no SQLite e testes de reimportação,
  sobreposição e concorrência.
- A migração 1012 cria a tabela de controle das transações importadas. Registros
  importados antes dessa migração não podem ser retroativamente identificados
  por `FITID`, pois as versões anteriores não armazenavam esse campo.
