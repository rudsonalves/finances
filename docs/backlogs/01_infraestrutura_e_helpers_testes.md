# Backlog 01: Infraestrutura e Helpers de Teste

## Contexto
Para viabilizar a criação de testes de unidade e integração rápidos e isolados, é necessário estabelecer a infraestrutura base de testes, mocks compartilhados e gerenciamento do Service Locator (`GetIt`).

## Prioridade
**P0 (Bloqueador para os demais testes)**

## Tarefas

- [ ] **1.1. Adicionar Dependências de Teste**
  - Adicionar `sqflite_common_ffi` em `dev_dependencies` no [pubspec.yaml](../../pubspec.yaml).
  - Garantir compatibilidade com `flutter_test` e `mocktail`.

- [ ] **1.2. Criar Estrutura de Pastas de Teste**
  - Criar diretórios:
    - `test/helpers/`
    - `test/unit/`
    - `test/integration/`
    - `test/widget/`

- [ ] **1.3. Implementar Gerenciador de Injeção de Dependências de Teste**
  - Refatorar os Managers para não armazenarem dependências do `GetIt` em campos `static final`.
  - Preferir serviços instanciáveis e dependências recebidas pelo construtor.
  - Criar `test/helpers/test_setup.dart` com funções `setupTestLocator()` e `tearDownTestLocator()`.
  - Tornar setup e teardown assíncronos e aguardar `locator.reset(dispose: true)`.
  - Permitir registrar mocks customizados ou mocks padrão para cada teste.

- [ ] **1.4. Mocks Compartilhados**
  - Criar `test/helpers/mocks.dart` com classes mock usando `mocktail`:
    - `MockAbstractBalanceRepository`
    - `MockAbstractTransactionRepository`
    - `MockAbstractAccountRepository`
    - `MockAbstractTransferRepository`
    - `MockAbstractCategoryRepository`
    - `MockAbstractUserRepository`
    - `MockAuthService`
    - `MockDatabase` / `MockDatabaseManager`

- [ ] **1.5. Geradores de Dados de Teste (Factories / Fixtures)**
  - Criar `test/helpers/fixtures/model_fixtures.dart` com métodos helpers:
    - `createFakeTransaction()`
    - `createFakeBalance()`
    - `createFakeAccount()`
    - `createFakeUser()`

- [ ] **1.6. Linha de Base e Gate de Qualidade**
  - Registrar a cobertura atual com `flutter test --coverage`.
  - Excluir arquivos gerados da métrica.
  - Adotar limite incremental no CI e exigir todos os cenários P0, sem usar 100% de cobertura como substituto de testes de comportamento.

## Critérios de Aceite
- Execução de `flutter test` roda com sucesso mesmo sem testes reais ainda.
- Qualquer suíte consegue aguardar setup e teardown sem reter instâncias ou estado entre testes.
