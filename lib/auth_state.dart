import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/core/values/globals.dart';
import 'package:social_media/data/models/user_model.dart';

import 'package:social_media/data/service/user_service.dart';

class AuthState with ChangeNotifier {
  final UserService userService;

  AuthState({required this.userService}) {
    if (userService.currentAuthUID() != null) {
      onSignedIn();
    } else {
      onSignedOut();
    }
  }

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserModel? _userData;
  UserModel? get userData => _userData;

  UserCredential? _userCredential;
  UserCredential? get userCredential => _userCredential;

  void onSignedIn() async {
    _isSignedIn = true;
    await setUserData();
    _toogle();
  }

  Future setUserData() async {
    _userData = await userService.getUser(userService.currentAuthUID());
  }

  void _toogle() {
    _isLoading = isLoading ? false : true;
    notifyListeners();
  }

  void onSignedOut() {
    userService.signOut();
    _isLoading = true;
    _isSignedIn = false;
    _userData = null;
    blockPost.clear();

    notifyListeners();
  }
}
