import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/current_models/current_account.dart';
import '../../../locator.dart';
import '../../../common/models/icons_model.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/current_models/current_user.dart';
import '../../../common/constants/themes/app_icons.dart';
import '../../../common/validate/account_validator.dart';
import '../../../common/widgets/add_cancel_buttons.dart';
import '../../../common/widgets/basic_text_form_field.dart';
import '../../../features/category/widgets/select_icon_row.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../repositories/account/account_repository.dart';

Future<void>? statefullAddAccountDialog(
  BuildContext context, {
  AccountDbModel? editAccount,
}) async {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  final Color primary = colorScheme.primary;
  bool addAccount = false;

  if (editAccount == null) {
    addAccount = true;
    editAccount = AccountDbModel(
      accountName: '',
      accountUserId: locator.get<CurrentUser>().userId!,
      accountDescription: '',
      accountIcon: IconModel(
        iconName: 'wallet',
        iconFontFamily: IconsFontFamily.MaterialIcons,
      ),
    );
  }

  TextEditingController nameController = TextEditingController(
    text: editAccount.accountName,
  );
  TextEditingController descriptionController = TextEditingController(
    text: editAccount.accountDescription,
  );

  final AppLocalizations locale = AppLocalizations.of(context)!;
  GlobalKey<FormState> formKey = GlobalKey();
  final AccountValidator validator = AccountValidator(locale);

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SimpleDialog(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          addAccount
              ? locale.statefullAccountDialogNewAccount
              : locale.statefullAccountDialogEditAccount,
          style: AppTextStyles.textStyleSemiBold18.copyWith(
            color: primary,
          ),
        ),
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                BasicTextFormField(
                  validator: validator.nameValidator,
                  labelText: locale.statefullAccountDialogName,
                  controller: nameController,
                ),
                BasicTextFormField(
                  validator: validator.descriptionValidator,
                  labelText: locale.statefullAccountDialogDescrip,
                  controller: descriptionController,
                ),
                SelectIconRow(
                  iconModel: editAccount!.accountIcon,
                  iconCallback: (IconModel newIcon) {
                    setState(() {
                      editAccount!.accountIcon.iconName = newIcon.iconName;
                      editAccount.accountIcon.iconFontFamily =
                          newIcon.iconFontFamily;
                    });
                  },
                ),
              ],
            ),
          ),
          AddCancelButtons(
            addLabel: addAccount
                ? locale.statefullAccountDialogAdd
                : locale.statefullAccountDialogUpdate,
            addIcon: addAccount ? Icons.add : Icons.update,
            addCallback: () async {
              if (formKey.currentState != null &&
                  formKey.currentState!.validate()) {
                editAccount!.accountName = nameController.text;
                editAccount.accountDescription = descriptionController.text;
                if (!addAccount) {
                  await editAccount.updateAccount();

                  final currentAccount = locator.get<CurrentAccount>();
                  if (editAccount.accountId == currentAccount.accountId) {
                    currentAccount.setFromAccountDbModel(editAccount);
                  }
                } else {
                  await locator
                      .get<AccountRepository>()
                      .addAccount(editAccount);
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            cancelCallback: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
