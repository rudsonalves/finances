# Backlog 05: Controllers e Gerenciamento de Estado

## Contexto
Os Controllers (baseados em `ChangeNotifier`) gerenciam os estados de tela, interagem com serviços e managers, e notificam a UI sobre carregamento (`isLoading`), dados atualizados e mensagens de erro.

## Prioridade
**P1 (Alta)**

## Módulos Alvo
- `lib/features/transaction/transaction_controller.dart`
- `lib/features/account/account_controller.dart`
- `lib/features/sign_in/sign_in_controller.dart`
- `lib/features/sign_up/sign_up_controller.dart`
- `lib/features/home_page/home_page_controller.dart`
- `lib/features/home_page/balance_card/balance_card_controller.dart`
- `lib/features/statistics/statistic_controller.dart`

---

## Tarefas

- [ ] **5.1. Testes do `TransactionController`**
  - **Arquivo**: `test/unit/features/transaction/transaction_controller_test.dart`
  - Casos de teste:
    - Inicialização e carregamento de categorias e contas disponíveis.
    - Alteração de tipo de transação (Receita / Despesa / Transferência).
    - Salvar transação com dados válidos (disparo correto para o manager, estado de loading e sucesso).
    - Salvar transação com erro (captura de erro, estado limpo, feedback ao usuário).
    - Edição e exclusão de transação existente.

- [ ] **5.2. Testes do `AccountController`**
  - **Arquivo**: `test/unit/features/account/account_controller_test.dart`
  - Casos de teste:
    - Carregar os saldos das contas conhecidas pelo repositório.
    - Calcular o total e transitar entre os estados inicial, loading, sucesso e erro.
    - Cobrir criação, edição e exclusão no componente que realmente expõe essas operações, ou mover as operações para o controller antes de testá-las nele.

- [ ] **5.3. Testes de Autenticação (`SignInController` e `SignUpController`)**
  - **Arquivos**:
    - `test/unit/features/sign_in/sign_in_controller_test.dart`
    - `test/unit/features/sign_up/sign_up_controller_test.dart`
  - Casos de teste:
    - Login bem-sucedido e atualização do estado; redirecionamento deve ser coberto no teste de widget/navegação.
    - Login com falha (credenciais incorretas, usuário não encontrado).
    - Cadastro de novo usuário e recuperação de senha.
    - Tratamento de exceções (`FirebaseAuthException`, erros de rede).

- [ ] **5.4. Testes do `HomePageController` e `BalanceCardController`**
  - **Arquivos**:
    - `test/unit/features/home_page/home_page_controller_test.dart`
    - `test/unit/features/home_page/balance_card_controller_test.dart`
  - Casos de teste:
    - Troca de conta selecionada e recarregamento dos cards de balanço e lista de transações recentes.
    - Troca de mês/período de visualização.
    - Ocultar/exibir saldo (privacidade).

## Critérios de Aceite
- Notificações de `notifyListeners()` validadas nos momentos corretos.
- Isolamento total de banco de dados e Firebase através de mocks.
