# Backlogs de Cobertura de Testes

Este diretório contém o planejamento mestre e a quebra detalhada das tarefas para estruturar e elevar a cobertura de testes da aplicação **Finances**.

## Estrutura dos Backlogs

| Arquivo                                                                                | Descrição                                                                        |     Prioridade      |
| :------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------- | :-----------------: |
| [00_plano_mestre_testes.md](00_plano_mestre_testes.md)                                 | **Plano Mestre**: Visão geral, matriz de riscos, arquitetura e fases.            |          -          |
| [01_infraestrutura_e_helpers_testes.md](01_infraestrutura_e_helpers_testes.md)         | **Fase 0**: Setup do ambiente de testes, mocks globais, GetIt e fixtures.        | **P0** (Bloqueador) |
| [02_regras_negocio_managers_financeiros.md](02_regras_negocio_managers_financeiros.md) | **Fase 1.1**: Regras de saldo, transações e transferências (`lib/manager/`).     |  **P0** (Crítica)   |
| [03_parser_e_managers_ofx.md](03_parser_e_managers_ofx.md)                             | **Fase 1.2**: Parsing e importação de extratos OFX (`lib/packages/ofx/`).        |  **P0** (Crítica)   |
| [04_validacoes_extensoes_modelos.md](04_validacoes_extensoes_modelos.md)               | **Fase 1.3**: Validadores, formatação monetária/datas e serialização de modelos. |    **P1** (Alta)    |
| [05_controllers_gerenciamento_estado.md](05_controllers_gerenciamento_estado.md)       | **Fase 2**: Controllers de tela e gerenciamento de estado (`ChangeNotifier`).    |    **P1** (Alta)    |
| [06_persistencia_migrations_backup.md](06_persistencia_migrations_backup.md)           | **Fase 1.2**: Schema, triggers, migrações e backup/restauração.                 | **P0/P1** (Crítica) |
| [07_widgets_e_fluxos_criticos.md](07_widgets_e_fluxos_criticos.md)                     | **Fase 4**: Testes de widgets e testes reais de integração no dispositivo.        | **P2** (Média)      |
| [08_inventario_e_regressao_de_bugs.md](08_inventario_e_regressao_de_bugs.md)           | Inventário contínuo de bugs, reprodução e testes de regressão.                  | **P0/P1**             |

---

## Ordem Recomendada de Execução

1. **[01_infraestrutura_e_helpers_testes.md](01_infraestrutura_e_helpers_testes.md)** - Criação da base técnica de testes.
2. **[02_regras_negocio_managers_financeiros.md](02_regras_negocio_managers_financeiros.md)** - Blindagem das regras de cálculo financeiro.
3. **[06_persistencia_migrations_backup.md](06_persistencia_migrations_backup.md)** - Triggers contábeis, migrações e recuperação de dados.
4. **[03_parser_e_managers_ofx.md](03_parser_e_managers_ofx.md)** - Blindagem da importação bancária.
5. **[04_validacoes_extensoes_modelos.md](04_validacoes_extensoes_modelos.md)** - Garantia de sanitização de inputs e integridade de dados.
6. **[05_controllers_gerenciamento_estado.md](05_controllers_gerenciamento_estado.md)** - Testes unitários de estado conforme as APIs atuais.
7. **[07_widgets_e_fluxos_criticos.md](07_widgets_e_fluxos_criticos.md)** - Testes visuais e de interação.
8. **[08_inventario_e_regressao_de_bugs.md](08_inventario_e_regressao_de_bugs.md)** - Processo contínuo, iniciado antes das correções.
