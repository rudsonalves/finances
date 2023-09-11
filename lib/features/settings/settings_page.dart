import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/widgets/custom_circular_progress_indicator.dart';
import '../../locator.dart';
import '../../common/models/language_model.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/current_models/current_user.dart';
import '../../common/current_models/current_theme.dart';
import '../../common/current_models/current_language.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../database_recover/database_recover.dart';
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
  final controller = SettingsPageController();

  @override
  void initState() {
    super.initState();
    controller.init();
  }

  Widget languageDropdown() {
    return DropdownButton<String>(
      elevation: 5,
      value: currentLanguage.localeCode,
      onChanged: (codeLang) {
        if (codeLang != null) {
          currentLanguage.setFromLocaleCode(codeLang);
          currentUser.setUserLanguage(codeLang);
        }
      },
      items: supportedLanguages.keys
          .map(
            (code) => DropdownMenuItem(
              value: code,
              child: Text(
                '${supportedLanguages[code]!['flag']!}'
                '  ${supportedLanguages[code]!['name']!}',
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
                      Text(
                        currentUser.userName!,
                        style: AppTextStyles.textStyleSemiBold18,
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
                              Center(
                                child: Text(
                                  'App version: $version',
                                  style:
                                      AppTextStyles.textStyleMedium16.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const DatabaseRecover(
                                        dialogState: DialogStates.createRestore,
                                      ),
                                    );
                                  },
                                  // icon: const Icon(Icons.backup_table_sharp),
                                  child: Text(
                                      locale.settingsPageCreateRestoreBackup),
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
