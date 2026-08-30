# Backlog 07: Widgets e Fluxos Críticos de Usuário

## Contexto
Após garantir a solidez das camadas de domínio, estado e dados, os testes de widgets e fluxos ponta a ponta asseguram que os componentes visuais respondem corretamente a inputs e que a navegação e experiência do usuário não sofrem regressões.

## Prioridade
**P2 (Média; fluxos que gravam dados são P1)**

## Módulos Alvo
- `lib/features/transaction/widgets/`
- `lib/features/home_page/balance_card/`
- `lib/common/widgets/`
- Fluxos completos de tela (Páginas principais)

---

## Tarefas

- [ ] **7.1. Testes de Widgets de Entrada e Validação de Formulário**
  - **Arquivo**: `test/widget/features/transaction/transaction_form_test.dart`
  - Casos de teste:
    - Exibição de mensagens de erro ao submeter formulário com campos vazios ou inválidos.
    - Seleção de categorias e atualização do ícone na UI.
    - Alternância entre abas de Despesa e Receita com atualização visual de cores (ex: verde para receita, vermelho para despesa).

- [ ] **7.2. Testes de Widgets de Apresentação de Dados**
  - **Arquivo**: `test/widget/features/home_page/balance_card_widget_test.dart`
  - Casos de teste:
    - Exibição de saldo positivo com tema/cor de crédito e saldo negativo com cor de alerta.
    - Comportamento de ocultar saldo (substituição do valor por máscara `••••••`).
    - Renderização de listas de transações vazias com mensagem amigável (*empty state*).

- [ ] **7.3. Smoke Tests de Widgets com Dependências Controladas**
  - **Diretório**: `test/widget/flows/`
  - Casos de teste:
    - **Fluxo 1**: Iniciar aplicativo -> Home carregada -> Clicar em Nova Transação -> Preencher e Salvar -> Verificar retorno à Home com saldo e lista atualizados.
    - **Fluxo 2**: Abrir importação OFX -> Selecionar arquivo de teste -> Confirmar transações importadas -> Verificar inclusão no extrato.

- [ ] **7.4. Testes E2E Reais**
  - **Diretório**: `integration_test/`
  - Executar em emulador/dispositivo com SQLite e canais de plataforma reais.
  - Cobrir login, criação de transação, transferência, reinício do app e importação OFX.
  - Usar Firebase Emulator Suite ou ambiente dedicado quando autenticação real fizer parte do cenário.

## Critérios de Aceite
- Testes de widget cobrindo os caminhos felizes e de erro dos formulários principais.
- Sem timers pendentes; usar pumps limitados e evitar `pumpAndSettle` sem limite em animações contínuas.
