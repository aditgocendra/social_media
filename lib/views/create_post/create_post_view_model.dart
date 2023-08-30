import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../data/service/post_service.dart';
import '../../data/service/tag_service.dart';
import '../../data/service/user_service.dart';

class CreatePostViewModel with ChangeNotifier {
  final UserService userService;
  final TagService tagService;
  final PostService postService;

  CreatePostViewModel({
    required this.userService,
    required this.tagService,
    required this.postService,
  });

  final List<Uint8List> _listImagePicked = [];
  List<Uint8List> get listImagePicked => _listImagePicked;

  final List<String> _tags = [];
  List<String> get tags => _tags;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void initPage() {
    _listImagePicked.clear();
    _tags.clear();
    _errorMessage = null;
  }

  void addImagePicked(Uint8List imagePicked) {
    _listImagePicked.add(imagePicked);
    notifyListeners();
  }

  void addTag(String tag) {
    if (tags.contains(tag)) return;

    _tags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag) {
    _tags.removeWhere((element) => element == tag);
    notifyListeners();
  }

  void removeImagePicked(Uint8List image) {
    _listImagePicked.removeWhere((element) => element == image);
    notifyListeners();
  }

  void toogleLoading() {
    _isLoading = isLoading ? false : true;
    notifyListeners();
  }

  void setError(String? err) {
    _errorMessage = err;
    notifyListeners();
  }

  void createPost({
    required String caption,
    required VoidCallback callbackSuccess,
  }) async {
    toogleLoading();
    if (caption.isEmpty) {
      setError('Caption required');
      return;
    }

    if (listImagePicked.isEmpty) {
      setError('Image required at least one');
      return;
    }

    if (tags.length > 5) {
      setError('Maximum tag 5');
      return;
    }

    try {
      await postService.createPost(
        caption: caption,
        userId: userService.currentAuthUID()!,
        createdAt: DateTime.now(),
        tags: tags,
        images: listImagePicked,
      );

      callbackSuccess.call();
    } catch (e) {
      setError(e.toString());
    }

    toogleLoading();
  }
}
