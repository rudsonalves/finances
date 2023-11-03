import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/models/user_model.dart';
import '../../common/widgets/primary_button.dart';
import '../../common/widgets/secondary_button.dart';
import '../../features/sign_up/sign_up_state.dart';
import '../../common/validate/sign_validator.dart';
import '../../common/widgets/large_bold_text.dart';
import '../../common/constants/routes/app_route.dart';
import '../../common/widgets/custom_text_button.dart';
import '../../features/sign_up/sign_up_controller.dart';
import '../../common/widgets/basic_text_form_field.dart';
import '../../common/widgets/password_text_form_field.dart';
import '../../common/widgets/custom_modal_bottom_sheet.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import '../../locator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();
  final SignUpController _controller = locator.get<SignUpController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controller.addListener(
      () {
        // SignUp State Loading
        if (_controller.state is SignUpStateLoading) {
          showDialog(
            context: context,
            builder: (context) => const Center(
              child: CustomCircularProgressIndicator(),
            ),
          );
        }

        // SignUp State Success
        if (_controller.state is SignUpStateSuccess) {
          Navigator.pop(context);
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoute.home.name, (route) => false);
        }

        // SignUp State Error
        if (_controller.state is SignUpStateError) {
          final SignUpStateError error = _controller.state as SignUpStateError;
          Navigator.pop(context);
          customModelBottomSheet(
            context,
            content: error.message,
            buttonText: SecondaryButton(
              onTap: () => Navigator.pop(context),
              label: AppLocalizations.of(context)!.signInPageTryAgain,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pwdController.dispose();
    _confirmPwdController.dispose();
    // _controller.dispose();
    super.dispose();
  }

  Future<void> signInButton() async {
    final locale = AppLocalizations.of(context)!;

    final valit =
        _formKey.currentState != null && _formKey.currentState!.validate();

    if (valit) {
      UserModel user = UserModel(
        name: _nameController.text,
        email: _emailController.text,
        password: _pwdController.text,
      );
      await _controller.doSignUp(user, locale);
    }
  }

  void signUpButton() => Navigator.popAndPushNamed(
        context,
        AppRoute.signIn.name,
      );

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final validate = SignValidator(locale);

    return Scaffold(
      body: ListView(
        children: [
          LargeBoldText(locale.signUpPageMsg0),
          Image.asset(
            'assets/images/signup.png',
            height: 180,
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  BasicTextFormField(
                    labelText: locale.signUpPageYourName,
                    hintText: 'Your Name',
                    capitalization: TextCapitalization.words,
                    controller: _nameController,
                    validator: validate.nameValidator,
                  ),
                  BasicTextFormField(
                    labelText: locale.signUpPageEmail,
                    hintText: 'your.email@server.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: validate.emailValidator,
                  ),
                  PasswordTextFormField(
                    labelText: locale.signUpPageChoosePassword,
                    hintText: '********',
                    controller: _pwdController,
                    validator: validate.passwordValidator,
                  ),
                  PasswordTextFormField(
                    labelText: locale.signUpPageConfirmPassword,
                    hintText: '********',
                    controller: _confirmPwdController,
                    textInputAction: TextInputAction.done,
                    validator: (value) => validate.pwdConfirmValidator(
                        value, _pwdController.text),
                  ),
                  PrimaryButton(
                    label: locale.signUpPageSignUp,
                    onTap: signInButton,
                  ),
                  CustomTextButton(
                    labelMessage: locale.signUpPageAlreadyHaveAccount,
                    labelButton: locale.signUpPageSignIn,
                    onPressed: signUpButton,
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
