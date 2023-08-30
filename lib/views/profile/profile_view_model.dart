import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';
import '../../data/service/post_service.dart';
import '../../data/service/user_service.dart';

class ProfileViewModel with ChangeNotifier {
  final UserService userService;
  final PostService postService;

  ProfileViewModel({
    required this.userService,
    required this.postService,
  });

  bool? _isUserProfile;
  bool? get isUserProfile => _isUserProfile;

  bool _isUserFollow = false;
  bool get isUserFollow => _isUserFollow;

  UserModel? _user;
  UserModel? get user => _user;

  final List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> get posts => _posts;

  List<String> _userImages = [];
  List<String> get userImages => _userImages;

  (int, int) _follow = (0, 0);
  (int, int) get follow => _follow;

  String? _errMessage;
  String? get errMessage => _errMessage;

  void initView(String uid) async {
    reset();

    if (uid == userService.currentAuthUID()) {
      _isUserProfile = true;
    } else {
      _isUserProfile = false;

      _isUserFollow = await userService.isUserFollow(
        uidCurrent: userService.currentAuthUID()!,
        uidProfile: uid,
      );
    }

    await setUserData(uid);
    await setCountFollowers();
    await setPosts(uid);
    await setUserGallery(uid);
  }

  void reset() {
    _userImages.clear();
    _posts.clear();

    _follow = (0, 0);
    _isUserFollow = false;

    _isUserProfile = null;
    _user = null;
  }

  void folowUser() async {
    await userService.followUser(
      userIdFollow: user!.id,
      userId: userService.currentAuthUID()!,
    );

    await setCountFollowers();
    _isUserFollow = true;
    notifyListeners();
  }

  void unfollowUser() async {
    await userService.unfollowUser(
      uidFollow: userService.currentAuthUID()!,
      uidUnfollow: user!.id,
    );

    await setCountFollowers();
    _isUserFollow = false;
    notifyListeners();
  }

  void updateCounterPost(String id, String field) async {
    try {
      final r = await postService.updateCounter(
        postId: id,
        userId: userService.currentAuthUID()!,
        field: field,
      );

      final index = _posts.indexWhere(
        (element) => element['post'].id == id,
      );

      _posts[index][field == 'bookmarks' ? 'isBookmark' : 'isLike'] =
          _posts[index][field == 'bookmarks' ? 'isBookmark' : 'isLike']
              ? false
              : true;

      final PostModel post = _posts[index]['post'];
      post.counter[field] = r;

      _posts[index]['post'] = post;

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void blockPost({required String uid, required String postId}) async {
    try {
      await userService.blockPost(uid: uid, postId: postId);
      _posts.removeWhere((element) => element['post'].id == postId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void deletePost(PostModel post) async {
    try {
      await postService.deletePost(post);
      _posts.removeWhere((element) => element['post'] == post);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void setError(String? err) {
    _errMessage = err;
    notifyListeners();
  }

  Future setUserData(String idUser) async {
    try {
      _user = await userService.getUser(idUser);
    } catch (e) {
      setError(e.toString());
    }
  }

  Future setUserGallery(String uid) async {
    try {
      _userImages = await userService.getAllImage(uid);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future setCountFollowers() async {
    final f1 = await userService.countFollowers(user!.id);
    final f2 = await userService.countFollows(user!.id);
    _follow = (f1, f2);
    notifyListeners();
  }

  Future setPosts(String uid) async {
    try {
      final r = await postService.getPosts(uid: uid);

      for (var post in r) {
        final isUserLike = await postService.isUserLikePost(
          userId: userService.currentAuthUID()!,
          postId: post.id,
        );

        final isUserBookmark = await postService.isUserBookmarkPost(
          userId: userService.currentAuthUID()!,
          postId: post.id,
        );

        final userPost = await userService.getUser(post.userId);

        _posts.add({
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
  }
}
