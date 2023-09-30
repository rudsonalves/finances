import 'package:finances/common/models/user_name_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:restart_app/restart_app.dart';

import '../../common/constants/laguage_constants.dart';
import '../../common/constants/routes/app_route.dart';
import '../../common/constants/themes/app_button_styles.dart';
import '../../common/widgets/basic_text_form_field.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import '../../locator.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/current_models/current_user.dart';
import '../../common/current_models/current_theme.dart';
import '../../common/current_models/current_language.dart';
import '../../common/constants/themes/app_text_styles.dart';
import 'settings_page_controller.dart';
import 'settings_page_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final currentUser = locator.get<CurrentUser>();
  final currentTheme = locator.get<CurrentTheme>();
  final currentLanguage = locator.get<CurrentLanguage>();
  final currentUserName = locator.get<UserNameNotifier>();
  final controller = SettingsPageController();
  final userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.init();
  }

  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
    controller.dispose();
  }

  Widget languageDropdown() {
    final locale = AppLocalizations.of(context)!;

    return DropdownButton<String>(
      elevation: 5,
      value: currentLanguage.localeCode,
      onChanged: (codeLang) {
        if (codeLang != null) {
          currentLanguage.setFromLocaleCode(codeLang);
          currentUser.setUserLanguage(codeLang);
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
    return DropdownButton<ThemeMode>(
      elevation: 5,
      value: currentTheme.themeMode$.value,
      onChanged: (themeMode) {
        if (themeMode != null) {
          currentTheme.setThemeMode(themeMode);
          currentUser.setUserTheme(themeMode.name);
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
        controller: userNameController,
        labelText: locale.signUpPageYourName,
      ),
      actions: [
        ElevatedButton(
          style: buttonStyle,
          onPressed: () async {
            final navigator = Navigator.of(context);

            if (userNameController.text.isNotEmpty &&
                currentUserName.userName != userNameController.text) {
              await currentUserName.changeName(userNameController.text);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final locale = AppLocalizations.of(context)!;

    userNameController.text = currentUserName.userName;

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(
                          Icons.person,
                          size: 80,
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
                            animation: currentUserName,
                            builder: (context, _) {
                              return Text(
                                userNameController.text,
                                style: AppTextStyles.textStyleSemiBold18,
                              );
                            }),
                      ),
                      Text(
                        currentUser.userEmail!,
                        style: AppTextStyles.textStyle18.apply(color: primary),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      // SettingsPage State Loading
                      if (controller.state is SettingsPageStateLoading) {
                        return const CustomCircularProgressIndicator();
                      }

                      // SettingsPage State Success
                      if (controller.state is SettingsPageStateSuccess) {
                        String version = controller.packageInfo.version;

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale.settingsPageAppSettings,
                                style:
                                    AppTextStyles.textStyleSemiBold18.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ValueListenableBuilder(
                                valueListenable: currentTheme.themeMode$,
                                builder: (context, themeMode, _) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        locale.settingsPageAppTheme,
                                        style: AppTextStyles.textStyleMedium16
                                            .copyWith(
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      themeModeDropdown(),
                                    ],
                                  );
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: currentLanguage.locale$,
                                builder: (context, value, _) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        locale.settingsPageLanguage,
                                        style: AppTextStyles.textStyleMedium16
                                            .copyWith(
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      languageDropdown(),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 32),
                              Text(
                                '${locale.settingsPageAppVersion}: $version',
                                style: AppTextStyles.textStyleMedium16.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // SettingsPage State Error
                      return Expanded(
                        child: Center(
                          child: Text(locale.settingsPageSettingsError),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
