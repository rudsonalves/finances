import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_icons.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/current_models/current_account.dart';
import '../../../common/current_models/current_user.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/models/icons_model.dart';
import '../../../common/validate/account_validator.dart';
import '../../../common/widgets/add_cancel_buttons.dart';
import '../../../common/widgets/basic_text_form_field.dart';
import '../../../locator.dart';
import '../../../repositories/account/abstract_account_repository.dart';
import '../../../common/widgets/new_icon_selection.dart';
import '../../home_page/home_page_controller.dart';

class AddAccountPage extends StatefulWidget {
  final AccountDbModel? editAccount;
  final Function? callBack;

  const AddAccountPage({
    super.key,
    this.editAccount,
    this.callBack,
  });

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountDescriptionController = TextEditingController();
  final _homePageController = locator<HomePageController>();

  bool _addNewAccount = true;
  int? _accountId;

  final ValueNotifier<IconModel> _accountIcon = ValueNotifier(
    IconModel(
      iconName: 'wallet',
      iconFontFamily: IconsFontFamily.MaterialIcons,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.editAccount != null) {
      _addNewAccount = false;
      _accountNameController.text = widget.editAccount!.accountName;
      _accountDescriptionController.text =
          widget.editAccount!.accountDescription ?? '';
      _accountId = widget.editAccount!.accountId;
      _accountIcon.value = widget.editAccount!.accountIcon;
    } else {
      _accountNameController.text = '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _accountNameController.dispose();
    _accountDescriptionController.dispose();
    _accountIcon.dispose();
    if (widget.callBack != null) widget.callBack!();
  }

  Future<void> _addCallback() async {
    AccountDbModel newAccount = AccountDbModel(
      accountId: _accountId,
      accountIcon: _accountIcon.value,
      accountName: _accountNameController.text,
      accountDescription: _accountDescriptionController.text,
      accountUserId: locator<CurrentUser>().userId!,
    );

    if (_accountId != null) {
      // Update Account
      await newAccount.updateAccount();
      _homePageController.setRedraw();
      final currentAccount = locator<CurrentAccount>();
      if (_accountId == currentAccount.accountId) {
        currentAccount.setFromAccountDbModel(newAccount);
      }
    } else {
      // New Account
      await locator<AbstractAccountRepository>().addAccount(newAccount);
      _homePageController.setRedraw();
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _cancelCallback() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final AccountValidator validator = AccountValidator(locale);

    return Dialog(
      elevation: 2,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            children: [
              // Title
              Center(
                child: Text(
                  _addNewAccount
                      ? locale.statefullAccountDialogNewAccount
                      : locale.statefullAccountDialogEditAccount,
                  style: AppTextStyles.textStyleSemiBold20.copyWith(
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      // Account Name
                      BasicTextFormField(
                        capitalization: TextCapitalization.words,
                        controller: _accountNameController,
                        validator: validator.nameValidator,
                        labelText: locale.statefullAccountDialogName,
                      ),
                      // Account Description
                      const SizedBox(height: 16),
                      BasicTextFormField(
                        capitalization: TextCapitalization.sentences,
                        validator: validator.descriptionValidator,
                        labelText: locale.statefullAccountDialogDescrip,
                        controller: _accountDescriptionController,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Icon Selection
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${locale.iconSelectionDialogIconSelection}:',
                    style: AppTextStyles.textStyleSemiBold16.copyWith(
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Card(
                      elevation: 5,
                      shape: const CircleBorder(),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: ListenableBuilder(
                            listenable: _accountIcon,
                            builder: (context, _) {
                              return _accountIcon.value.iconWidget(size: 42);
                            }),
                      ),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final IconModel? iconResult = await showDialog(
                        context: context,
                        builder: (contex) => Dialog(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 800,
                            ),
                            child: NewIconSelection(
                              icon: _accountIcon.value,
                            ),
                          ),
                        ),
                      );
                      if (iconResult != null) {
                        _accountIcon.value = iconResult;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Actions Buttons
              AddCancelButtons(
                addLabel: _addNewAccount
                    ? locale.statefullAccountDialogAdd
                    : locale.statefullAccountDialogUpdate,
                addIcon: _addNewAccount ? Icons.add : Icons.update,
                addCallback: () async {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    await _addCallback();
                  }
                },
                cancelCallback: _cancelCallback,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
