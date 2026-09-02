# Backlog 08: Inventário e Regressão de Bugs

## Objetivo

Registrar bugs conhecidos e descobertos durante os testes, priorizando falhas que alteram ou podem perder dados financeiros.

## Modelo obrigatório

Cada bug deve registrar:

- severidade e versões afetadas;
- pré-condições e passos mínimos para reprodução;
- resultado atual e resultado esperado;
- impacto e possibilidade de corrupção/perda de dados;
- teste de regressão que falha antes da correção;
- correção, critério de aceite e evidência de validação.

## Itens iniciais

- [x] Transferência pode deixar registros parciais e suprime exceções.
- [x] Atualização de transação remove e reinsere sem atomicidade.
- [x] Falha de criação do schema é apenas registrada em log.
- [x] Falha de migração pode deixar foreign keys desativadas.
- [x] Avaliar deriva monetária causada pelo uso de `double` e SQLite `REAL`.

## Critério de aceite

Nenhum bug P0/P1 é encerrado sem teste de regressão automatizado e validação de que uma falha não deixa dados parciais.

### BUG-08-01 — Transferência podia deixar registros parciais

- **Status:** corrigido.
- **Severidade:** P1 — risco de inconsistência financeira.
- **Versões afetadas:** implementação legada anterior à correção consolidada na versão de desenvolvimento `1.2.00+106`.
- **Pré-condições:** duas contas válidas, uma transferência em criação ou atualização e uma falha durante uma das gravações envolvidas.
- **Reprodução mínima:**
  1. Iniciar a gravação de uma transferência entre duas contas.
  2. Permitir a criação do débito, do registro de transferência ou dos saldos.
  3. Provocar falha antes da conclusão do crédito correspondente.
- **Resultado anterior:** partes da operação podiam permanecer gravadas e algumas exceções não chegavam ao chamador.
- **Resultado esperado:** débito, crédito, vínculo da transferência e saldos devem ser confirmados como uma única operação; qualquer falha deve desfazer todas as alterações e ser propagada.
- **Impacto:** possibilidade de saldo incorreto, transferência incompleta e registros órfãos.
- **Possibilidade de perda ou corrupção de dados:** alta; uma transferência parcial altera diretamente os saldos das contas.
- **Correção aplicada:** as operações de inclusão, remoção e atualização foram centralizadas em `FinancialOperationRepository` e executadas dentro de transações SQLite. `TransferManager` passou a propagar as falhas e impedir a execução simultânea da mesma operação.
- **Testes de regressão:**
  - `test/integration/repositories/financial_operation_repository_test.dart` — `faz rollback quando a segunda transação não pode ser inserida`;
  - `test/integration/repositories/financial_operation_repository_test.dart` — `restaura a transferência anterior se a atualização falhar`;
  - `test/unit/manager/transfer_manager_test.dart` — `propaga falha da operação financeira`;
  - `test/unit/manager/transfer_manager_test.dart` — `bloqueia duas gravações simultâneas do mesmo objeto`.
- **Critério de aceite:** uma falha em qualquer etapa deixa zero registros parciais, preserva a operação anterior durante atualização e retorna a exceção ao chamador.
- **Evidência de validação:** suíte completa executada com sucesso, totalizando 370 testes antes do início da Task 7.

### BUG-08-02 — Atualização de transação não era atômica

- **Status:** corrigido.
- **Severidade:** P1 — risco de perda de lançamento financeiro.
- **Versões afetadas:** implementação legada anterior à correção consolidada na versão de desenvolvimento `1.2.00+106`.
- **Pré-condições:** uma transação persistida e uma atualização que exija remover o registro anterior e inserir o novo.
- **Reprodução mínima:**
  1. Persistir uma transação válida.
  2. Iniciar sua atualização.
  3. Permitir a remoção da transação original.
  4. Provocar uma falha durante a inserção da nova versão.
