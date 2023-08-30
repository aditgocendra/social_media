import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media/auth_state.dart';

import '../../core/utils/validator.dart';
import '../../core/decorations/text_field_decoration.dart';
import '../../core/values/colors.dart';
import 'sign_in_view_model.dart';

class SignInView extends StatelessWidget {
  SignInView({super.key});

  final TextEditingController emailTec = TextEditingController();
  final TextEditingController passTec = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthState>();
    final viewModel = context.watch<SignInViewModel>();

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
                TextFormField(
                  controller: emailTec,
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
                      onPressed: () => viewModel.toogleObscurePass(),
                      icon: Icon(
                        Icons.remove_red_eye_outlined,
                        color: viewModel.isObscurePass
                            ? Colors.grey.shade500
                            : primaryLightColor,
                      ),
                    ),
                  ),
                ),
                if (viewModel.errMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      viewModel.errMessage!,
                      style: const TextStyle(color: Colors.redAccent),
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
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          viewModel.signIn(
                            email: emailTec.text.trim(),
                            password: passTec.text.trim(),
                            callbackSuccess: (String userId) {
                              authState.onSignedIn();
                              context.go('/');
                            },
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
                        'Sign In',
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
                        text: "You not have account ? ",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(
                          color: primaryLightColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.go('/sign_up');
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
