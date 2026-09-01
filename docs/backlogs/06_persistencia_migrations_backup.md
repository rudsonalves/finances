# Backlog 06: Persistência, Migrações e Backup de Banco de Dados

## Contexto
O aplicativo armazena todos os registros financeiros no SQLite local. É fundamental garantir que o schema seja criado corretamente, migrações entre versões não corrompam dados e rotinas de backup/restauração preservem a integridade referencial.

## Prioridade
**P0/P1 (Crítica)**

## Módulos Alvo
- [lib/store/database/database_manager.dart](../../lib/store/database/database_manager.dart)
- `lib/store/database/database_migrations.dart`
- `lib/store/tables_creators.dart`
- `lib/store/database/database_backup.dart`
- `lib/repositories/` (implementações SQLite dos repositórios)

---

## Tarefas

- [x] **6.1. Testes de Criação de Schema e Integridade do SQLite**
  - **Arquivo**: `test/integration/database/tables_creators_test.dart`
  - Utilizar `sqflite_common_ffi` para executar SQLite em memória nos testes.
  - Casos de teste:
    - Criação de todas as tabelas (`accounts`, `balance`, `category`, `transactions`, `transfers`, `ofx_*`, `users`, `icons`).
    - Validação de constraints (`PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `DEFAULT`).
    - Validação de índices criados para busca rápida por data e conta.
    - Teste de exclusão em cascata ou restrições de integridade.
    - Triggers de inserção/remoção atualizando o saldo do dia e todos os saldos posteriores.

- [x] **6.1.1. Tornar o Banco Testável**
  - Injetar `DatabaseFactory`, caminho do banco e filesystem no `DatabaseManager`.
  - Permitir banco em memória com `sqflite_common_ffi`, mantendo testes Android para diferenças de plataforma.
  - Fazer `_onCreate` propagar falhas e impedir bases parcialmente inicializadas.

- [x] **6.2. Testes de Migrações de Schema (`DatabaseMigrations`)**
  - **Arquivo**: `test/integration/database/database_migrations_test.dart`
  - Casos de teste:
    - Execução sequencial de cada versão suportada, de `1000` até a versão atual.
    - Inserção de dados pré-migração e verificação de integridade dos dados pós-migração.
    - Falha injetada em cada migração, com rollback e restauração garantida de `PRAGMA foreign_keys` via `try/finally`.

- [x] **6.3. Testes de Backup e Restauração (`DatabaseBackup`)**
  - **Arquivo**: `test/integration/database/database_backup_test.dart`
  - Casos de teste:
    - Exportação do estado do banco atual para arquivo de backup.
    - Restauração de arquivo de backup em base zerada e verificação de que todas as tabelas e registros batem com o original.
    - Tratamento de arquivos de backup corrompidos ou inválidos.
    - Compatibilidade de versão, permissões, cancelamento, falta de espaço e falha sem substituir parcialmente a base atual.

- [x] **6.4. Testes de Integração de Repositórios Reais com SQLite**
  - **Diretório**: `test/integration/repositories/`
  - Testar consultas complexas, paginações e agrupamentos em:
    - `TransactionRepository` (filtros por período, conta, categoria).
    - `BalanceRepository` (busca por range de datas).
    - `StatisticRepository` (somas e agregações para gráficos).

## Critérios de Aceite
- Testes de banco de dados executando em ambiente desktop/CI sem dependência de emulador Android/iOS via `sqflite_common_ffi`.
- Nenhuma falha de constraint ou perda de dados em migrações e rotinas de backup.

## Resultado

- O schema SQLite passou a ser validado em memória com `sqflite_common_ffi`.
- Foram cobertas tabelas, colunas obrigatórias, valores padrão, chaves estrangeiras, índices e triggers financeiros.
- O `DatabaseManager` passou a aceitar `DatabaseFactory` e fornecedor de caminho, permitindo bancos isolados em memória e em arquivos temporários.
- Falhas durante `_onCreate` deixaram de ser silenciosamente ignoradas.
- As migrações de `1000` até `1013` foram validadas sequencialmente, incluindo preservação de dados, rollback e restauração de `PRAGMA foreign_keys`.
- Transações manuais duplicadas foram removidas dos scripts `1008`, `1009` e `1010`, pois `Batch.commit()` já fornece atomicidade.
- Foi adicionada a migração `1013`, com índice composto para paginação por conta e data.
- Backup e restauração passaram a aceitar dependências injetáveis e a preservar backups anteriores quando uma nova exportação falha.
- Arquivos corrompidos, SQLite incompatível e versões futuras são rejeitados antes de substituir o banco atual.
- Backups legados suportados são aceitos e migrados antes do reinício dos repositórios.
- Falhas de backup, restauração e migração são propagadas sem prosseguir sobre estado parcial.
- Consultas reais de transações, saldos e estatísticas foram validadas com SQLite.
- A consulta estatística foi corrigida para não misturar transações de contas diferentes.
- Falhas de filesystem são cobertas pelo comportamento de exceção e substituição temporária; permissões e falta de espaço dependem da plataforma e não exigem emulador na suíte principal.
- `flutter analyze`: nenhuma ocorrência.
- `flutter test`: 370 testes aprovados.
- `git diff --check`: nenhuma inconsistência.