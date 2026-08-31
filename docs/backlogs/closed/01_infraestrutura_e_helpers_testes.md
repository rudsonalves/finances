# Backlog 01: Infraestrutura e Helpers de Teste

## Contexto
Para viabilizar a criação de testes de unidade e integração rápidos e isolados, é necessário estabelecer a infraestrutura base de testes, mocks compartilhados e gerenciamento do Service Locator (`GetIt`).

## Prioridade
**P0 (Bloqueador para os demais testes)**

## Tarefas

- [x] **1.1. Adicionar Dependências de Teste**
  - Adicionar `sqflite_common_ffi` em `dev_dependencies` no [pubspec.yaml](../../pubspec.yaml).
  - Garantir compatibilidade com `flutter_test` e `mocktail`.

- [x] **1.2. Criar Estrutura de Pastas de Teste**
  - Criar diretórios:
    - `test/helpers/`
    - `test/unit/`
    - `test/integration/`
    - `test/widget/`

- [x] **1.3. Implementar Gerenciador de Injeção de Dependências de Teste**
  - Refatorar os Managers para não armazenarem dependências do `GetIt` em campos `static final`.
  - Preferir serviços instanciáveis e dependências recebidas pelo construtor.
  - Criar `test/helpers/test_setup.dart` com funções `setupTestLocator()` e `tearDownTestLocator()`.
  - Tornar setup e teardown assíncronos e aguardar `locator.reset(dispose: true)`.
  - Permitir registrar mocks customizados ou mocks padrão para cada teste.

- [x] **1.4. Mocks Compartilhados**
  - Criar `test/helpers/mocks.dart` com classes mock usando `mocktail`:
    - `MockAbstractBalanceRepository`
    - `MockAbstractTransactionRepository`
    - `MockAbstractAccountRepository`
    - `MockAbstractTransferRepository`
    - `MockAbstractCategoryRepository`
    - `MockAbstractUserRepository`
    - `MockAuthService`
    - `MockDatabase` / `MockDatabaseManager`

- [x] **1.5. Geradores de Dados de Teste (Factories / Fixtures)**
  - Criar `test/helpers/fixtures/model_fixtures.dart` com métodos helpers:
    - `createFakeTransaction()`
    - `createFakeBalance()`
    - `createFakeAccount()`
    - `createFakeUser()`

- [x] **1.6. Linha de Base e Gate de Qualidade**
  - Registrar a cobertura atual com `flutter test --coverage`.
  - Excluir arquivos gerados da métrica.
  - Adotar limite incremental no CI e exigir todos os cenários P0, sem usar 100% de cobertura como substituto de testes de comportamento.

## Critérios de Aceite
- Execução de `flutter test` roda com sucesso mesmo sem testes reais ainda.
- Qualquer suíte consegue aguardar setup e teardown sem reter instâncias ou estado entre testes.

## Resultado

- Linha de base em 31/08/2026: **0,16%** das linhas instrumentadas (13 de 8.061).
- O gate inicial impede regressão abaixo dessa linha de base e deve subir a cada backlog implementado.
- Código gerado (`lib/l10n/`, `*.g.dart`, `*.freezed.dart` e `firebase_options.dart`) não participa da métrica.
