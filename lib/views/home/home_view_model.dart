import 'package:flutter/material.dart';
import 'package:social_media/data/models/post_model.dart';

import '../../data/service/post_service.dart';
import '../../data/service/user_service.dart';

class HomeViewModel with ChangeNotifier {
  final UserService userService;
  final PostService postService;

  HomeViewModel({
    required this.userService,
    required this.postService,
  });

  final List<Map<String, dynamic>> _postUsers = [];
  List<Map<String, dynamic>> get postUsers => _postUsers;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errMessage;
  String? get errMessage => _errMessage;

  void initView() async {
    reset();
    await userService.setBlockPost(uid: userService.currentAuthUID()!);
    await setPost();
  }

  void reset() {
    _postUsers.clear();
    _isLoading = true;
  }

  void setError(String? err) {
    _errMessage = err;
    notifyListeners();
  }

  void toogleLoading() => _isLoading = isLoading ? false : true;

  void updateCounterPost(String id, String field) async {
    try {
      final r = await postService.updateCounter(
        postId: id,
        userId: userService.currentAuthUID()!,
        field: field,
      );

      final index = _postUsers.indexWhere(
        (element) => element['post'].id == id,
      );

      _postUsers[index][field == 'bookmarks' ? 'isBookmark' : 'isLike'] =
          postUsers[index][field == 'bookmarks' ? 'isBookmark' : 'isLike']
              ? false
              : true;

      final PostModel post = postUsers[index]['post'];
      post.counter[field] = r;

      _postUsers[index]['post'] = post;

      if (field == 'bookmarks') {
        await userService.bookmarkPost(
          uid: userService.currentAuthUID()!,
          pid: id,
        );
      }

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void blockPost({
    required String uid,
    required String postId,
  }) async {
    try {
      await userService.blockPost(uid: uid, postId: postId);
      _postUsers.removeWhere((element) => element['post'].id == postId);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void deletePost(PostModel post) async {
    try {
      await postService.deletePost(post);
      _postUsers.removeWhere((element) => element['post'] == post);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future setPost() async {
    try {
      final posts = await postService.getPosts();

      for (var post in posts) {
        final isUserLike = await postService.isUserLikePost(
          userId: userService.currentAuthUID()!,
          postId: post.id,
        );

        final isUserBookmark = await postService.isUserBookmarkPost(
          userId: userService.currentAuthUID()!,
          postId: post.id,
        );

        final userPost = await userService.getUser(post.userId);

        _postUsers.add({
          'post': post,
          'user': userPost,
          'isLike': isUserLike,
          'isBookmark': isUserBookmark,
        });
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }

    toogleLoading();
    notifyListeners();
  }
}
