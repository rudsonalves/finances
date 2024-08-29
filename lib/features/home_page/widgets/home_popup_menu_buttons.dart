// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

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
