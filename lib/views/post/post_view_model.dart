import 'package:flutter/material.dart';

import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';
import '../../data/service/post_service.dart';
import '../../data/service/user_service.dart';

class PostViewModel with ChangeNotifier {
  final PostService postService;
  final UserService userService;

  PostViewModel({
    required this.postService,
    required this.userService,
  });

  PostModel? _post;
  PostModel? get post => _post;

  final List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> get comments => _comments;

  UserModel? _userPost;
  UserModel? get userPost => _userPost;

  bool _isUserLike = false;
  bool get isUserLike => _isUserLike;

  bool _isUserBookmark = false;
  bool get isUserBookmark => _isUserBookmark;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errMessage;
  String? get errMessage => _errMessage;

  void initView(String id) async {
    reset();
    await setPost(id);
    await setComments(postId: id, startAfterId: null);
  }

  void reset() {
    _post = null;
    _userPost = null;
    _errMessage = null;
    _isLoading = false;
    _isUserBookmark = false;
    _isUserLike = false;
    _comments.clear();
  }

  void tooggleLoading() {
    _isLoading = isLoading ? false : true;
    notifyListeners();
  }

  void setError(String? err) => _errMessage = err;

  void updateCounterPost(String id, String field) async {
    try {
      final r = await postService.updateCounter(
        postId: id,
        userId: userService.currentAuthUID()!,
        field: field,
      );

      _isUserLike = isUserLike ? false : true;
      _isUserBookmark = isUserBookmark ? false : true;

      _post!.counter[field] = r;

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void createComment({required String comment}) async {
    try {
      final r = await postService.createComment(
        id: post!.id,
        userId: userService.currentAuthUID()!,
        comment: comment,
      );

      final userComment = await userService.getUser(r.userId);

      _comments.insert(0, {
        'comment': r,
        'user': userComment,
      });
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void blockPost({required String uid, required String postId}) async {
    try {
      await userService.blockPost(uid: uid, postId: postId);
    } catch (e) {
      setError(e.toString());
    }
  }

  void deletePost(PostModel post) async {
    await postService.deletePost(post);
  }

  Future setPost(String id) async {
    try {
      _post = await postService.getPost(id);

      _userPost = await userService.getUser(post!.userId);

      _isUserLike = await postService.isUserLikePost(
        userId: userPost!.id,
        postId: post!.id,
      );

      _isUserBookmark = await postService.isUserBookmarkPost(
        userId: userPost!.id,
        postId: post!.id,
      );

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future setComments({required String postId, String? startAfterId}) async {
    final data = await postService.getComments(
      postId: postId,
      startAfterId: startAfterId,
    );

    for (var v in data) {
      final userComment = await userService.getUser(
        v.userId,
      );

      _comments.add({
        'comment': v,
        'user': userComment,
      });
    }

    notifyListeners();
  }
}
