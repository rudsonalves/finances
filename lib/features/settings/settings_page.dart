import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:restart_app/restart_app.dart';

import '../../common/constants/app_info.dart';
import '../../common/constants/laguage_constants.dart';
import '../../common/constants/routes/app_route.dart';
import '../../common/constants/themes/app_button_styles.dart';
import '../../common/models/user_name_notifier.dart';
import '../../common/widgets/basic_text_form_field.dart';
import '../../common/widgets/markdown_rich_text.dart';
import '../../common/widgets/simple_spin_box_field.dart';
import '../../common/widgets/widget_alert_dialog.dart';
import '../../locator.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/current_models/current_user.dart';
import '../../common/current_models/current_theme.dart';
import '../../common/current_models/current_language.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../repositories/database/abstract_database_repository.dart';
import '../../services/authentication/auth_service.dart';
import '../home_page/home_page_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _currentUser = locator<CurrentUser>();
  final _currentTheme = locator<CurrentTheme>();
  final _currentLanguage = locator<CurrentLanguage>();
  final _currentUserName = locator<UserNameNotifier>();
  final _userNameController = TextEditingController();
  final _userMaxTransactions = ValueNotifier<int>(35);
  final _maxTransValueController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _userNameController.text = _currentUserName.userName;
    _userMaxTransactions.value = _currentUser.userMaxTransactions;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userMaxTransactions.dispose();
    _maxTransValueController.dispose();
    super.dispose();
  }

  Widget languageDropdown() {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButton<String>(
      elevation: 5,
      dropdownColor: colorScheme.onInverseSurface,
      value: _currentLanguage.localeCode,
      onChanged: (codeLang) {
        if (codeLang != null) {
          _currentLanguage.setFromLocaleCode(codeLang);
          _currentUser.setUserLanguage(codeLang);
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(locale.settingsPageRestart),
            content: Text(locale.settingsPageLangReboot),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await Restart.restartApp(webOrigin: AppRoute.onboard.name);
                },
                child: Text(
                  locale.genericYes,
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  locale.genericClose,
                ),
              ),
            ],
          ),
        );
      },
      items: languageAttributes.keys
          .map(
            (code) => DropdownMenuItem(
              value: code,
              child: Text(
                '${languageAttributes[code]!.flag}'
                '  ${languageAttributes[code]!.language}',
                style: AppTextStyles.textStyleMedium16,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget themeModeDropdown() {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButton<ThemeMode>(
      elevation: 5,
      dropdownColor: colorScheme.onInverseSurface,
      value: _currentTheme.themeMode$.value,
      onChanged: (themeMode) {
        if (themeMode != null) {
          _currentTheme.setThemeMode(themeMode);
          _currentUser.setUserTheme(themeMode.name);
        }
      },
      items: const [
        DropdownMenuItem(
          value: ThemeMode.system,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.android),
              SizedBox(width: 8),
              Text('system'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(Icons.light_mode),
              SizedBox(width: 8),
              Text('light'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(Icons.dark_mode),
              SizedBox(width: 8),
              Text('dark'),
            ],
          ),
        ),
      ],
    );
  }

  AlertDialog editNameDialog(AppLocalizations locale) {
    final buttonStyle = AppButtonStyles.primaryButtonColor(context);

    return AlertDialog(
      title: Text(locale.settingsPageDialogTitle),
      content: BasicTextFormField(
        controller: _userNameController,
        labelText: locale.signUpPageYourName,
      ),
      actions: [
        ElevatedButton(
          style: buttonStyle,
          onPressed: () async {
            final navigator = Navigator.of(context);

            if (_userNameController.text.isNotEmpty &&
                _currentUserName.userName != _userNameController.text) {
              await _currentUserName.changeName(_userNameController.text);
            }
            navigator.pop();
          },
          child: Text(locale.transPageButtonUpdate),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: buttonStyle,
          child: Text(locale.genericClose),
        ),
      ],
    );
  }

  void editMaxTransactions() async {
    final primary = Theme.of(context).colorScheme.primary;
    final locale = AppLocalizations.of(context)!;

    _maxTransValueController.text = _userMaxTransactions.value.toString();

    int? value = await showDialog(
      context: context,
      builder: (context) => WidgetAlertDialog(
        title: locale.maxTrasctionsTitle,
        content: [
          MarkdownRichText.richText(
            locale.maxTrasctionsText,
            color: primary,
          ),
          SimpleSpinBoxField(
            value: _currentUser.userMaxTransactions,
            labelText: 'labelText',
            controller: _maxTransValueController,
            minValue: 25,
            maxValue: 100,
          ),
        ],
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(
              int.parse(_maxTransValueController.text),
            ),
            style: AppButtonStyles.primaryButtonColor(context),
            child: Text(locale.genericSelect),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(null),
            style: AppButtonStyles.primaryButtonColor(context),
            child: Text(locale.genericClose),
          ),
        ],
      ),
    );

    if (value != null) {
      _userMaxTransactions.value = value;
    }
  }

  Future<void> updateMaxTransactions(int value) async {
    if (_currentUser.userMaxTransactions != value) {
      _currentUser.userMaxTransactions = value;
      await _currentUser.updateUserMaxTransactions();
      locator<HomePageController>().maxTransactions = value;
    }
  }

  void _resetDialog() async {
    final locale = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;

    await showDialog(
      context: context,
      builder: (context) => WidgetAlertDialog(
        title: locale.resetDialogTitle,
        content: [
          Text(
            style: TextStyle(color: primary),
            locale.resetDialogMsg0,
          ),
          const SizedBox(height: 12),
          MarkdownRichText.richText(
            color: primary,
            locale.resetDialogMsg1,
          ),
          const SizedBox(height: 4),
          Center(
            child: ElevatedButton(
              style: AppButtonStyles.primaryButtonColor(context),
              onPressed: _resetData,
              child: Text(
                locale.resetDialogData,
              ),
            ),
          ),
          const SizedBox(height: 8),
          MarkdownRichText.richText(
            color: primary,
            locale.resetDialogAccountMsg,
          ),
          const SizedBox(height: 4),
          Center(
            child: ElevatedButton(
              style: AppButtonStyles.primaryButtonColor(context),
              onPressed: _resetAccount,
              child: Text(
                locale.resetDialogReset,
              ),
            ),
          ),
        ],
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppButtonStyles.primaryButtonColor(context),
            child: Text(locale.genericCancel),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAccount() async {
    await locator<AbstractDatabaseRepository>().deleteDatabase();
    await locator<AuthService>().removeAccount();
    await Restart.restartApp(webOrigin: AppRoute.onboard.name);
  }

  Future<void> _resetData() async {
    await locator<AbstractDatabaseRepository>().deleteDatabase();
    await Restart.restartApp(webOrigin: AppRoute.onboard.name);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        title: Text(
          locale.settingsPageTitle,
          style: AppTextStyles.textStyleSemiBold18,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AppTopBorder(),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          child: Image.asset(
                            'assets/images/finances_icon.png',
                            width: 70,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => editNameDialog(locale),
                            );
                          },
                          child: AnimatedBuilder(
                              animation: _currentUserName,
                              builder: (context, _) {
                                return Text(
                                  _userNameController.text,
                                  style: AppTextStyles.textStyleSemiBold18,
                                );
                              }),
                        ),
                        Text(
                          _currentUser.userEmail!,
                          style:
                              AppTextStyles.textStyle18.apply(color: primary),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          locale.settingsPageAppSettings,
                          style: AppTextStyles.textStyleSemiBold18.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Theme
                        ValueListenableBuilder(
                          valueListenable: _currentTheme.themeMode$,
                          builder: (context, themeMode, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  locale.settingsPageAppTheme,
                                  style:
                                      AppTextStyles.textStyleMedium16.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                themeModeDropdown(),
                              ],
                            );
                          },
                        ),
                        // Language
                        ValueListenableBuilder(
                          valueListenable: _currentLanguage.locale$,
                          builder: (context, value, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  locale.settingsPageLanguage,
                                  style:
                                      AppTextStyles.textStyleMedium16.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                languageDropdown(),
                              ],
                            );
                          },
                        ),
                        // Max Transactions per Page
                        Row(
                          children: [
                            Text(
                              locale.resetDialogTransactions,
                              style: AppTextStyles.textStyleMedium16.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 32),
                            ElevatedButton(
                              onPressed: editMaxTransactions,
                              child: SizedBox(
                                width: 60,
                                child: ListenableBuilder(
                                  listenable: _userMaxTransactions,
                                  builder: (context, _) {
                                    updateMaxTransactions(
                                        _userMaxTransactions.value);
                                    return Text(
                                      _userMaxTransactions.value.toString(),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Text(
                              locale.resetDialogResetButton,
                              style: AppTextStyles.textStyleMedium16.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 32),
                            IconButton.filledTonal(
                              onPressed: _resetDialog,
                              icon: const Icon(
                                Icons.restart_alt_rounded,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // App Version
                        Text(
                          '${locale.settingsPageAppVersion}: ${AppInfo.version}',
                          style: AppTextStyles.textStyleMedium16.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