- **Resultado anterior:** a remoção e a reinserção eram operações separadas; uma falha após a remoção podia eliminar definitivamente o lançamento original.
- **Resultado esperado:** remoção, ajuste dos saldos e reinserção devem fazer parte da mesma transação SQLite. Se qualquer etapa falhar, o lançamento e o saldo anteriores devem permanecer inalterados.
- **Impacto:** desaparecimento de transações, saldos divergentes e perda de histórico financeiro.
- **Possibilidade de perda ou corrupção de dados:** alta; a falha podia remover um lançamento confirmado.
- **Correção aplicada:** `FinancialOperationRepository.updateTransaction` passou a consultar o registro original, remover a transação, tratar o saldo anterior e inserir a nova versão dentro de uma única transação SQLite. As alterações somente são confirmadas se todas as etapas forem concluídas.
- **Testes de regressão:**
  - `test/integration/repositories/financial_operation_repository_test.dart` — `faz rollback da atualização se a reinserção falhar`;
  - `test/integration/repositories/financial_operation_repository_test.dart` — `atualiza o único lançamento do dia sem manter saldo órfão`;
  - `test/unit/manager/transaction_manager_test.dart` — confirma a delegação da atualização para a operação atômica.
- **Critério de aceite:** ao provocar falha na reinserção, deve continuar existindo exatamente a transação original, com descrição, valor e saldo anteriores.
- **Evidência de validação:** o teste de integração confirma a preservação da transação original e do saldo após a falha; a suíte completa passou antes do início da Task 7.
### BUG-08-03 — Falha na criação do schema era suprimida

- **Status:** corrigido.
- **Severidade:** P1 — risco de inicialização com banco incompleto.
- **Versões afetadas:** implementação legada anterior à correção consolidada na versão de desenvolvimento `1.2.00+106`.
- **Pré-condições:** primeira abertura do banco ou recriação do arquivo, seguida de falha ao criar uma tabela, índice ou trigger.
- **Reprodução mínima:**
  1. Abrir um banco ainda inexistente.
  2. Provocar uma exceção durante o callback de criação do schema.
  3. Aguardar a inicialização do `DatabaseManager`.
- **Resultado anterior:** a exceção era apenas registrada em log, permitindo que a inicialização prosseguisse sem informar ao chamador que o schema estava incompleto.
- **Resultado esperado:** qualquer falha durante a criação do schema deve interromper a abertura do banco e ser propagada ao chamador.
- **Impacto:** consultas posteriores poderiam falhar por ausência de tabelas, índices ou triggers; operações financeiras poderiam ocorrer sobre um schema incompleto.
- **Possibilidade de perda ou corrupção de dados:** alta; a ausência de triggers ou restrições pode produzir saldos e relacionamentos inconsistentes.
- **Correção aplicada:** `DatabaseManager._onCreate` executa a criação do schema sem suprimir exceções. Foi adicionado um `DatabaseSchemaCreator` opcional para permitir a reprodução determinística da falha em testes.
- **Testes de regressão:**
  - `test/integration/database/database_manager_test.dart` — `propaga falha ocorrida durante a criação do schema`;
  - `test/integration/database/database_manager_test.dart` — `abre banco em memória e cria o schema completo`;
  - `test/integration/database/tables_creators_test.dart` — valida tabelas, índices, triggers e foreign keys do schema completo.
- **Critério de aceite:** uma exceção em qualquer etapa do callback de criação deve fazer `DatabaseManager.database` concluir com erro, sem disponibilizar uma conexão parcialmente inicializada.
- **Evidência de validação:** o teste injeta uma falha intencional no criador do schema e confirma que o mesmo `StateError` chega ao chamador.


### BUG-08-04 — Falha de migração podia deixar foreign keys desativadas

- **Status:** corrigido.
- **Severidade:** P1 — risco de quebra permanente da integridade referencial.
- **Versões afetadas:** implementação legada anterior à correção consolidada na versão de desenvolvimento `1.2.00+106`.
- **Pré-condições:** banco com `PRAGMA foreign_keys = ON` e uma migração que precise desativar temporariamente as restrições.
- **Reprodução mínima:**
  1. Abrir o banco com foreign keys habilitadas.
  2. Iniciar uma migração.
  3. Provocar falha em um dos scripts após executar `PRAGMA foreign_keys = OFF`.
  4. Consultar novamente `PRAGMA foreign_keys`.
