import 'package:flutter/material.dart';

import '../../data/service/user_service.dart';

class SignInViewModel with ChangeNotifier {
  final UserService userService;

  SignInViewModel({
    required this.userService,
  });

  bool _isObscurePass = true;
  bool get isObscurePass => _isObscurePass;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errMessage;
  String? get errMessage => _errMessage;

  void toogleObscurePass() {
    _isObscurePass = isObscurePass ? false : true;
    notifyListeners();
  }

  void toogleLoading() {
    _isLoading = isLoading ? false : true;
    notifyListeners();
  }

  void setError(String? err) {
    _errMessage = err;
    notifyListeners();
  }

  void signIn({
    required String email,
    required String password,
    required Function(String userId) callbackSuccess,
  }) async {
    setError(null);
    toogleLoading();

    try {
      final r = await userService.signIn(
        email: email,
        password: password,
      );

      callbackSuccess(r.user!.uid);
    } catch (e) {
      setError(e.toString());
    }

    toogleLoading();
  }
}
