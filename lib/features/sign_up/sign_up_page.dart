import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/models/user_model.dart';
import '../../common/widgets/primary_button.dart';
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
        if (_controller.state is SignUpStateLoading) {
          showDialog(
            context: context,
            builder: (context) => const Center(
              child: CustomCircularProgressIndicator(),
            ),
          );
        }

        if (_controller.state is SignUpStateSuccess) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, AppRoute.home.name);
        }

        if (_controller.state is SignUpStateError) {
          final SignUpStateError error = _controller.state as SignUpStateError;
          Navigator.pop(context);
          customModelBottomSheet(
            context,
            content: error.message,
            buttonText: AppLocalizations.of(context)!.signUpPageTryAgain,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _pwdController.dispose();
    _confirmPwdController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final validate = SignValidator(locale);

    return Scaffold(
      body: ListView(
        children: [
          LargeBoldText(locale.signUpPageMsgPart0),
          LargeBoldText(locale.signUpPageMsgPart1),
          Image.asset('assets/images/signup.png'),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  BasicTextFormField(
                    labelText: locale.signUpPageYourName,
                    hintText: 'Albert Einstein',
                    capitalization: TextCapitalization.words,
                    controller: _nameController,
                    validator: validate.nameValidator,
                  ),
                  BasicTextFormField(
                    labelText: locale.signUpPageEmail,
                    hintText: 'albert@email.com',
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
                    onTap: () async {
                      final valit = _formKey.currentState != null &&
                          _formKey.currentState!.validate();

                      if (valit) {
                        UserModel user = UserModel(
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _pwdController.text,
                        );
                        await _controller.doSignUp(user);
                      }
                      // else {
                      //   log('SignUpPage: Some field is not validated!');
                      // }
                    },
                  ),
                  CustomTextButton(
                    labelMessage: locale.signUpPageAlreadyHaveAccount,
                    labelButton: locale.signUpPageSignIn,
                    onPressed: () => Navigator.popAndPushNamed(
                      context,
                      AppRoute.signIn.name,
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
