import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../../data/models/post_model.dart';
import '../../data/service/post_service.dart';
import '../../data/service/user_service.dart';

class SearchViewModel with ChangeNotifier {
  final UserService userService;
  final PostService postService;

  SearchViewModel({
    required this.userService,
    required this.postService,
  });

  final List<Map<String, dynamic>> _resultPosts = [];
  List<Map<String, dynamic>> get resultPosts => _resultPosts;

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  String? _errMessage;
  String? get errMessage => _errMessage;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void initView(String query) async {
    reset();
    await setPosts(query, null);
    // await setUsers(query);
  }

  void reset() {
    _resultPosts.clear();
    _users.clear();
    _errMessage = null;
  }

  void toogleLoading() => _isLoading = isLoading ? false : true;

  void setError(String? err) {
    _errMessage = err;
    notifyListeners();
  }

  void updateCounterPost(String id, String field) async {
    try {
      final r = await postService.updateCounter(
        postId: id,
        userId: userService.currentAuthUID()!,
        field: field,
      );

      final index = _resultPosts.indexWhere(
        (element) => element['post'].id == id,
      );

      _resultPosts[index][field == 'bookmarks' ? 'isBookmark' : 'isLike'] =
          resultPosts[index][field == 'bookmarks' ? 'isBookmark' : 'isLike']
              ? false
              : true;

      final PostModel post = resultPosts[index]['post'];
      post.counter[field] = r;

      _resultPosts[index]['post'] = post;

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void blockPost({required String uid, required String postId}) async {
    try {
      await userService.blockPost(uid: uid, postId: postId);
      _resultPosts.removeWhere((element) => element['post'].id == postId);
    } catch (e) {
      setError(e.toString());
    }
  }

  void deletePost(PostModel post) async {
    await postService.deletePost(post);
  }

  Future setPosts(String query, String? lastId) async {
    try {
      final posts = await postService.getPosts(
        searchKey: query,
        startAfterId: lastId,
      );

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

        _resultPosts.add({
          'post': post,
          'user': userPost,
          'isLike': isUserLike,
          'isBookmark': isUserBookmark,
        });
      }

      toogleLoading();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future setUsers(String query) async {
    try {
      _users = await userService.getUsers(searchKey: query);
    } catch (e) {
      setError(e.toString());
    }
  }
}
