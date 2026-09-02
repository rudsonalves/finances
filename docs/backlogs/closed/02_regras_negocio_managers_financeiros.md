# Backlog 02: Regras de Negócio e Managers Financeiros

## Contexto
Os `Managers` contêm o coração financeiro da aplicação. Inconsistências nessa camada resultam em saldos incorretos, perdas de rastreabilidade ou falhas de propagação em lançamentos retroativos e transferências.

## Prioridade
**P0 (Crítica)**

## Módulos Alvo
- [lib/manager/balance_manager.dart](../../lib/manager/balance_manager.dart)
- [lib/manager/transaction_manager.dart](../../lib/manager/transaction_manager.dart)
- [lib/manager/transfer_manager.dart](../../lib/manager/transfer_manager.dart)

---

## Tarefas

- [x] **2.1. Testes Unitários para `BalanceManager`**
  - **Arquivo**: `test/unit/manager/balance_manager_test.dart`
  - Casos de teste:
    - `getBalanceInDate` quando já existe balanço na data informada (retorna o existente).
    - `getBalanceInDate` quando não existe balanço na data, mas existe balanço anterior (cria novo balanço herdando `closingBalance` anterior como `openingBalance`).
    - `getBalanceInDate` quando não existe nenhum balanço prévio no histórico da conta (inicializa com valores zerados).
    - Tratamento de exceções e erros de acesso ao repositório.

- [x] **2.2. Testes Unitários para `TransactionManager.addNew`**
  - **Arquivo**: `test/unit/manager/transaction_manager_test.dart`
  - Casos de teste:
    - Adicionar transação de receita (tipo `Income`): verificar associação ao ID de balanço correto e inserção no repositório.
    - Adicionar transação de despesa (tipo `Expense`): verificar débito correto.
    - Verificar associação ao balanço e chamada correta ao repositório. A propagação pertence aos testes de integração dos triggers SQLite.

- [x] **2.3. Testes Unitários para `TransactionManager.remove`**
  - Casos de teste:
    - Remover receita: estorno no saldo do dia e decremento nos saldos de todos os balanços futuros.
    - Remover despesa: estorno no saldo do dia e incremento nos saldos de todos os balanços futuros.
    - Remoção de transação inexistente ou com erro no banco.

- [x] **2.4. Testes Unitários para `TransferManager`**
  - **Arquivo**: `test/unit/manager/transfer_manager_test.dart`
  - Casos de teste:
    - Executar transferência entre duas contas distintas:
      - Débito na conta de origem (criação/atualização de transação de saída).
      - Crédito na conta de destino (criação/atualização de transação de entrada).
      - Registro do registro de transferência.
      - Atualização dos balanços em ambas as contas.
    - Cancelamento/estorno de transferência entre contas.
    - Tentativa de transferência para a mesma conta (validação de restrição).
    - Erro em cada etapa deve ser devolvido ao chamador, sem ser apenas registrado em log.

- [x] **2.5. Tornar Transações e Transferências Atômicas**
  - Executar débito, crédito e registro da transferência em uma única transação SQLite.
  - Executar remoção e reinserção de `updateTransaction` na mesma transação.
  - Testar rollback quando qualquer gravação falhar e impedir registros órfãos.
  - Testar idempotência, chamadas concorrentes e duplo toque em salvar.

- [x] **2.6. Invariantes Monetárias**
  - Cobrir arredondamento, `0.1 + 0.2`, milhares de lançamentos, zero negativo e valores extremos.
  - Garantir que a soma dos lançamentos corresponda aos saldos em centavos.
  - Avaliar migração de `double`/SQLite `REAL` para centavos inteiros ou um tipo decimal.

## Critérios de Aceite
- Todos os invariantes P0 possuem cenários de sucesso, falha e rollback.
- Testes unitários isolam orquestração; testes SQLite validam atomicidade, triggers e integridade real.

## Resultado

- `BalanceManager` não modifica mais o objeto histórico ao criar o balanço de um novo dia.
- Inclusão, remoção e atualização de transferências usam uma única transação SQLite.
- Atualização de transações usa rollback e não mantém saldos órfãos.
- Erros financeiros são propagados ao chamador em vez de convertidos em log ou `-1`.
- Operações simultâneas sobre o mesmo objeto são rejeitadas e objetos já persistidos não podem ser incluídos novamente.
- Os testes comparam valores em centavos. A migração de `REAL` para centavos inteiros foi adiada para uma migração de schema específica, evitando alteração destrutiva sem uma estratégia de compatibilidade e rollback.
- A cobertura filtrada subiu de **0,16%** para **2,87%** (233 de 8.108 linhas), novo limite mínimo do CI.
