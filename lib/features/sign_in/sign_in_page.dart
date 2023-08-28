import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/colors/custom_color.g.dart';
import '../../locator.dart';
import '../database_recover/database_recover.dart';
import './sign_in_state.dart';
import './sign_in_controller.dart';
import '../../common/widgets/primary_button.dart';
import '../../common/widgets/large_bold_text.dart';
import '../../common/validate/sign_validator.dart';
import '../../common/widgets/custom_text_button.dart';
import '../../common/constants/routes/app_route.dart';
import '../../common/models/user_model.dart';
import '../../common/widgets/basic_text_form_field.dart';
import '../../common/widgets/password_text_form_field.dart';
import '../../common/widgets/custom_modal_bottom_sheet.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _pwdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _controller = locator.get<SignInController>();
  bool showMessage = false;

  @override
  void initState() {
    super.initState();
    //

    _controller.addListener(
      () {
        // SignIn State Loading
        if (_controller.state is SignInStateLoading) {
          showDialog(
            context: context,
            builder: (context) => const Center(
              child: CustomCircularProgressIndicator(),
            ),
          );
        }

        // SignIn State Success
        if (_controller.state is SignInStateSuccess) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(
            context,
            AppRoute.home.name,
          );
        }

        // SignIn State Error
        if (_controller.state is SignInStateError) {
          final locale = AppLocalizations.of(context)!;
          final SignInStateError error = _controller.state as SignInStateError;

          Navigator.pop(context);
          if (error.message
              .contains(RegExp(r".*Local data don't have this user.$"))) {
            customModelBottomSheet(
              context,
              content: error.message,
              buttonText: AppLocalizations.of(context)!.signInPageTryAgain,
              secondMessage: locale.signInPageWantImport,
              secondWidget: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await showDialog(
                    context: context,
                    builder: (context) => const DatabaseRecover(
                      dialogState: DialogStates.restore,
                    ),
                  );
                },
                child: Text(locale.signInPageRescueData),
              ),
            );
          } else {
            customModelBottomSheet(
              context,
              content: error.message,
              buttonText: AppLocalizations.of(context)!.signInPageTryAgain,
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _pwdController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final validate = SignValidator(locale);

    return Scaffold(
      body: ListView(
        children: [
          LargeBoldText(locale.signInPageMsgPart0),
          LargeBoldText(locale.signInPageMsgPart1),
          Image.asset('assets/images/signin.png'),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  BasicTextFormField(
                    labelText: locale.signInPageEmail,
                    hintText: 'sample@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: validate.emailValidator,
                    onchanged: (value) {
                      if (validate.emailValidator(value) == null) {
                        showMessage = true;
                      } else {
                        showMessage = false;
                      }
                      setState(() {});
                    },
                  ),
                  if (showMessage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          locale.signInPageForgotPassword,
                          textAlign: TextAlign.end,
                        ),
                        TextButton(
                          onPressed: () async {
                            bool sucess = await _controller
                                .recoverPassword(_emailController.text);
                            if (sucess) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(locale.signInPageResetPassword),
                                    icon: Icon(
                                      Icons.lock_reset,
                                      color: customColors.sourceLightyellow,
                                      size: 64,
                                    ),
                                    content: Text(
                                      locale.signInPageResetPasswordMessage(
                                        _emailController.text,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(locale.genericClose),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(locale.signInPageResetPassword),
                                    icon: Icon(
                                      Icons.error,
                                      color: customColors.sourceMinusred,
                                      size: 64,
                                    ),
                                    content: Text(
                                      locale.signInPageProblemRequest,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(locale.genericClose),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(locale.signInPageRecover),
                        ),
                      ],
                    ),
                  PasswordTextFormField(
                    labelText: locale.signInPagePassword,
                    hintText: '********',
                    controller: _pwdController,
                    textInputAction: TextInputAction.done,
                    validator: validate.passwordValidator,
                  ),
                  PrimaryButton(
                    label: locale.signInPageSignIn,
                    onTap: () async {
                      final valit = _formKey.currentState != null &&
                          _formKey.currentState!.validate();

                      if (valit) {
                        UserModel user = UserModel(
                          email: _emailController.text,
                          password: _pwdController.text,
                        );
                        await _controller.doSignIn(user);
                      }
                    },
                  ),
                  CustomTextButton(
                    labelMessage: locale.signInPageDontHaveAccount,
                    labelButton: locale.signInPageSignUp,
                    onPressed: () => Navigator.popAndPushNamed(
                      context,
                      AppRoute.signUp.name,
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
