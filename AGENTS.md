# Diretrizes do projeto

## Estratégia de testes

- Automatize testes unitários, de widgets e de integração determinística, incluindo banco SQLite em memória, migrations, backup, repositórios, controllers, parsers e fluxos com dependências controladas.
- Trate como testes manuais os cenários E2E que dependam de dispositivo ou emulador, Firebase Emulator ou serviço externo, seletor nativo de arquivos, canais de plataforma, permissões do sistema, reinicialização real do aplicativo ou persistência entre execuções do processo.
- Não crie nem amplie automaticamente infraestrutura em `integration_test/` para esses cenários manuais. Em vez disso, forneça um roteiro manual reproduzível com pré-condições, passos, resultados esperados e evidências a registrar.
- Não execute testes manuais em nome do usuário. Oriente o usuário a executá-los no dispositivo ou emulador e aguarde os resultados informados por ele.
- Se um cenário E2E puder ser isolado de recursos externos e executado de forma determinística, cubra a lógica com testes de widget, integração ou smoke tests com dependências controladas.
