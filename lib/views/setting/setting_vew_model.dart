import 'package:flutter/material.dart';
import 'package:social_media/data/models/user_model.dart';
import 'package:social_media/data/service/user_service.dart';

class SettingViewModel with ChangeNotifier {
  final UserService userService;

  SettingViewModel({
    required this.userService,
  });

  UserModel? _user;
  UserModel? get user => _user;

  void setUser() async {
    final r = await userService.getUser(userService.currentAuthUID());

    _user = r;
  }
}