- **Resultado anterior:** a exceção interrompia o fluxo antes da reativação das foreign keys, deixando a conexão com as restrições desabilitadas.
- **Resultado esperado:** `foreign_keys` deve voltar para `ON` tanto em caso de sucesso quanto em caso de falha.
- **Impacto:** registros órfãos e relacionamentos inválidos entre contas, saldos, transações, transferências, categorias e importações OFX.
- **Possibilidade de perda ou corrupção de dados:** alta; operações posteriores poderiam ignorar todas as restrições referenciais.
- **Correção aplicada:** a execução dos scripts em `DatabaseMigrations.applyMigrations` foi envolvida em `try/finally`; o bloco `finally` executa `PRAGMA foreign_keys = ON`.
- **Testes de regressão:**
  - `test/integration/database/database_migrations_test.dart` — `restaura foreign keys quando uma migração falha`;
  - `test/integration/database/database_migrations_test.dart` — `reverte todo o processo quando uma migração falha`;
  - `test/integration/database/database_migrations_test.dart` — verificação final de que `PRAGMA foreign_keys` permanece igual a `1`.
- **Critério de aceite:** após qualquer falha de migração, a exceção deve ser propagada e `PRAGMA foreign_keys` deve retornar `1`.
- **Evidência de validação:** o teste provoca uma falha real de SQL durante a migração e confirma que as foreign keys foram restauradas.

### BUG-08-05 — Saldos acumulavam deriva monetária

- **Status:** corrigido para valores monetários com duas casas decimais.
- **Severidade:** P1 — possibilidade de divergência progressiva nos saldos.
- **Versões afetadas:** schemas até a versão `1013`.
- **Pré-condições:** executar várias operações monetárias fracionárias sobre o mesmo saldo.
- **Reprodução mínima:**
  1. Criar duas contas com saldo inicial igual a zero.
  2. Realizar cem transferências de `0.01`.
  3. Consultar diretamente o saldo acumulado.
- **Resultado anterior:** cem débitos de `0.01` produziram `-1.0000000000000007` em vez de `-1.0`.
- **Resultado esperado:** os saldos persistidos devem permanecer normalizados em duas casas decimais após inclusões e remoções.
- **Impacto:** comparações inexatas, resíduos em contas que deveriam estar zeradas e divergência entre cálculos acumulados e valores apresentados.
- **Possibilidade de perda ou corrupção de dados:** moderada; a deriva é pequena, mas afeta valores financeiros persistidos e cresce com o número de operações.
- **Causa:** `double` e SQLite `REAL` usam representação binária e não representam exatamente diversos valores decimais, como `0.01`.
- **Correção aplicada:** os triggers de inclusão e remoção passaram a aplicar `ROUND(..., 2)` ao atualizar `balanceOpen` e `balanceClose`.
- **Compatibilidade com bancos existentes:** a migration `1014` remove os triggers antigos e instala as versões com arredondamento, preservando transações e saldos existentes.
- **Testes de regressão:**
  - `test/integration/repositories/financial_operation_repository_test.dart` — `não acumula deriva ao somar várias operações de um centavo`;
  - `test/integration/database/database_migrations_test.dart` — `migração 1014 preserva dados e instala triggers sem deriva monetária`;
  - `test/integration/repositories/transaction_repository_test.dart` — `calcula totais mensais sem expor deriva monetária`;
  - `test/integration/repositories/transaction_repository_test.dart` — `agrupa valores por categoria sem expor deriva monetária`.
- **Critério de aceite:** cem operações de um centavo devem produzir exatamente `1.0` ou `-1.0`; a remoção dessas operações deve restaurar exatamente o saldo anterior; bancos na versão `1013` devem receber os novos triggers sem perder dados.
- **Risco residual:** as transações continuam armazenadas como SQLite `REAL`. A normalização em duas casas atende aos valores monetários atualmente aceitos pela aplicação, mas uma futura adoção de moedas com outra precisão exigirá armazenar unidades mínimas inteiras ou registrar a precisão da moeda.
- **Evidência de validação:** o teste de caracterização reproduziu `-1.0000000000000007`; após a correção, os testes de acúmulo, remoção, agregação e migration passaram.