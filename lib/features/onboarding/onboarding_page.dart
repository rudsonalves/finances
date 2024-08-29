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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/widgets/primary_button.dart';
import '../../common/widgets/large_bold_text.dart';
import '../../common/widgets/custom_text_button.dart';
import '../../common/constants/routes/app_route.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/main_image500.png',
              height: 500,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LargeBoldText(locale.splashPageMsg0),
              PrimaryButton(
                label: locale.splashPageGetStarted,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoute.signUp.name,
                ),
              ),
              CustomTextButton(
                labelMessage: locale.splashPageHaveAccount,
                labelButton: locale.splashPageLogIn,
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoute.signIn.name,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
