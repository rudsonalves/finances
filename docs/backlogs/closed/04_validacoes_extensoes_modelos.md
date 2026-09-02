# Backlog 04: Validações, Extensões e Modelos de Domínio

## Contexto
Modelos com falhas de serialização (`toMap`/`fromMap`) e validadores incorretos introduzem inconsistências silenciosas na persistência SQLite e na interface com o usuário.

## Prioridade
**P1 (Alta)**

## Módulos Alvo
- [lib/common/validate/account_validator.dart](../../lib/common/validate/account_validator.dart)
- [lib/common/validate/sign_validator.dart](../../lib/common/validate/sign_validator.dart)
- [lib/common/validate/transaction_validator.dart](../../lib/common/validate/transaction_validator.dart)
- `lib/common/extensions/` e `lib/common/models/extends_date.dart` (`ExtendedDate`, `MoneyMaskedText`, `AppScale`, etc.)
- `lib/common/models/` (`TransactionDbModel`, `BalanceDbModel`, `AccountDbModel`, `TransferDbModel`, `UserDbModel`, etc.)

---

## Tarefas

- [x] **4.1. Testes de Validadores de Formulário**
  - **Diretório**: `test/unit/common/validate/`
  - `SignValidator`:
    - Validação de e-mail (válido, inválido, vazio, espaços extras).
    - Validação de senha (mínimo de caracteres, regras de complexidade se aplicável).
    - Confirmação de senha (senhas iguais vs divergentes).
  - `TransactionValidator`:
    - Validação de descrição (tamanho mínimo/máximo, vazio).
    - Validação de valor monetário (zero, negativo, formato inválido).
    - Validação de data e conta selecionada.
  - `AccountValidator`:
    - Validação de nome da conta, saldo inicial e tipo de conta.

- [x] **4.2. Testes de Extensões e Utilitários**
  - **Diretório**: `test/unit/common/extensions/`
  - `ExtendedDate`:
    - Formatações de data para exibição e persistência.
    - Operações de início de mês, fim de mês, comparações (`isSameDay`, `isAfter`, `isBefore`).
  - `MoneyMaskedText`:
    - Formatação de valores (ex: `1234` -> `R$ 12,34`).
    - Conversão correta de string formatada para `double` / `int` (centavos) e vice-versa.
    - Separadores, símbolos e precisão nas localidades suportadas, incluindo arredondamento nos limites de centavo.
    - Edição de texto e máscara em tempo real.

- [x] **4.3. Testes de Serialização de Modelos (`toMap` / `fromMap` / `copyWith`)**
  - **Diretório**: `test/unit/common/models/`
  - Testar ida e volta (`Model -> toMap -> fromMap -> Model`):
    - `TransactionDbModel`
    - `BalanceDbModel`
    - `AccountDbModel`
    - `TransferDbModel`
    - `UserDbModel`
    - `CategoryDbModel`
  - Garantir tratamento correto de valores `null`, conversão de booleanos para inteiros SQLite (`0`/`1`) e tipos data/timestamp.

## Critérios de Aceite
- Todos os limites, entradas inválidas e regras financeiras possuem testes comportamentais; a cobertura não pode ser atingida com testes triviais.
- Testes de integridade bidirecional para todos os modelos de banco de dados.

## Resultado

- Validadores passaram a normalizar espaços e rejeitar entradas monetárias, datas e identificadores inválidos.
- Datas preservam instantes UTC, precisão recebida e limites mensais corretos.
- Formatação monetária respeita precisão, sinais e todas as localidades suportadas.
- Modelos aceitam valores `int` ou `double` provenientes de SQLite/JSON e preservam campos opcionais.
- Cópias de usuário não compartilham listas mutáveis.
- Escalas de interface respondem a mudanças nas dimensões da tela.
- Suíte completa de testes aprovada.