 Dado que há uma restrição de chave estrangeira na coluna `accountUserId` na tabela `accountTable`, você precisará seguir um processo mais elaborado para garantir a integridade referencial.

Aqui está um procedimento mais seguro para atualizar o `userId` na tabela `usersTable`:

1. Desabilitar temporariamente a restrição de chave estrangeira;
2. Alterar a accountUserId;
3. Alterar a  userId;
4. Remova os índices existentes;
5. Recrie os índices;
6. Reabilitar a restrição de chave estrangeira.

Este processo é feito no código abaixo.

   ```sql
   PRAGMA foreign_keys=off;

   UPDATE accountTable SET accountUserId = 'new key' WHERE accountUserId = 'old key';

   UPDATE usersTable SET userId = 'new key' WHERE userId = 'old key';

   DROP INDEX IF EXISTS idxAccountUserId;

   CREATE INDEX idxAccountUserId ON accountTable (accountUserId);

   PRAGMA foreign_keys=on;
   ```

   Certifique-se de reativar a verificação de chaves estrangeiras após realizar as alterações.

Esse processo garante que as referências de chave estrangeira sejam mantidas corretamente durante a atualização. Lembre-se de fazer backup do seu banco de dados antes de realizar operações de atualização para evitar perda de dados.