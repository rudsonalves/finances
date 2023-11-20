import 'package:flutter/material.dart';

import '../../common/models/app_locale.dart';
import '../../locator.dart';
import '../../common/extensions/sizes.dart';
import '../../common/extensions/app_scale.dart';
import '../../features/splash/splash_state.dart';
import '../../features/splash/splash_controller.dart';
import '../../common/constants/routes/app_route.dart';
import '../../common/constants/themes/app_colors.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _splashController = locator<SplashController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => Sizes.init(context));
    _splashController.isUserLogged();
    _splashController.addListener(() {
      locator<AppScale>().init(context);
      if (_splashController.state is SplashStateSuccess) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoute.home.name, (route) => false);
      } else {
        Navigator.pushReplacementNamed(context, AppRoute.onboard.name);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locator<AppLocale>().initializeLocale(context);
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = locator<AppLocale>();
    if (!appLocale.started) {
      appLocale.initializeLocale(context);
    }
    final locale = appLocale.locale;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.getColorsGradient(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              locale.appName,
              textAlign: TextAlign.center,
              style: AppTextStyles.textStyleBold38.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/icons/finances_icon2.png',
                width: 100,
                height: 100,
              ),
            ),
            const CustomCircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
