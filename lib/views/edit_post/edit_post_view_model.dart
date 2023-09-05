import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:social_media/data/models/post_model.dart';
import 'package:social_media/data/service/post_service.dart';

class EditPostViewModel with ChangeNotifier {
  final PostService postService;

  EditPostViewModel({
    required this.postService,
  });

  final List<dynamic> _imageContent = [];
  List<dynamic> get imageContent => _imageContent;

  final List<String> _imageContentDelete = [];
  List<String> get imageContentDelete => _imageContentDelete;

  PostModel? _post;
  PostModel? get post => _post;

  String _caption = '';
  String get caption => _caption;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void initView(String id) async {
    reset();
    await setPost(id);
  }

  void reset() {
    _imageContent.clear();
    _imageContent.clear();
    _imageContentDelete.clear();
    _isLoading = false;
    _post = null;
  }

  void changeCaption(String newCaption) {
    _caption = newCaption;
  }

  void addTag(String tag) {
    if (_post!.tags.contains(tag)) return;

    _post!.tags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag) {
    _post!.tags.removeWhere((element) => element == tag);
    notifyListeners();
  }

  void setError(String? err) {
    _errorMessage = err;
    notifyListeners();
  }

  void addImagePicked(Uint8List imagePicked) {
    _imageContent.add(imagePicked);
    notifyListeners();
  }

  void removeImagePicked(dynamic image) {
    _imageContent.removeWhere((element) => element == image);
    if (image.runtimeType == String) {
      _imageContentDelete.add(image);
    }

    notifyListeners();
  }

  void updatePost({
    required VoidCallback callbackSuccess,
  }) async {
    _post!.caption = caption;
    List<Uint8List> newImage = [];

    for (var element in imageContent) {
      if (element.runtimeType == Uint8List) {
        newImage.add(element);
      }
    }

    try {
      await postService.updatePost(
        post: post!,
        newImage: newImage,
        imageDeleted: imageContentDelete,
      );

      callbackSuccess.call();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future setPost(String id) async {
    try {
      _post = await postService.getPost(id);
      for (var element in post!.content) {
        _imageContent.add(element);
      }

      _caption = post!.caption;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }
}
