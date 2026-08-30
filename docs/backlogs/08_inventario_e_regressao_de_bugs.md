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

- [ ] Transferência pode deixar registros parciais e suprime exceções.
- [ ] Atualização de transação remove e reinsere sem atomicidade.
- [ ] Falha de criação do schema é apenas registrada em log.
- [ ] Falha de migração pode deixar foreign keys desativadas.
- [ ] Avaliar deriva monetária causada pelo uso de `double` e SQLite `REAL`.

## Critério de aceite

Nenhum bug P0/P1 é encerrado sem teste de regressão automatizado e validação de que uma falha não deixa dados parciais.
