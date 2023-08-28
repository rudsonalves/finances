# Finance App (pt_BR)

By *rudsonalves67@gmail.com*

The intention of this project is to develop an application to assist in user budget control, allowing the creation and management of accounts. The project was inspired by the diagram published on Figma, [Financy-App](https://www.figma.com/file/vQzApZhqZFDFp1td5K4asQ/Financy-App?type=design&mode=design&t=EFvH3bvOxfe8hSap-0), and was initially developed based on videos from the YouTube channel [@devkaio](https://www.youtube.com/@devkaio), to which I am very grateful for the good practices and interesting ideas that helped implement the project.

## Code Development

This project aims to enhance my knowledge in the Flutter SDK and the entire ecosystem involved in application development.

Overall, the project is being developed following a feature-based architecture, where components and modules related to a specific feature are grouped into a logical structure, facilitating code comprehension and maintenance.

Pages are built using the State pattern, where the page's construction changes when its internal state changes. Generally, a page will have a module with an abstract class, and its subclasses extend this abstract class to define their different states. A second control module is responsible for managing the states used in the page's construction. The third module is responsible for building the page itself, depending on the current state.

The Service Locator used is *get_it*, which provides a way to centralize and obtain instances of necessary services throughout the application. It is also capable of generating Singleton objects and on-demand instances, offering great flexibility in resource distribution and control.

## Project Planning

1. The first version of the application will have the following features:

   - Creation and management of accounts in Firebase;
   - Local database with all wallet information;
   - Local login control (*flutter_secure_storage*);
   - Implementation of a settings page with:
     - Theme control;
     - Language selection;
     - Other product information (possibly an *About* page);
   - Support for Portuguese and English languages;
   - Single wallet functionality.

2. For upcoming versions, the plan includes:

   - Support for multiple wallets;
   - Addition of general graphical analysis;
   - Support for one more language (Spanish).

## Resources

Initially, the application will only manage financial movements for one wallet. In future versions, I plan to implement graphical financial analysis, projections, and support for multiple wallets.

The application uses the following packages:

- **get_it: ^7.6.0** - provides access to application components throughout the widget tree. Service Locator;
- **firebase_auth: ^4.6.1** - authentication;
- **firebase_core: ^2.13.0**;
- **flutter_secure_storage: ^8.0.0** - storage of login information and application status. Eventually, I plan to replace it with the *sqflite* package;
- **sqflite: ^2.2.8+4** - database for storing user wallet information;
- **path_provider: ^2.0.15** - obtaining commonly used locations in the host platform's file system, such as temporary and application data directories;
- **path: ^1.8.3** - library for path manipulation based on strings;
- **intl: ^0.18.0** - will be used for date formatting and parsing;
- **flutter_localization: ^3.0.2** - Flutter's standard internationalization;
- **dynamic_color: ^1.6.5** - Flutter package to create material color schemes based on dynamic platform-specific color implementations.

The project also uses icons from [Material Symbols](https://fonts.google.com/icons).

## Database

### 1. Table "usersTable":

This table is used to store information about users, such as their IDs, names, email addresses, and login status (0 - false and 1 - true), theme, language, and others.

### 2. Table "accountTable":

This table is used to store information about user accounts. Each account has an ID, a name, an associated user ID, and an image.

Index created for the *accountUserId* column.

The *accountLastBalance* column has been added to store the ID of the last balance recorded in the wallet. Financial movement queries will start from this balance and move backward in time until finding a balance with a null *balancePreviousId*, indicating that this is the first balance recorded in this wallet. Similarly, the *balanceNextId* of the balance with an *id* equal to *accountLastBalance* should be null, indicating that this is the last balance recorded in the account.

### 3. Table "balanceTable":

This table is used to store information about wallet balances on the specified *balanceDate*. Each entry in the table represents a specific balance in a wallet. Fields include the ID of the associated wallet, the balance ID, the IDs of the previous and next balances, as well as the opening and closing values of the balance. Essentially, this table is a linked list of balances.

Index created for the *balanceDate* and *balanceAccountId* columns.

A null value in *balancePreviousId* indicates that this is the first balance recorded in this account. Similarly, a null value in *balanceNextId* indicates that this is the last balance recorded in this account.

### 4. Table "categoriesTable":

This table is used to store information about categories of financial transactions. Each category has an ID, a name, and an associated image.

Index created for the *categoryName* column.

### 5. Table "transactionsTable":

This table is used to store information about financial transactions. Each transaction has an ID, a description, a category ID, a value, a status, and a date.

Index created for the *transDate* column.

A *transTransferId* column was added to store the ID of a transfer between accounts. This column can be null, indicating that the transaction is not a transfer between accounts. This column was added to facilitate the identification of transactions related to a transfer, as well as the data of this transfer.

### 6. Table "transDayTable":

This table is used to relate specific transactions to specific balances in the *balanceTable*. It is used as a junction table to create a relationship between transactions and balances in wallets.

### 7. Table "transfersTable":

This table maintains information about the IDs of transactions and the accounts where a transfer was initiated.

### 8. Table "versionControlTable":

This table was created to maintain control over database versions.

### 9. Table "iconsTable":

This table maintains icon definitions (name, fontFamily, color) used in categoriesTable and accountsTable.

![Database Diagram](docs/databaseDiagram.jpg)

### Triggers

Two triggers were created to validate entries in the *balanceNextId* and *balancePreviousId* columns in the *balanceTable*. In the trigger bodies, it is checked whether the value inserted in *balanceNextId* or *balancePreviousId* is null or corresponds to a valid *balanceId* in the *balanceTable*. Otherwise, an error is generated.

With these triggers in place, any attempt to insert an invalid value in *balanceNextId* or *balancePreviousId* will result in an error, and the insertion operation will be interrupted, thus maintaining the referential

 integrity of this data.


# Bug Fixes and Implementations

Some bugs were noticed and need to be fixed:

- *20230623.3.* Implementation: There are currently two functions in the *lib/common/functions* directory;
- *20230818.3* Bug: o back está levando para a página de apresentação. Trocar pela página inicial.

These bug fixes and implementations will help improve the user experience and make the app more complete and stable.


# Aplicativo de Finanças (pt_BR)

Por *rudsonalves67@gmail.com*

A intenção deste projeto é desenvolver um aplicativo para auxiliar no controle do orçamento do usuário, permitindo a criação e gerenciamento de contas. O projeto foi inspirado no diagrama publicado no Figma, [Financy-App](https://www.figma.com/file/vQzApZhqZFDFp1td5K4asQ/Financy-App?type=design&mode=design&t=EFvH3bvOxfe8hSap-0), e foi inicialmente desenvolvido com base nos vídeos do canal do YouTube [@devkaio](https://www.youtube.com/@devkaio), do qual sou muito grato pelas boas práticas e ideias interessantes que ajudaram a implementar o projeto.

## Desenvolvimento do Código

Este projeto tem como objetivo aprimorar meus conhecimentos no SDK Flutter e em todo o ecossistema envolvido no desenvolvimento do aplicativo.

No geral, o projeto está sendo desenvolvido seguindo uma arquitetura baseada em funcionalidades, na qual os componentes e módulos relacionados a uma determinada funcionalidade são agrupados em uma estrutura lógica, facilitando a compreensão e a manutenção do código.

As páginas são construídas usando o padrão State, no qual a construção da página é alterada quando seu estado interno muda. Em geral, uma página terá um módulo com uma classe abstrata e suas subclasses estendem essa classe abstrata para definir seus diferentes estados. Um segundo módulo de controle é responsável por gerenciar os estados utilizados na construção da página. O terceiro módulo é responsável pela construção da própria página, dependendo do estado atual.

O Service Locator utilizado é o *get_it*, que fornece uma maneira de centralizar e obter instâncias de serviços necessários ao longo do aplicativo. Ele também é capaz de gerar objetos Singleton e sob demanda, oferecendo uma grande flexibilidade na distribuição e controle dos recursos.

## Planejamento do Projeto

1. A primeira versão do aplicativo terá as seguintes características:

   - Criação e gerenciamento de contas no Firebase;
   - Banco de dados local com todas as informações das carteiras;
   - Controle local de login (*flutter_secure_storage*);
   - Implementação de uma página de configurações com:
     - Controle de tema;
     - Seleção de idioma;
     - Outras informações sobre o produto (possivelmente uma página *Sobre*);
   - Suporte aos idiomas português e inglês;
   - Funcionalidade de carteira única.

2. Para as próximas versões, está planejado:

   - Suporte a múltiplas carteiras;
   - Adição de análises gráficas gerais;
   - Suporte a mais um idioma (espanhol).

## Recursos

Inicialmente, o aplicativo irá gerenciar apenas a movimentação financeira de uma carteira. Em versões futuras, pretendo implementar análises gráficas das finanças, projeções e suporte a várias carteiras.

O aplicativo utiliza os seguintes pacotes:

- **get_it: ^7.6.0** - fornece acesso a componentes do aplicativo ao longo da árvore de widgets. Service Locator;
- **firebase_auth: ^4.6.1** - autenticação;
- **firebase_core: ^2.13.0**;
- **flutter_secure_storage: ^8.0.0** - armazenamento de informações de login e status do aplicativo. Eventualmente, pretendo substituí-lo pelo pacote *sqflite*;
- **sqflite: ^2.2.8+4** - banco de dados para armazenamento das informações das carteiras do usuário;
- **path_provider: ^2.0.15** - obtenção de locais comumente usados no sistema de arquivos da plataforma host, como diretórios temporários e de dados do aplicativo;
- **path: ^1.8.3** - biblioteca para manipulação de caminhos baseada em strings;
- **intl: ^0.18.0** - será usado para formatação e análise de datas;
- **flutter_localization: ^3.0.2** - internacionalização padrão do Flutter;
- **dynamic_color: ^1.6.5** - pacote Flutter para criar esquemas de cores de materiais com base na implementação de cores dinâmicas de uma plataforma.

O projeto também utiliza os ícones do [Material Symbols](https://fonts.google.com/icons).

## Banco de Dados

### 1. Tabela "usersTable":

Essa tabela é usada para armazenar informações sobre os usuários, como seus IDs, nomes, endereços de e-mail e estado de login (0 - false e 1 - true), tema, linguagem e outros.

### 2. Tabela "accountTable":

Essa tabela é usada para armazenar informações sobre as contas dos usuários. Cada conta possui um ID, um nome, um ID de usuário associado e uma imagem.

Índice criado para a coluna *accountUserId*.

A coluna *accountLastBalance* foi adicionada para armazenar o ID do último saldo registrado na carteira. As consultas de um lançamento financeiro irão começar por este saldo e retroceder no tempo até encontrar um saldo com *balancePreviousId* nulo, indicando que este é o primeiro saldo registrado nesta carteira. De forma semelhante, o *balanceNextId* do saldo com *id* igual a *accountLastBalance* deve ser nulo, indicando que este é o último saldo registrado na conta.

### 3. Tabela "balanceTable":

Essa tabela é usada para armazenar informações sobre os saldos das carteiras na data especificada em *balanceDate*. Cada entrada na tabela representa um saldo específico em uma carteira. Os campos incluem o ID da carteira associada, o ID do saldo, os IDs do saldo anterior e seguinte, bem como os valores de abertura e fechamento do saldo. Essencialmente, essa tabela é uma lista encadeada dos saldos.

Índice criado para as colunas *balanceDate* e *balanceAccountId*.

Um valor nulo em *balancePreviousId* indica que este é o primeiro saldo registrado nesta conta. De forma semelhante, um valor nulo em *balanceNextId* indica que este é o último saldo registrado nesta conta.

### 4. Tabela "categoriesTable":

Essa tabela é usada para armazenar informações sobre as categorias das transações financeiras. Cada categoria possui um ID, um nome e uma imagem associada.

Índice criado

 para a coluna *categoryName*.

### 5. Tabela "transactionsTable":

Essa tabela é usada para armazenar informações sobre as transações financeiras. Cada transação possui um ID, uma descrição, um ID de categoria, um valor, um status e uma data.

Índice criado para a coluna *transDate*.

Foi adicionada uma coluna *transTransferId* para armazenar a ID de uma transferência entre contas. Esta coluna pode ser nula, indicando que a transação não se trata de uma transferência entre contas. Esta coluna foi adicionada para facilitar a identificação das transações relativas a uma transferência, bem como os dados desta transferência.

### 6. Tabela "transDayTable":

Essa tabela é usada para relacionar transações específicas com saldos específicos na tabela *balanceTable*. Ela é usada como uma tabela de junção para criar uma relação entre transações e saldos nas carteiras.

### 7. Tabela "transfersTable":

Esta tabela mantém as informações das IDs das transações e das contas onde uma transferência foi criada.

### 8. Tabela "versionControlTable":

Esta tabela foi criada para manter o controle de versões do banco de dados.

### 9. Tabela "iconsTable":

Esta tabela mantém as definições de ícones (nome, fontFamily, cor), usadas em categoriesTable e accountsTable

![Diagrama do Banco de Dados](docs/databaseDiagram.jpg)

### Gatilhos

Foram criados dois gatilhos (triggers) para validar as entradas das colunas *balanceNextId* e *balancePreviousId* na tabela *balanceTable*. No corpo dos gatilhos, é verificado se o valor inserido em *balanceNextId* ou *balancePreviousId* é nulo ou corresponde a um *balanceId* válido na tabela *balanceTable*. Caso contrário, um erro é gerado.

Com esses gatilhos em vigor, qualquer tentativa de inserir um valor inválido em *balanceNextId* ou *balancePreviousId* resultará em um erro, e a operação de inserção será interrompida, mantendo assim a integridade referencial desses dados.

# Changes:

## 2023/08/28:

In this committee, four changes were made to the project:

- The project was renamed to "finances" and moved to another repository with the same name.
- Three more colors were added to the project's color palette: lightblue, lightgreen, and lightyellow.
- The line 'final locale = AppLocalizations.of(context)!' was moved from the beginning of the initState() method in the SignInPage class to inside the anonymous function within _controller.addListener. This was necessary to avoid an error during app execution.
- The methods 'Future<void> signInButton()' and 'void signUpButton()' were extracted from the build block of the SignUpPage class. This change was purely cosmetic, resulting in a more coherent code organization.

## 2023/08/27:

Adjusted iconData, decided to keep iconData being constructed by the app. Completed app internationalization using ChatGPT for message translation. Changes are as follows:
 * android/build.gradle:
   - Updated to version 1.7.10.
 * lib/common/functions/function_alert_dialog.dart:
 * lib/common/widgets/color_button.dart:
 * lib/features/category/category_page.dart:
 * lib/features/category/widgets/add_category_dialog.dart:
 * lib/features/category/widgets/dismissible_category.dart:
 * lib/features/category/widgets/icon_selection_dialog.dart:
 * lib/features/database_recover/database_recover.dart:
 * lib/features/home_page/home_page.dart:
 * lib/features/settings/settings_page.dart:
 * lib/features/sign_in/sign_in_page.dart:
 * lib/features/statistics/statistic_card/statistic_card.dart:
 * lib/features/statistics/statistics_page.dart:
   - Added internationalization.
 * lib/common/widgets/markdown_text.dart:
   - Created this module to generate RichText from Markdown phrases. Currently supports only bold text.
 * lib/features/account/account_page.dart:
   - Implemented the use of MarkdownText;
   - Added internationalization.
 * lib/l10n/app_en.arb:
 * lib/l10n/app_en_US.arb:
   - Added new texts;
   - Corrected spelling of some texts.
 * lib/l10n/app_es.arb:
 * lib/l10n/app_pt.arb:
 * lib/l10n/app_pt_BR.arb:
   - Revised translations.

## 2023/08/25

Changes:

 * android/app/build.gradle:
   - Added support for `firebase-analytics`.
   
 * android/app/google-services.json:
   - Updated.
   
 * lib/common/constants/themes/colors/custom_color.g.dart:
   - Added the red color, but it's causing some issues. I should redo the color scheme.
   
 * lib/features/account/account_page.dart:
   - Now, to delete an account, all transactions need to be removed first. Otherwise, the delete will be blocked.
   - A call to `locator.get<BalanceCardController>().requestRedraw()` is now made to redraw the `BalanceCard` when an account is added, modified, or deleted.
   
 * lib/features/home_page/balance_card/balance_card_controller.dart:
   - Added a `requestRedraw()` method to request the redraw of the `BalanceCard`.
   
 * lib/features/home_page/home_page.dart:
   - The `HomePage` is now redrawn only if a local command is requested.
   
 * lib/features/home_page/widgets/cart_popup_menu_buttons.dart:
   - Removed some debugging options from the `HomePage` menu.
   
 * lib/features/home_page_view/home_page_view.dart:
   - Added an `await`, which was apparently missing, and a call to `locator.get<StatisticsController>().requestRedraw()` to the `addTransaction()` method.
   
 * lib/features/statistics/statistic_controller.dart:
   - Added a `redraw` getter and a `requestRedraw()` method to schedule a statistics reconstruction.
   
 * lib/features/statistics/statistics_page.dart:
   - Now, the page remains static and is only redrawn when a transaction is added, edited, or removed.
   - This process is implemented by overriding the `didUpdateWidget` method, which is called every time the page gains or loses focus.
   
 * lib/locator.dart:
   - `TransactionController` is now registered as a `LazySingleton`. This was done to allow better control of the `HomePage` redraw, but it ended up not being used. It's marked for testing and removal if not needed.
   - `StatisticsController` registered as a `LazySingleton` for controlling the `StatisticsPage` redraw.
   
 * lib/services/database/sqflite_helper.dart:
   - `countTransactionsForAccountId` was fixed to properly count transactions for an account.
   
 * lib/services/logger/app_logger.dart:
   - This is under consideration for adding the `logger` package to the project.


## 2023/08/24b:

* android/build.gradle:
   - kotlin_version changed to 1.8.0.
* lib/common/models/extends_date.dart:
   - Fixed the bug on line 34. Changed from date.microsecond to date.millisecond;
   - Simplified the getMillisecondsIntervalOfMonth method by adding the methods _isLeapYear(int year) and _lastDayOfMonth(ExtendedDate date) and removing the _isLeap getter.
* lib/features/settings/settings_page_controller.dart:
* lib/features/settings/settings_page_state.dart:
* lib/features/settings/settings_page.dart:
   - The SettingsPage now utilizes a controller to manage the state. This was necessary to access the app version;
   - The app version is displayed on this page.
* lib/features/statistics/statistic_card/statistic_card.dart:
   - The state of this card is now controlled by the same controller as the StatisticPage.
* lib/features/statistics/statistic_controller.dart:
   - _incomes and _expenses have been transformed into Map<String, double>, with strDate as the key;
   - _statisticsList has been transformed into Map<String, List<StatisticResult>>, also with strDate as the key;
   - List<String> _strDates contains the list of strDate keys;
   - The strDate getter returns the strDate at _index;
   - The _index attribute holds the index of the selected strDate key;
   - The methods nextMonth() and previousMonth() switch between strDate keys.
* lib/features/statistics/statistics_page.dart:
   - The StatisticsPage class has been modified to use strDate as the index for statistics;
   - The rest of the class has been adapted to use the new attributes from StatisticsController.
* pubspec.yaml:
   - Added the package_info_plus package to gather app information.

## 2023/08/24:

* lib/common/widgets/custom_modal_bottom_sheet.dart:
   - The CustomModalBottomSheet now automatically resizes to adjust to the size of the displayed message.
* lib/features/database_recover/database_recover.dart:
   In this class, several code improvements have been implemented to enhance readability and flexibility. These include:
   - Addition of the enum DialogStates {create, restore, createRestore} to customize the type of dialog to be presented.
   - Introduction of the DialogStates dialogState attribute to choose the appropriate dialog type to display.
   - Inclusion of methods dialogMessage(), dialogCreateBackup(), dialogRestoreBackup(), and dialogDivider() to enhance code readability.
* lib/features/settings/settings_page.dart:
   - Adjusted the SettingsPage to appropriately select the DatabaseRecover dialog.
* lib/features/sign_in/sign_in_page.dart:
   - Modified the customModalBottomSheet call to display the DatabaseRecover(dialogState: DialogStates.restore) dialog if necessary.

## 2023/08/23:

  * android/app/src/main/AndroidManifest.xml:
    - added permission for the app to write and read in the device's storage area.
  * lib/common/widgets/custom_modal_bottom_sheet.dart:
    - at this first moment I added a button to restore data. This process will still be improved.
  * lib/common/widgets/secondary_button.dart:
    - I reimplemented this button with an OutlinedButton.
  * lib/features/database_recover/database_recover.dart:
    - controls the app's recover/backup dialog. I shall separate and improve this process later on.
  * lib/features/settings/settings_page.dart:
    - simplified it with just one button to call the recover/backup dialog.
  * lib/features/sign_in/sign_in_controller.dart:
    - just simplified some log messages to be less informative.
  * lib/features/sign_in/sign_in_page.dart:
    - Added the button to call the recover/backup dialog in the initState() method.
  * lib/features/statistics/statistic_card/statistic_card.dart:
    - some aesthetic tweaks. There is a bug in this code that is presenting the header and information out of sync.
  * lib/repositories/account/sqflite_account_repository.dart:
  * lib/repositories/backup/backup_repository.dart:
  * lib/repositories/category/category_repository.dart:
  * lib/repositories/category/sqflile_category_repository.dart:
  * lib/repositories/user/sqflite_user_repository.dart:
    - added restart() method to restart repository
  * lib/repositories/backup/sqlflite_backup_repository.dart:
    - control layer over sqflite to manage app backup/restore.
  * lib/services/database/database_helper.dart:
  * lib/services/database/sqlflite_helper.dart:
    - adjusted the Scheme database version;
    - added dbSchemeVersion() method to format database Scheme version;
    - added backupDatabase([String? destinyDir]) method to backup app database;
    - added method Future<bool> restoreDatabase(String newDbPath) to restore app database.
  * pubspec.yaml:
    - added file_picker package to generate dialog to access device directory tree.
   
## 2023/08/22:

Changes:
 * lib/common/constants/themes/icons/fontello_icons_codes.dart:
   - Added 6 more custom icons: sign-language, microchip, alimony, bill, services.
 * lib/common/functions/card_income_function.dart:
   - Added a function to assemble Incomes/Expenses for the Cards on the HomePage and Statistics pages.
 * lib/common/validate/sign_validator.dart:
   - Reduced the password validation requirement to only letters and numbers, up to 6 characters.
 * lib/common/widgets/autocomplete_text_form_field.dart:
   - Now removes focus from the widget after selecting one of the suggestions in AutocompleteTextFormField.
 * lib/features/account/widgets/dismissible_account_card.dart:
 * lib/features/home_page/balance_card/balance_card.dart:
   - Residues in the balance were causing negative values of 0.00. These operation residues have been removed to ensure the integrity of operations;
   - In BalanceCard, the method _incomeExpenseShowValue has also been removed and separated into an exclusive module for reuse by other Cards.
 * lib/features/home_page/home_page_controller.dart:
   - The maximum number of transactions to be presented on the HomePage is now an attribute of HomePageController and can be changed directly;
   - The function getNextTransactions can also receive an integer attribute "more" to limit the number of new transactions to be collected.
 * lib/features/statistics/statistic_card/statistic_card.dart:
 * lib/features/statistics/statistic_controller.dart:
 * lib/features/statistics/statistic_state.dart:
 * lib/features/statistics/statistics_page.dart:
   - Created a basic statistics page. This is not the final page yet, but it will be a starting point.
 * lib/services/database/sqflite_helper.dart:
   - The transDayTable has been changed to have only transDayTransId as the primary key;
   - The method getTransactionSumsByCategory({required int startDate, required int endDate}) has been added to return the sum of transactions in categories within the date range from startDate to endDate.

## 2023/08/19:

In this commit, I made the following changes:

1. I modified the prefixes of the `TransferDbModel` class and its associated elements from "transf" to "transfer". Additionally, I removed the `transfValue` and `transfDate` attributes as they were not being used.

2. I reviewed the logs to eliminate unnecessary ones, including debug logs. Furthermore, I improved the content of the remaining logs within the application.

3. I fixed a bug in the `AccountDropdownFormField` widget, which was related to incorrect usage of `accountId` instead of `accountName`. Now, the widget correctly returns the account name throughout the app.

Here's a breakdown of the changes in each file:

- `lib/common/models/transfer_db_model.dart`
- `lib/features/transaction/transaction_controller.dart`
- `lib/repositories/transfer_repository/sqflite_transfer_repository.dart`
- `lib/services/database/managers/transfers_manager.dart`
- `lib/services/database/sqflite_helper.dart`
  - Attributes now use the prefix "transfer" instead of "transf".
  - The attributes `transfValue` and `transfDate` have been removed.

- `lib/common/widgets/account_dropdown_form_field.dart`
  - I fixed a bug in the widget. Now, the widget correctly returns the `accountName` instead of the previously returned `accountId`, which was incorrect. `accountName` is now the default throughout the application.

- `lib/features/home_page/home_page.dart`
- `lib/features/home_page/widgets/transaction_dismissible_tile.dart`
  - I changed the class name `TransactionListTile` to `TransactionDismissibleTile` to better align with similar approaches in other parts of the project.

- `lib/features/sign_in/sign_in_page.dart`
- `lib/features/sign_up/sign_up_page.dart`
  - I modified the permanent logs to provide clearer error indications.

## 2023/08/18:

In this commit, several bugs were fixed. The description of the changes is provided below:

* lib/features/category/category_controller.dart:
  - Added a `WidgetsBinding.instance.addPostFrameCallback` before `notifyListeners` to synchronize frame rendering. This is used to enqueue the callback to the end of the next frame's layout.
  - Multiple calls to `_changeState` were removed, and the responsibility of state change is now concentrated solely within the `getAllCategories` method.

* lib/features/category/category_page.dart:
  - `addCategory()` has been converted into a `Future` function.
  - The ElevatedButton for adding now invokes the `AddCategoryDialog` class within a `showDialog` instead of the `statefullAddCategoryDialog`.

* lib/features/category/widgets/add_category_dialog.dart:
  - New class introduced to replace the `statefullAddCategoryDialog`. Issues with the `dispose` of `TextEditingController` used in the dialog prompted a more conventional approach to resolve the problem.

* lib/features/category/widgets/dismissible_category.dart:
  - Now utilizes the `AddCategoryDialog` class within a `showDialog` instead of the `statefullAddCategoryDialog`.

* lib/features/category/widgets/statefull_add_category_dialog.dart:
  * lib/features/category/statefull_category_dialog.dart:
  - These modules were removed from the app.

* lib/features/transaction/transaction_controller.dart:
  - Added a missing `override` to the `accountIdByName` method.

## 2023/08/17:

This commit completes the implementation of transfers between accounts and fixes bugs in the process. More tests still need to be executed, however, the functionality of transferring values between accounts is working well. Below is a detailed breakdown of the changes:

 * lib/common/models/category_db_model.dart:
   - Improved the `toString()` method details by adding more information.
 * lib/common/widgets/account_dropdown_form_field.dart:
   - Added the default value to the `AccountDropdownFormField` class. The default account value is passed to the widget through a `TextEditingController` as a string. This value, known as `accountName`, is then converted to `accountId` using the new `accountIdByName` method in the `AccountRepository`.
 * lib/features/account/widgets/statefull_add_account_dialog.dart:
   - Now the `currentAccount` is updated when it undergoes any changes.
 * lib/features/category/widgets/statefull_add_category_dialog.dart:
   - I'm still facing issues with this stateful dialog. The `categoryController`, used in the form to control the category name, is being disposed of before closing the dialog or something similar. This has been marked as a TODO to be investigated more carefully later on. Currently, a 200ms delay is resolving the issue.
 * lib/features/transaction/transaction_controller.dart:
   - I had to add the `Future<void> getTransferAccountName` method to the `TransactionController` to load the account name to be edited in the case of a transfer.
 * lib/features/transaction/transaction_page.dart:
   - Added a call to load the account name to be edited in the case of a transfer in the `initState()` of `TransactionPageState`.
   - The destination account's `accountId` is retrieved through the `accountName` passed by `_accountController.text` (a `TextEditingController`) in the `addAction()` method.
   - The `_categoryId` is retrieved from the transaction passed to `TransactionPage`.
 * lib/repositories/account/sqflite_account_repository.dart:
   - Added the `accountIdByName` method to retrieve the `accountId` by `accountName`.
 * lib/repositories/category/sqflile_category_repository.dart:
   - Added a default category for Inputs, along with the Transfers category.
 * lib/services/database/managers/transfers_manager.dart:
   - Added documentation to the `updateTransfer` method. In the current version, the update is done by removing transactions from the previous transfer and creating a new transaction.
 * lib/services/database/sqflite_helper.dart:
   - Fixed a bug in the `deleteTransfer` method. The use of the `transferId` attribute was conflicting with the internal attribute of the `SqfliteHelper` class.

## 2023/08/16:

In this commit, various changes were made to the code, ranging from bug fixes to the implementation of account transfers, along with several other modifications. Below are more detailed descriptions of the changes:

* `lib/common/constants/themes/icons/trademarks_icons_codes.dart`:
   - Added new icons: citibank, jpmorgan_chase, wellsfargo, goldmansachs, itaubank, authelia, bradesco_bank.

* `lib/common/models/account_db_model.dart`:
* `lib/common/models/balance_db_model.dart`:
* `lib/common/models/card_balance_model.dart`:
* `lib/common/models/category_db_model.dart`:
* `lib/common/models/icons_model.dart`:
* `lib/common/models/language_model.dart`:
* `lib/common/models/trans_day_db_model.dart`:
* `lib/common/models/user_db_model.dart`:
   - Cosmetic changes in the `toString()` method.

* `lib/common/models/transaction_db_model.dart`:
   - Modified the `toString()` method.
   - The `transStatus` attribute is now an enum `TransStatus{transactionNotChecked, transactionChecked}`.
   - Added the `copyToTransfer()` method to generate a copy of the transaction with the inverted `transValue`.
   - Simplified the `toMap()` method.
   - Adjusted the `factory TransactionDbModel.fromMap` method.
   - Added the `Future<void> updateTransaction()` method to update the transaction in the database.

* `lib/common/models/transfer_db_model.dart`:
   - Created a model for transfers.

* `lib/common/validate/sign_validator.dart`:
   - Corrected email validation. Now, it's necessary to have two to three characters at the end of the email.

* `lib/common/widgets/account_dropdown_form_field.dart`:
   - Created a dropdown list for selecting accounts.

* `lib/common/widgets/category_dropdown_form_field.dart`:
   - Renamed the `CustomDropdownFormField` class to `CategoryDropdownFormField`, as the class is specialized in handling categories.
   - The items are now loaded directly from `categoryRepository.categoriesMap.keys.toList()`.

* `lib/common/widgets/custom_floating_action_button.dart`:
   - Renamed the `TransactionFloatingButton` class to `CustomFloatingActionButton`, as it's a more generic class.

* `lib/features/account/account_page.dart`:
   - The base `Card` was replaced by a `Container` to adjust colors and standardize the app.

* `lib/features/category/category_controller.dart`:
   - Now, only the `getAllCategories()` method manages the states in `CategoryState`. There were issues with excessive calls to `getAllCategories()` that led to state conflicts. The updated approach now requires calling `getAllCategories()` to update the categories.

* `lib/features/category/category_page.dart`:
   - Removed the `TextEditingController _categoryController` from this page and moved it to the widget that uses it.
   - Added the `addCategory()` and `callBack()` methods to manage page refreshing.
   - Replaced the `Card` widget with a `Container` to adjust colors and standardize the app.

* `lib/features/category/statefull_category_dialog.dart`:
   - This dialog is temporarily disabled, with its content commented out. I'm still considering whether to utilize it.

* `lib/features/category/widgets/dismissible_category.dart`:
   - Added control to preserve category with ID 1 for account transfers. Category with ID 1 can be edited but not deleted.

* `lib/features/category/widgets/statefull_add_category_dialog.dart`:
   - This dialog now creates its own `TextEditingController` for the category. The issue of disposing this controller still needs to be resolved.

* `lib/features/home_page/home_page.dart`:
   - Now, this page is redrawn with each call.

* `lib/features/home_page/widgets/cart_popup_menu_buttons.dart`:
   - Made minor adjustments to the main page menu.

* `lib/features/home_page/widgets/transaction_list_tile.dart`:
   - Added removal of transfers.

* `lib/features/home_page_view/home_page_view.dart`:
   - The `HomePageView` now passes the `addTransaction` or `AddAccount` function to the `floatingActionButton` based on the open page.

* `lib/features/onboarding/onboarding_page.dart`:
   - Simplified the images presented in the `OnboardingPage`.

* `lib/features/sign_in/sign_in_controller.dart`:
   - Added the option for password recovery to the `SignInController`.

* `lib/features/sign_in/sign_in_page.dart`:
   - Added widgets and code for requesting password changes.

* `lib/features/sign_up/sign_up_page.dart`:
* `lib/features/splash/splash_page.dart`:
   - The disposal order in these classes, along with others using the `dispose()` method, had the sequence of disposal changed. Now, `super.dispose()` is the first to be released.

* `lib/features/transaction/transaction_page.dart`:
   - Adjusted the order of disposal.
   - The `addAction()`

 method now checks if a destination `AccountDbModel` (`account1`) was passed. If `account1` is provided, it's loaded into `account1` for use in an account transfer.
   - If `account1` (destination account) is passed, a transfer between accounts is initiated. Otherwise, only a transaction is recorded.
   - Added an `AccountDropdownFormField` to receive the destination account for a transfer.

* `lib/locator.dart`:
   - New locators registered: `TransferRepository` and `AccountController`.

* `lib/repositories/account/sqflite_account_repository.dart`:
   - Added the `getAccount` method to retrieve an account by its ID.

* `lib/repositories/transfer_repository/transfer_repository.dart`:
* `lib/repositories/transfer_repository/sqflite_transfer_repository.dart`:
   - Added the `TransferRepository` (abstract) and `SqfliteTransferRepository` classes to handle account information in the database.

* `lib/services/authentication/auth_service.dart`:
* `lib/services/authentication/firebase_auth_service.dart`:
   - Added the `recoverPassword` method for password recovery.

* `lib/services/database/database_helper.dart`:
* `lib/services/database/sqflite_helper.dart`:
   - Added the `insertTransfer` method to insert a transfer into the database.
   - Added the `updateTransaction` method to update a transfer in the database.
   - Added the `deleteTransDay` method to remove a transfer from the database.
   - Added the `queryTransDay` method to load a transfer from the database.
   - The logging methods were separated into various individual methods: `logTransactions()`, `logBalances()`, `logTransDay()`, `logTransfers()`, `logCategories()`.
   - Added a method for creating the `transfersTable` table.

* `lib/services/database/managers/account_manager.dart`:
* `lib/services/database/managers/balance_manager.dart`:
* `lib/services/database/managers/transactions_manager.dart`:
* `lib/services/database/managers/transfers_manager.dart`:
   - Several methods were reviewed and had varying levels of documentation added.

## 2023/08/05:

  * lib/common/current_models/current_account.dart:
    - added method changeCurrentAccount to change CurrentAccount
  * lib/common/models/extends_date.dart:
    - lastDayOfMonth was corrected to handle the last day of the month of December;
    - getter lastDayOfTheMonth returns the last day of the current month.
  * lib/common/models/icons_model.dart:
    - iconWidget method receives new color attribute to change default color if a color is provided.
  * lib/features/account/account_controller.dart:
    - totalBalance getter returns the total balance of all accounts.
  * lib/features/account/account_page.dart:
    - some aesthetic changes in AccountPage.
  * lib/features/account/widgets/dismissible_account_card.dart:
    - Added a Padding with a bottom of 8 pixels to separate the accounts.
    - I changed the Card order with Dismissible. Now the Card is called as a child of Dismissible.
  * lib/features/category/category_page.dart:
    - CategoryPage has been re-enabled to replace StatefulCategoryDialog. The StatefulCategoryDialog code is still present in the project, but it is currently disabled.
  * lib/features/home_page/balance_card/balance_card.dart:
    - replaced the function 'Function(bool) balanceCallBack' by 'Function(AccountDbModel account) balanceCallBack', which receives an account as an attribute;
    - Fixed BalanceCard size.
  * lib/features/home_page/balance_card/balance_card_controller.dart:
    - added a _balanceDate attribute, to keep the date of the month enabled in CardBalance;
    - added accountsList and accountsMap getters to return accounts;
    - in method 'changeState(BalanceCardState newState)' a call WidgetsBinding.instance.addPostFrameCallback was added to invoke notifyListeners(). This was necessary for stacking calls to notifyListeners;
    - added the setBalanceDate(ExtendedDate date) method to update the BalanceCard date.
  * lib/features/home_page/home_page.dart:
    - added attribute LastDate ExtendedDate to manage date in BalanceCard;
    - the helpDialog method was moved to this page, but it should be remodeled and moved in the future;
    - the Badge widget was replaced by a call to helpDialog;
    - added lastDate control to update BalanceCard date.
  * lib/features/home_page/home_page_controller.dart:
    - added changeCurrentAccount method;
    - simplified the getNextTransactions method.
  * lib/features/home_page/widgets/cart_popup_menu_buttons.dart:
    - changed the call to CategoryPage.
  * lib/features/home_page/widgets/transaction_list_tile.dart:
    - removal of the helpDialog method for the HomePage;
    - addition of a Padding;
    - swap position between Card and Dismissible widgets.
  * lib/repositories/transaction/sqflite_transaction_repository.dart:
  * lib/repositories/transaction/transaction_repository.dart:
    - does getCardBalance get one more ExtendedDate attribute? date, to select the month of the balance request.

## 2023/08/02:

In this commit I added color support to icons and made some tweaks to the WalletPage implementation, still in progress.
  * docs/convert_font_config_json_to_map.py:
    - python code to convert json into list of iconNames vs. iconsCode.
  * docs/databaseDiagram.jpg:
    - new database diagram with addition of icons table and its use in walletsTable and categoriesTable tables.
  * lib/common/constants/themes/app_icons.dart:
    - a non-instantiable class for icon support with the methods:
      - IconsFontFamily(String fontFamilyName) - returns an IconsFontFamily named fontFamilyName;
      - iconNames(IconsFontFamily fontFamily) - returns the list of icon names from the fontFamily family;
      - IconData? iconData(String iconName, [IconsFontFamily fontFamily = IconsFontFamily.MaterialIcons]) - returns the iconData of the iconName and fontFamily family.
  * lib/common/constants/themes/icons/material_icons_codes.dart:
    - Map<String, int> materialIconsCodes with the names of the MaterialIcons icons.
  * lib/common/constants/themes/icons/trademarks_icons_codes.dart:
    - Map<String, int> trademarkIconsCodes with the names of the TrademarkIcons icons.
  * lib/common/current_models/current_wallet.dart:
  * lib/common/models/category_db_model.dart:
  * lib/common/models/wallet_db_model.dart:
    - changes in the CurrentWallet, WalletDbModel and CaterogyDbModel classes to accept the IconModel walletIcon as a parameter;
  * lib/common/models/categories_icons.dart:
    - the CategoriesIcons class seems to me to be a remnant of code developed over the many changes I had to make to add the icons to the project. This code will likely be removed in the future. At the moment all it does is filter icon names to display in the icon selection dialog.
  * lib/common/models/icons_model.dart:
    - declaration of the IconModel class to handle the App's icons;
    - this class has the following attributes: int? iconId; String iconName; IconsFontFamily iconFontFamily; int iconColor.
    - in addition to the classic toMap, fromMap, toJson, fromJson and toString methods, this class has the iconWidget({double? size}) method, which returns an icon widget.
  * lib/common/widgets/color_button.dart:
    - this class adds a button for selecting colors.
  * lib/common/widgets/custom_dropdown_form_field.dart:
  * lib/features/category/category_controller.dart:
  * lib/features/category/widgets/dismissible_category.dart:
  * lib/features/category/widgets/icon_selection_dialog.dart:
  * lib/features/category/widgets/select_icon_row.dart:
  * lib/features/category/widgets/statefull_add_category_dialog.dart:
    - tweaked to employ iconWidget({double? size}) method of IconModel class.
  * lib/features/wallet/add_wallet/add_wallet.dart:
  * lib/features/wallet/add_wallet/dismissible_wallet_card.dart:
  * lib/features/wallet/wallet_controller.dart:
  * lib/features/wallet/wallet_page.dart:
    - implementations to WalletPage.
* lib/locator.dart:
    - changes to CurrentWallet's registerLazySingleton to add a default wallet;
    - added registerLazySingleton to the IconRepository class.
  * lib/repositories/category/category_repository.dart:
  * lib/repositories/category/sqflile_category_repository.dart:
    - replacement of method `String getNameById(int id)` by `CategoryDbModel getCategoryId(int id)`;
    - the addCategory method now adds its icon before adding the new category;
    - method updateCategory now updates its icon before updating the category;
  * lib/repositories/wallet/sqflite_wallet_repository.dart:
    - separate method to create a new wallet, named _addOnly;
    - _addOnly first adds the new icon before creating the new wallet;
    - updateWallet updates the icon before updating the wallet.
  * lib/repositories/icons/icons_repository.dart:
  * lib/repositories/icons/sqlite_icons_repository.dart:
    - addition of a repository to handle the icons.
  * lib/services/database/database_helper.dart:
    - addition of methods: Future<int> insertIcon(Map<String, dynamic> iconMap); Future<int> updateIcon(Map<String, dynamic> iconMap); Future<Map<String, dynamic>?> queryIconId(int id); and Future<void> deleteIconId(int id);
    - the deleteIconId method should not be used too often, as the icons are tied to the category and wallet that created them via the database;
  * lib/services/database/sqlflite_helper.dart:
    - in addition to the addition of the previously described methods, addition of the _createIconsTable(batch) method for creating the icon table;
     - change of walletsTable and categoriesTable tables to use iconsTable ids as walletIcon and categoryIcon, respectively. The deletion in these tables is connected in cascade to the deletion of the respective icons in the iconsTable.
     - made adjustments to _recordMigration and _updateMigration methods for database migration control.
     - _getCurrentDatabaseSchemeVersion - has also been changed to adjust database migration control. Database migration still needs further testing.
   * pubspec.yaml:
     - added to the project flutter_colorpicker package for color control and
     - the TrademarkIcons font, with some trademark icons.

## 2023/07/25:

  * lib/common/current_models/current_wallet.dart:
    - added a constructor to the CurrentWallet class;
    - attribute walletDescription was added to CurrentWallet class.
  * lib/common/models/categories_icons.dart:
    - this class has been simplified and now uses the AppMaterialIcons class, presented below;
    - loadIcons(), init(), and getIconPath() methods have been removed. They are no longer needed;
    - added to list of Strings _iconsList to store a list with icon names;
    - listOfIconsContains now only queries the _iconsList list;
    - getIconData was added in place of the getIconImage method. Instead of returning the path to the icon, this method returns the IconData for the passed iconName.
  * lib/common/models/wallet_db_model.dart:
    - In the WalletDbModel class, the walletDescription attribute was added.
  * lib/common/validate/wallet_validator.dart:
    - a validator to validate walletName and walletDescription.
  * lib/common/widgets/basic_text_form_field.dart:
    - added support for focusNode attribute in BasicTextFormField.
  * lib/common/widgets/custom_dropdown_form_field.dart:
  * lib/common/widgets/custom_dropdown_form_field.dart:
  * lib/features/category/widgets/icon_selection_dialog.dart:
  * lib/features/category/widgets/select_icon_row.dart:
  * lib/features/home_page/widgets/transaction_list_tile.dart:
  * lib/features/transaction/transaction_page.dart:
    - replaced categoriesIcons.getIconPath call with categoriesIcons.getIconData.
  * lib/features/wallet/add_wallet/add_wallet.dart:
  * lib/features/wallet/wallet_controller.dart:
  * lib/features/wallet/wallet_page.dart:
    - added dialog for inserting a new wallet.
  * lib/services/database/sqlflite_helper.dart:
    - added table for version control;
    - added walletDescription in walletTable table;
    - openDatabase method now checks if there is any update script for the database;
    - added _createVersionControlTable private method to create a version control table;
    - added _applyMigrations private method for applying migrations in version control table.

## 2023/07/21b:

In this commit I transferred the CategoryPage page to a dialog, as I found this behavior more appropriate. I also fixed the 'More transaction' button so that the ListView would not restart every time a new transaction was read from the database. Finally, I changed and added the internationalizations related to most of the changes made in these last commits. Below is a description of the updates:

 * lib/common/constants/themes/app_button_styles.dart:
   - this module sets default color style for application buttons.
 * lib/common/widgets/add_cancel_buttons.dart:
   - Newte module replaced the IconButton widgets with ElevatedButton.icon and applied the AppButtonStyles.primaryButtonColor(context) style to standardize the button's colors.
 * lib/features/category/category_controller.dart:
   - state control has been removed from the getAllCategories method. It is no longer necessary;
   - added an await to _categoryRepository.getCategories(), which now reloads the category list.
 * lib/features/category/category_page.dart:
   - this page should be removed in future releases.
 * lib/features/category/statefull_category_dialog.dart:
   - this module creates a statefull dialog to control the categories, eliminating the CategoryPage angito.
 * lib/features/category/widgets/category_text_form_field.dart:
   - renamed to expressly switch TextField to TextFormField, and support validation.
 * lib/features/category/widgets/dismissible_category.dart:
   - modified to work stateless, as used in other pages. This widget has been turned into a dialog, and it is no longer convenient to handle it with the state control.
 * lib/features/category/widgets/statefull_add_category_dialog.dart:
   - functions cancelCallback and addCallback were moved to the beginning of the code;
   - the statefullAddCategoryDialog function no longer has a return;
   - added a callBack function to the function's attributes to notify parent widgets of being redrawn;
   - the CategoryTextFormField (formerly CategoryTextField) is now built into a form to allow validation;
   - to prevent the dialog from generating a category with a null name, a validation was added to the category name.
 * lib/features/home_page/home_page.dart:
   - HomePage now supports reading old transactions. Loading these transactions does not change the position displayed by the ListView.
 * lib/features/home_page/home_page_controller.dart:
   - getNextTransactions method no longer changes the HomePage state, but notifies listeners to redraw the screen. This was necessary for the ListView to maintain its position after loading older transactions.
 * lib/features/home_page/widgets/cart_popup_menu_buttons.dart:
 * lib/features/transaction/transaction_page.dart:
   - TranslationPage now invokes a dialog for adding/editing categories.

## 2023/07/21:

In this commit, I implemented a "more transactions" button and added an autocomplete for the description field in the TransactionsPage. See the description below for more details:
 * lib/common/current_models/current_balance.dart:
   - added a factory contructor CurrentBalance.fromWalletDbModel(BalanceDbModel balance).
 * lib/common/models/user_db_model.dart:
   - replace the default language 'en' by 'en_US'.
 * lib/common/widgets/autocomplete_text_form_field.dart:
   - added a AutocompleteTextformField class to use the description of old transactions to autocomplete descriptions entry in the new transactions.
 * lib/features/home_page/home_page.dart:
   - added a 'more transactions' button in the ListView to open the oldest transactions in the HomePage.
 * lib/features/home_page/home_page_controller.dart:
   - added a ExtendedDate _lastDate variable to track the date of the last transaction displayed on the HomePage. If _lastDate is null, there are no more transactions in the current wallet;
   - the _updateLastDate() method was created to check if the last balance has a balancePreviousId equal to null, if true set _lastDate to null too;
   - getNextTransactions() method get the more old transactions from database, using _lastDate as starting date.
 * lib/features/transaction/transaction_page.dart:
   - replaced BasicTextFormField with AutocompleteTextFormField and added transaction descriptions as suggestions to the description field.

## 2023/07/20:

 * lib/common/constants/routes/app_route.dart:
 * lib/features/category/category_page.dart:
   - renamed AddCategoryPage to CategoryPage.
 * lib/common/current_models/current_balance.dart:
 * lib/features/home_page/home_page_controller.dart:
 * lib/features/transaction/transaction_controller.dart:
   - BalanceManager and TransactionsManager are now non-intanciable class, that is, they only have static methods.
 * lib/common/widgets/image_header.dart:
 * lib/common/widgets/main_app_bar.dart:
   - removed from the code. This codes have been disable for a long time
 * lib/common/widgets/row_of_two_bottons.dart:
 * lib/common/widgets/widget_alert_dialog.dart:
 * lib/features/category/widgets/categories_header.dart:
 * lib/features/category/widgets/category_text_field.dart:
 * lib/features/category/widgets/dismissible_category.dart:
 * lib/features/category/widgets/icon_selection_dialog.dart:
 * lib/features/category/widgets/statefull_category_dialog.dart:
 * lib/features/home_page/home_page_controller.dart:
   - these widgets have been translated.
 * lib/l10n/app_en.arb, app_en_US.arb, ...:
   - added news messages in translation.
 * lib/features/transaction/transaction_page.dart:
   - fixed category list update on TransactionPage.
 * lib/locator.dart:
 * lib/services/database/transactions_manager/balance_manager.dart:
 * lib/services/database/transactions_manager/transactions_manager.dart:
 * lib/services/database/transactions_manager/wallet_manager.dart:
   - Lazy Singleton TransactionsManager and BalanceManager have been removed from locator.dart. Now these classes are non-instanciable with statics methods.

## 2023/07/19:

In this commit, I added basic support to wallet page. The main wallet is now visible on the WalletPage and the balance getter has been implemented. See the main changes below:

 * lib/common/current_models/current_wallet.dart:
   - added a CurrentWallet.fromWalletDbModel factory constructor to return a CurrentWallet from a passed WalletDbModel. This is needed to construct a CurrentWallet, which is not the actual current balance.
 * lib/features/home_page/balance_card/balance_card.dart:
   - now balance value is returned from currentBalance.
 * lib/features/home_page_view/home_page_view.dart:
   - now the locator.get<BalanceCardController>().getBalance() is executed after locator.get<HomePageController>().getTransactions() completes.
 * lib/features/wallet/wallet_controller.dart:
   - added a wallet controller to control WalletPage construction;
   - walletsDataList is a simple list of SimpleWalletData {walletName, walletBalance (the current day's closed balance), walletImage}, a simples class to saving basic wallets informations. This informaqions are used to build the wallets list in WalletPage.
 * lib/features/wallet/wallet_page.dart:
   - a basic wallet page. This page has changed in future versions.
 * lib/features/wallet/wallet_state.dart:
   - WalletStates class.
 * lib/repositories/balance/sqflite_balance_repository.dart:
 * lib/repositories/balance/balance_repository.dart:
   - getBalanceInDate signature has changed. Now a balanceId can be passed to return a non-current wallet balance.
 * lib/repositories/wallet/sqflite_wallet_repository.dart:
   - added a getter to walletsList, a list of wallets.
 * lib/services/database/database_helper.dart:
   - now queryBalanceId searches the database only by balanceId. walletId is not longer required;
   - rawQueryTransForBalanceId has its return order inverted to DESC, to correct a bug in the transactions order.
 * lib/services/database/transactions_manager/balance_manager.dart:
   - the BalanceManager method now receives a wallet attribute (a CurrentWallet objetc, but not a current wallet, necessarily) to allow injecting a balance into the list of non-current balances;
   - a _reloadCurrentBalance() method was added in the addValue and subtractValue methods to update eventual changes in the currentBalance.
 * lib/services/database/transactions_manager/transactions_manager.dart:
   - minor changes to possibly turn this class into a non-instanciable class.
 * lib/services/database/transactions_manager/wallet_manager.dart:
   - a non-instanciable class to get current wallet balance, for now.

## 2023/07/17:

In this commit I added support for language ant theme selection in the app. For now, the settings are displayed on the profile page, in the future I will create a suitable configuration paga for this.

Language supporte was not provided by easy_localization package as intended. I didn't find advantages in its use compared to use of intl and flutter_localization packages, the flutter standards.

The main changes in this commir were:

 * l10n.yaml:
   - stores the information to auto genetate the language files;
   - added an untranslated-message-file as untranslated_messages.txt, to list pending translations.
 * lib/app.dart:
   - I changed the ValueListenableBuilder widget to use AnimatedBuilder to enable use of the Listenable.merge. This is necessary to listen currentTheme.themeMode$ and currentLanguage.locale$ simultaneously;
   - added locale attribute as currentLanguage.locale to select locale as per currentLanguage object;
   - for theme control replace valueThemeMode with currentTheme.themeMode. The currentTheme class now controls the app's theme.
 * lib/common/current_models/current_language.dart:
   - extended class of LanguageModel for language control in app.
 * lib/common/current_models/current_theme.dart:
   - new class for in-app theme control.
 * lib/common/current_models/current_user.dart:
   - added the applyCurrentUserSettings() method to change apply the settings of the logged in user to the app.
 * lib/common/models/language_model.dart:
   - module created to manage the app's language.
   - supportedLanguages - a constant map with supported languages. the idea is that only this map is changed to support new languages by the app.
   - the LanguageModel class controls the basic language properties and methods in the app.
 * lib/common/models/user_db_model.dart:
   - added userTheme and userLanguage to store the theme and language used by the user.
 * lib/features/sign_in/sign_in_controller.dart:
 * lib/features/splash/splash_controller.dart:
   - apply theme and language settings to the app with CurrentUser.applyCurrentUserSettings().
 * lib/l10n/app_en.arb:
 * lib/l10n/app_en_US.arb:
 * lib/l10n/app_es.arb:
 * lib/l10n/app_pt.arb:
 * lib/l10n/app_pt_BR.arb:
   - templates to generate the language files.
 * lib/locator.dart:
   - removed the AppSettings and
   - added CurrentTheme and CurrentLanguage as LazySingleton
 * lib/services/database/sqlflite_helper.dart:
   - added database support for userTheme and userLanguage.
 * pubspec.yaml:
   - added 'generate: true' option to generate language files from *.arb in lib/l10n/.
 * lib/common/validate/sign_validator.dart:
 * lib/common/validate/transaction_validator.dart:
 * lib/common/widgets/add_cancel_buttons.dart:
 * lib/features/home_page/balance_card/balance_card.dart:
 * lib/features/home_page/home_page.dart:
 * lib/features/onboarding/onboarding_page.dart:
 * lib/features/profile/profile_page.dart:
 * lib/features/sign_in/sign_in_page.dart:
 * lib/features/sign_up/sign_up_page.dart:
 * lib/features/splash/splash_page.dart:
 * lib/features/statistics/statistics_page.dart:
 * lib/features/transaction/transaction_page.dart:
 * lib/features/wallet/wallet_page.dart:
   - all these pages and widgets have been set to use internationalization. It is quite possible that some widgets have gone unnoticed in this first change and are pending for a future edition.

I also moved a series of folder modules which generated many changes not commented here, but they are only due to the change of modules directory.

## 2023/07/11:

Changes:

In this commit, the database was remodeled to better maintain the necessary information in the app. The final structure of the database is presented in the README.md of this project. Here are the changes from this commit.

 * lib/common/constants/models/balance_db_model.dart:
   - to differ from the models for the database of other models in the app, a "_db_" was added to the name of the code files, as well as a "Db" was added to the name of the classes;
   - the BalanceDbModel class now contains a control of the daily balance, as well as a counter of transactions posted on the balance sheet;
   - the ExtendedDate class is used as a date control in the class. ExtendedDate is shown below.
 * lib/common/constants/models/card_balance_model.dart:
   - this module is the former balance_model.dart, which has been renamed to better represent its use in the application and integration with the stateful CardBalance widget. In short, this class has been simplified to explicitly meet the needs of the CardBalance widget.
 * lib/common/constants/models/category_db_model.dart:
 * lib/common/constants/models/trans_day_db_model.dart:
 * lib/common/constants/models/transaction_db_model.dart:
 * lib/common/constants/models/user_db_model.dart:
 * lib/common/constants/models/wallet_db_model.dart:
   - the same as was done to balance_db_model.dart.
 * lib/common/constants/models/extends_date.dart:
   - this module is an adaptation of custom_date.dart.
   - now the ExtendedDate class extends from the DateTime class and adds some necessary implementations for the app, in addition to supplementing unnecessary features of the ExtendedDate class;
   - factory ExtendedDate.nowDate() - adds a named constructor to generate a new ExtendedDate with just the current date;
   - static (int, int) getMillisecondsIntervalOfMonth(ExtendedDate date) - implements a static method to return the interval of a month in millisecondsSinceEpoch. This is used to generate the balance and will also be used to generate statistics in the app;
   - ExtendedDate get onlyDate - a getter to return only the date (hours = 0, minutes = 0, sec = 0);
   - ExtendedDate nextDay(), previusDay(), nextMonth() - generate an ExtendedDate of the next day, previous day and next month, respectively;
   - implements support for operators >, >=, <, <= and == through direct comparison of the ExtendedDate millisecondsSinceEpoch.
 * lib/common/generals/current_balance.dart:
 * lib/common/generals/current_user.dart:
 * lib/common/generals/current_wallet.dart:
   - this modules were created to keep the current balance, current user and current wallet in use in the app. These are singletons created and accessed throughout its app code, with the informations:
   - the balance of the current day;
   - the information of the logged in user;
   - from the wallet opened in the app.
   - these new classes also have init() methods to start them, when necessary, and specific methods for their operation.
 * lib/features/category/category_controller.dart:
   - the constructor of the CategoryController class no longer receives a parameter. Now the CategoryRepository is loaded via getIt.get<CategoryRepository>();
   - no longer has _categories list. This has been replaced by direct access to the list in categoryRepository.categories;
   - categoryNames is now a getter for categoryRepository.categoriesMap.keys.toList();
   - added a categoryRepository.init() in the init() of the class;
   - method removeCategory now returns void;
   - categoryImage, addCategory and updateCategory methods were remodeled, since the category list control is now done by categoryRepository.
 * lib/features/category/category_page.dart:
   - CategoryPage has been adapted to work with the new CategoryRepository and CategoryController guidelines.
 * lib/features/category/widgets/dismissible_category.dart:
 * lib/features/category/widgets/statefull_category_dialog.dart:
 * lib/features/category/widgets/icon_selection_dialog.dart:
   - have also been adjusted to accommodate changes to CategoriesIcons and CategoryController.
 * lib/features/home_page/balance_card/balance_card.dart:
 * lib/features/home_page/balance_card/balance_card_controller.dart:
   - adjusted to accommodate changes in CardBalanceModel.
 * lib/features/home_page/home_page.dart:
 * lib/features/home_page/home_page_controller.dart:
 * lib/features/home_page/widgets/transaction_list_tile.dart:
   - adjusted to accommodate changes to HomePageController, BalanceCardController, CurrentUser, CurrentWallet and CurrentBalance.
 * lib/features/home_page/widgets/cart_popup_menu_buttons.dart:
   - at the moment some changes were made to generate test logs.
 * lib/features/home_page_view/home_page_view.dart:
 * lib/features/profile/profile_page.dart:
 * lib/features/statistics/statistics_page.dart:
 * lib/features/wallet/wallet_page.dart:
   - adjusted to accommodate changes to CurrentUser, CurrentWallet and CurrentBalance.
 * lib/features/sign_in/sign_in_controller.dart:
 * lib/features/sign_in/sign_in_page.dart:
 * lib/features/sign_up/sign_up_controller.dart:
 * lib/features/sign_up/sign_up_page.dart:
 * lib/features/splash/splash_controller.dart:
 * lib/features/splash/splash_page.dart:
   - Several changes were made to the login and splash control pages. Between them:
     - when creating an account, the user receives a default wallet, configured as currentWallet;
     - a new balance is generated, if there is none, for the current day in the open wallet;
     - Logged user registration now uses a flag, userLogged, and no longer by secure_store package.
 * lib/features/transaction/transaction_controller.dart:
   - no receives arguments in the constructor;
   - addTransactions and updateTransactions now use TransactionsManager to add/update a transaction;
 * lib/features/transaction/transaction_page.dart:
   - adjusted for changes in transactionControle and CategoryRepository.
 * lib/locator.dart:
   - due to changes in the project, several objects became Singleton, being started by demand. This generated many problems in the code during the implementations, generating many changes in the initialization of these objects. I had to carefully review each class and its obligations to fit this file.
 * lib/main.dart:
   - adjusted app startup for the new changes.
 * lib/repositories/balance/balance_repository.dart:
 * lib/repositories/balance/sqflite_balance_repository.dart:
   - added to handle connections between database and app actions regarding adding, removing and updating a balance.
 * lib/repositories/category/category_repository.dart:
 * lib/repositories/category/sqflile_category_repository.dart:
   - the categoryRepository now maintains a Map<String, CategoryDbModel> with all categories created in the app. As there are few categories, I thought it reasonable to keep them in memory while the app is running.
 * lib/repositories/trans_day/trans_day_repository.dart:
 * lib/repositories/trans_day/sqflite_trans_day_repository.dart:
   - added to handle connections between database and app actions with respect to adding, removing and updating a transDay.
 * lib/repositories/transaction/transaction_repository.dart:
 * lib/repositories/transaction/sqflite_transaction_repository.dart:
   - these modules are responsible for the first layer of abstraction between the database and the transactions in the app. As a first layer they just translate information between the database and how transactions are handled in the app. Transactions management by the app is done by TransactionsManager, described below;
   - these modules underwent several changes to restrict their responsibilities only to the level of translation between the database and the app. This was necessary because the addition/removal and updating of new transactions started to require other information and actions, with the launch of balances, insertions and removals in the transDayTable, among others.
 * lib/repositories/user/user_repository.dart:
 * lib/repositories/user/sqflite_user_repository.dart:
   - just like the CategoryRepository, the UserRepository also keeps in memory the user list registered in the system. Motivations are the same as used in CategoryRepository. In general, 1 to 2 users are expected in the same app and therefore little information is retained in memory.
 * lib/repositories/wallet/wallet_repository.dart:
 * lib/repositories/wallet/sqflite_wallet_repository.dart:
   - the same as above.
 * lib/services/database/database_helper.dart:
 * lib/services/database/sqlflite_helper.dart:
   - the database was completely restructured to meet the needs of the project. See the documentation for more details.
   - elsewhere I removed unused code and renamed several methods to clearer and more objective names.
 * lib/services/database/transactions_manager/balance_manager.dart:
 * lib/services/database/transactions_manager/transactions_manager.dart:
   - these classes were created to manage balances and transactions in the app. This was necessary to simplify the maintenance of modules in the app's code, keeping each module with limited and clear responsibilities.

## 2023/07/07:

Changes:
 * added the attribut balanceTransCount in balance to count the number of transactions carried out in a balance;
 * balance injection has been removed from CurrentBalance code to BalanceRepository as injectBalance method;

## 2023/06/27:

Changes:
The colors were all adjusted to the theme using Material3. Three colors are customized as Extended Colors:
  - SubPrimary: has Tone 30 above Primary;
  - SubTertiary: has Tone 30 above Tertiary;
  - MediumPrimary: an intermediate Tone between Primary and SubPrimary.
The other changes are shown below:
 * lib/common/constants/themes/app_colors.dart:
   - now AppColors uses the context to get the colors of the theme in use. There are still a few tweaks to the dark theme.
 * lib/common/constants/themes/colors/color_schemes.g.dart:
 * lib/common/constants/themes/colors/custom_color.g.dart:
   - updated theme to a blue one.
 * lib/common/extensions/app_scale.dart:
   - I created an AppScale class to store the application's scale. At the moment this is only being used to adjust the text size, but I intend to extend its use in the future.
 * lib/common/widgets/app_top_border.dart:
   - This class only generates the bottom part of the screen decoration. This was about to be removed from the code, but I managed to resolve the issues with the AppBar and am using an implementation of it for the app.
 * lib/common/widgets/custom_app_bar.dart:
   - This is the CustomAppBar class, which customizes an AppBar with the properties:
     * automaticallyImplyLeading: false;
     * foregroundColor: can be colorScheme.onPrimary or colorScheme.tertiary, depending on the enableColor flag;
     * elevation: 0;
     * scrolledUnderElevation: 0.0. This guarantees that no crease will be generated at the base of the AppBar when a ListView is moved upwards;
     * flexibleSpace: a Container with the app's decoration colors.
   Otherwise, the class replicates an AppBar.
 * lib/common/widgets/image_header.dart:
 * lib/common/widgets/main_app_bar.dart:
   - removed from the code. They are no longer used.
 * lib/features/category/category_page.dart:
 * lib/features/home_page/balance_card/balance_card.dart:
 * lib/features/profile/profile_page.dart:
 * lib/features/statistics/statistics_page.dart:
 * lib/features/wallet/wallet_page.dart:
   - all these pages had their AppBar replaced by the CustomAppBar class.
 * lib/features/category/widgets/categories_header.dart:
   - just some cosmetic changes.
 * lib/features/category/widgets/dismissible_category.dart:
   - bug fix.
 * lib/features/splash/splash_controller.dart:
   - added a 1 second delay for the screen to be displayed.
 * lib/features/transaction/widgets/general_app_bar.dart:
  - renamed to custom_app_bar.dart.
 * lib/locator.dart:
   - registered the AppScale class as a LazySingleton.

## 2023/06/27 - colors:

Changes:
In this commit I just adjusted the colors of the application. In summary the changes were:
 * integration of application colors with theme colors;
 * AppColors now takes colors directly from the theme with the functions getColorsGradient and getGrayGradient, to generate gradients with the color palette or in grayscale.

## 2023/06/26:

Changes:
In this commit, I added edit category editing capability to the code with the following changes:
 * lib/common/widgets/add_cancel_buttons.dart:
   - added addIcon attribute to replace add icon with AddCancelButtons class.
 * lib/common/widgets/basic_text_form_field.dart:
   - added suffixIcon to add suffix icon in TextFormField widget.
 * lib/features/category/category_page.dart:
   - now the TextEditingController _categoryController is controlled by CategoryPage class;
   - CategoryFloatingActinoButton has been removed and replaced by a direct call to the FloatingActionButton widget.
 * lib/features/category/widgets/category_floating_action_button.dart:
   - code removed.
 * lib/features/category/widgets/dismissible_category.dart:
   - DismissibleCategory has its own TextEditingController categoryController, to control edit and delete actions.
 * lib/features/category/widgets/statefull_category_dialog.dart:
   - extracted statefullCategoryDialog from CategoryFloatingActionButton class.
 * lib/features/home_page/widgets/transaction_list_tile.dart:
   - changed date format to use DateFormat.yMMMEd().add_Hm() format;
   - add a helpDialog function, activated by a long press on a transaction.
 * lib/features/transaction/transaction_page.dart:
   - added a switch to diaplay Icons.thumb_up/Icons.thumb_down icons to indicate income/expanse release.
   - 
