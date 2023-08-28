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
              LargeBoldText(locale.splashPageMsgPart0),
              LargeBoldText(locale.splashPageMsgPart1),
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
