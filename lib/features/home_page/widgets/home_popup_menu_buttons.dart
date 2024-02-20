import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/current_models/current_user.dart';
import '../../../locator.dart';
import '../../../common/constants/routes/app_route.dart';
import '../../../repositories/user/abstract_user_repository.dart';
import '../../../services/authentication/auth_service.dart';
import '../../database_recover/database_recover.dart';

class HomePagePopupMenuButtons extends StatelessWidget {
  const HomePagePopupMenuButtons({super.key});

  void _onSelected(BuildContext context, String? value) async {
    if (value == 'settings') {
      await Navigator.pushNamed(context, AppRoute.settings.name);
    } else if (value == 'logout') {
      await locator<AuthService>().signOut();
      var user = locator<CurrentUser>();
      user.userLogged = false;
      await locator<AbstractUserRepository>().updateUser(user);
      SystemNavigator.pop();
    } else if (value == 'backup') {
      showDialog(
        context: context,
        builder: (context) => const DatabaseRecover(
          dialogState: DialogStates.createRestore,
        ),
      );
    } else if (value == 'about') {
      Navigator.pushNamed(context, AppRoute.aboutPage.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return PopupMenuButton<String>(
      onSelected: (value) => _onSelected(context, value),
      icon: Icon(
        Icons.more_vert,
        color: colorScheme.onPrimary,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings,
                color: primary,
              ),
              const SizedBox(width: 8),
              Text(
                locale.cardPopupMenuSettings,
              )
            ],
          ),
        ),
        PopupMenuItem(
          value: 'backup',
          child: Row(
            children: [
              Icon(
                Icons.upload_file,
                color: primary,
              ),
              const SizedBox(width: 8),
              Text(
                locale.cardPopupMenuBackup,
              )
            ],
          ),
        ),
        PopupMenuItem(
          value: 'about',
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: primary,
              ),
              const SizedBox(width: 8),
              const Text('About'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: primary,
              ),
              const SizedBox(width: 8),
              Text(locale.cardPopupMenuLogout),
            ],
          ),
        ),
      ],
    );
  }
}
