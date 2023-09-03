import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/utils/validator.dart';
import 'sign_up_view_model.dart';
import '../../core/decorations/text_field_decoration.dart';
import '../../core/values/colors.dart';

class SignUpView extends StatelessWidget {
  SignUpView({super.key});

  final TextEditingController emailTec = TextEditingController();
  final TextEditingController passTec = TextEditingController();
  final TextEditingController confPassTec = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(0, 0),
                blurRadius: 1.6,
                spreadRadius: 0.8,
              )
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo/logo-n.png',
                  width: 84,
                ),
                TextFormField(
                  controller: emailTec,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => validatorField(value),
                  decoration: TextFieldDecoration.filled(hint: 'Email'),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: passTec,
                  obscureText: viewModel.isObscurePass,
                  validator: (value) => validatorField(value),
                  decoration: TextFieldDecoration.filled(
                    hint: 'Password',
                    suffix: IconButton(
                      onPressed: () => viewModel.toogleObscure(true),
                      icon: Icon(
                        Icons.remove_red_eye_outlined,
                        color: viewModel.isObscurePass
                            ? Colors.grey.shade500
                            : primaryLightColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: confPassTec,
                  obscureText: viewModel.isObscureConfPass,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Form is required';
                    }

                    if (value != passTec.text) {
                      return 'Confirm pass not same with password';
                    }

                    return null;
                  },
                  decoration: TextFieldDecoration.filled(
                    hint: 'Confirm Password',
                    suffix: IconButton(
                      onPressed: () => viewModel.toogleObscure(false),
                      icon: Icon(
                        Icons.remove_red_eye_outlined,
                        color: viewModel.isObscureConfPass
                            ? Colors.grey.shade500
                            : primaryLightColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Builder(
                  builder: (context) {
                    if (viewModel.isLoading) {
                      return const CircularProgressIndicator();
                    }

                    return ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          viewModel.signUp(
                            emailTec.text.trim(),
                            passTec.text.trim(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryLightColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already account ? ",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign In',
                        style: const TextStyle(
                          color: primaryLightColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.go('/sign_in');
                          },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
