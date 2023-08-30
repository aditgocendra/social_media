import 'package:flutter/material.dart';

import '../../data/service/user_service.dart';

class SignUpViewModel with ChangeNotifier {
  final UserService userService;

  SignUpViewModel({
    required this.userService,
  });

  bool _isObscurePass = true;
  bool get isObscurePass => _isObscurePass;

  bool _isObscureConfPass = true;
  bool get isObscureConfPass => _isObscureConfPass;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errMessage;
  String? get errMessage => _errMessage;

  void toogleObscure(bool isPassword) {
    if (isPassword) {
      _isObscurePass = isObscurePass ? false : true;
    } else {
      _isObscureConfPass = isObscureConfPass ? false : true;
    }

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

  void signUp(String email, String password) async {
    setError(null);
    toogleLoading();

    try {
      await userService.signUp(email: email, password: password);
    } catch (e) {
      setError(e.toString());
    }

    toogleLoading();
  }
}
