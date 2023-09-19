import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/current_models/current_user.dart';
import '../../../locator.dart';
import '../../../common/constants/routes/app_route.dart';
import '../../../services/authentication/auth_service.dart';
import '../../../services/database/database_helper.dart';
import '../../database_recover/database_recover.dart';

class HomePagePopupMenuButtons extends StatelessWidget {
  const HomePagePopupMenuButtons({super.key});

  void helpDialog(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          locale.transactionListTileHelp,
          textAlign: TextAlign.center,
        ),
        alignment: Alignment.center,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.transactionListTileSwipeControls,
              style: AppTextStyles.textStyleBold16,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.swipe_right),
                const SizedBox(width: 8),
                Text(locale.transactionListTileEditTransaction),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.swipe_left),
                const SizedBox(width: 8),
                Text(locale.transactionListTileDeleteTransaction),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              locale.transactionListTileButtons,
              style: AppTextStyles.textStyleBold16,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.add),
                const SizedBox(width: 8),
                Text(locale.transactionListTileAddNewTransaction),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.more_horiz),
                const SizedBox(width: 8),
                Text(locale.transactionListTileMoreOptions),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Row(
      children: [
        PopupMenuButton(
          onSelected: (value) async {
            if (value == 'settings') {
              await Navigator.pushNamed(context, AppRoute.settings.name);
            } else if (value == 'helpHomePage') {
              helpDialog(context);
            } else if (value == 'logout') {
              await locator.get<AuthService>().signOut();
              var user = locator.get<CurrentUser>();
              user.userLogged = false;
              await locator.get<DatabaseHelper>().updateUser(user.toMap());
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.onboard.name,
                  (route) => false,
                );
              }
            } else if (value == 'backup') {
              showDialog(
                context: context,
                builder: (context) => const DatabaseRecover(
                  dialogState: DialogStates.createRestore,
                ),
              );
            }
          },
          child: Icon(
            Icons.more_horiz,
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
              value: 'helpHomePage',
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: primary,
                  ),
                  const SizedBox(width: 8),
                  Text(locale.cardPopupMenuTransactionsHelp),
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
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
