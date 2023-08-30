import 'dart:js_interop';

import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import 'edit_profile_view.dart';

import '../../data/service/user_service.dart';

class EditProfileViewModel with ChangeNotifier {
  final UserService userService;

  EditProfileViewModel({
    required this.userService,
  });

  Gender _genderSelect = Gender.male;
  Gender get genderSelect => _genderSelect;

  final List<String> _avatars = [];
  List<String> get avatars => _avatars;

  UserModel? _user;
  UserModel? get user => _user;

  String? _errMessage;
  String? get errMessage => _errMessage;

  void initView() async {
    resetView();
    await getAvatars();
    await setUser();

    notifyListeners();
  }

  Future getAvatars() async {
    final r = await userService.getAvatars();

    _avatars.addAll(r);
  }

  Future setUser() async {
    final r = await userService.getUser(userService.currentAuthUID());

    if (!r.isNull) {
      _user = r;
      setGenderSelect(user!.gender == 'male' ? Gender.male : Gender.female);
    }
  }

  void setGenderSelect(Gender gender) {
    _genderSelect = gender;
    notifyListeners();
  }

  void resetView() {
    avatars.clear();
    _user = null;
  }

  void setError(String? err) {
    _errMessage = err;
    notifyListeners();
  }

  void saveUser({
    required String username,
    required String status,
    required VoidCallback callbackSuccess,
  }) async {
    UserModel user = UserModel(
      id: userService.currentAuthUID()!,
      username: username,
      photoProfile: genderSelect == Gender.male ? avatars.last : avatars.first,
      status: status,
      gender: genderSelect.name,
      searchKey: _generateSearchKey(username.toLowerCase()),
      createdAt: DateTime.now(),
    );

    try {
      await userService.setUser(user);

      callbackSuccess.call();
    } catch (e) {
      setError(e.toString());
    }
  }

  List<String> _generateSearchKey(String username) {
    List<String> result = [];
    final split = username.split(' ');

    result.add(username);
    result.addAll(split);

    return result;
  }
}
