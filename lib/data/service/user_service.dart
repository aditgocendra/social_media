import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/values/globals.dart' as globals;
import '../../core/firebase/authentication.dart';
import '../../core/firebase/cloud_storage.dart';

import '../models/user_model.dart';

abstract class UserService {
  Future signUp({
    required String email,
    required String password,
  });

  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<List<String>> getAvatars();

  Future setUser(UserModel user);

  Future blockPost({required String uid, required String postId});

  Future setBlockPost({required String uid});

  Future<List<UserModel>> getUsers({
    String? searchKey,
    String? startAfterId,
  });

  Future<UserModel?> getUser(String? userId);

  Future<bool> usernameIsExist(String username);

  Future followUser({
    required String userIdFollow,
    required String userId,
  });

  Future unfollowUser({required String uidFollow, required uidUnfollow});

  Future<int> countFollowers(String uid);

  Future<int> countFollows(String uid);

  Future<bool> isUserFollow({
    required String uidCurrent,
    required String uidProfile,
  });

  Future bookmarkPost({
    required String uid,
    required String pid,
  });

  Future<List<String>> getBookmarkPost({
    required String uid,
    String? startAfterId,
  });

  Future<List<String>> getAllImage(String uid);

  String? currentAuthUID();

  void signOut();
}

class UserServiceImpl implements UserService {
  final Authentication _authentication = AuthenticationImpl();
  final CloudStorage _cloudStorage = CloudStorageImpl();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collection = 'users';

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _authentication.signIn(email: email, password: password);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future signUp({required String email, required String password}) async {
    try {
      await _authentication.signUp(email: email, password: password);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<String>> getAvatars() async {
    return await _cloudStorage.getList('avatar/');
  }

  @override
  Future setUser(UserModel user) async {
    return await _firestore.collection(_collection).doc(user.id).set(
          user.toJson(),
        );
  }

  @override
  Future<UserModel?> getUser(String? userId) async {
    if (userId == null) return null;

    final r = await _firestore.collection(_collection).doc(userId).get();

    if (!r.exists) return null;

    return UserModel.fromJson(r.data()!, r.id);
  }

  @override
  Future<bool> usernameIsExist(String username) async {
    final r = await _firestore
        .collection(_collection)
        .where('username', isEqualTo: username)
        .get();

    if (r.docs.isNotEmpty) return true;

    return false;
  }

  @override
  String? currentAuthUID() {
    final user = _authentication.getCurrentUser();

    return user?.uid;
  }

  @override
  void signOut() {
    _authentication.signOut();
  }

  @override
  Future followUser({
    required String userIdFollow,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    final followerRef = _firestore
        .collection(_collection)
        .doc(userIdFollow)
        .collection('followers')
        .doc(userId);
    batch.set(followerRef, {'createdAt': DateTime.now()});

    final followRef = _firestore
        .collection(_collection)
        .doc(userId)
        .collection('follows')
        .doc(userIdFollow);
    batch.set(followRef, {'createdAt': DateTime.now()});

    await batch.commit();
  }

  @override
  Future unfollowUser({required String uidFollow, required uidUnfollow}) async {
    final batch = _firestore.batch();

    final followerRef = _firestore
        .collection(_collection)
        .doc(uidUnfollow)
        .collection('followers')
        .doc(uidFollow);
    batch.delete(followerRef);

    final followRef = _firestore
        .collection(_collection)
        .doc(uidFollow)
        .collection('follows')
        .doc(uidUnfollow);
    batch.delete(followRef);

    await batch.commit();
  }

  @override
  Future<int> countFollowers(String uid) async {
    final r = await _firestore
        .collection(_collection)
        .doc(uid)
        .collection('followers')
        .count()
        .get();

    return r.count;
  }

  @override
  Future<int> countFollows(String uid) async {
    final r = await _firestore
        .collection(_collection)
        .doc(uid)
        .collection('follows')
        .count()
        .get();

    return r.count;
  }

  @override
  Future<bool> isUserFollow({
    required String uidCurrent,
    required String uidProfile,
  }) async {
    final r = await _firestore
        .collection(_collection)
        .doc(uidProfile)
        .collection('followers')
        .doc(uidCurrent)
        .get();

    if (r.exists) {
      return true;
    }
    return false;
  }

  @override
  Future<List<String>> getAllImage(String uid) async {
    return await _cloudStorage.getList('posts/$uid/');
  }

  @override
  Future<List<UserModel>> getUsers({
    String? searchKey,
    String? startAfterId,
  }) async {
    var collection = _firestore.collection(_collection);
    Query<Map<String, dynamic>>? query = collection;

    if (!query.isNull) {
      query = query.where('searchKey', arrayContains: searchKey);
    }

    query = query.orderBy('createdAt', descending: true);

    final r = await query.limit(15).get();

    return UserModel.fromJsonList(r.docs);
  }

  @override
  Future blockPost({
    required String uid,
    required String postId,
  }) async {
    final collection = _firestore
        .collection(_collection)
        .doc(uid)
        .collection('block')
        .doc(uid);

    final doc = await collection.get();

    // check doc
    if (!doc.exists) {
      // set collection
      await collection.set({
        'posts': [postId],
        'users': [],
        'tags': [],
      });
    } else {
      // print(doc.data()!['posts']);
      final List<dynamic> p = doc.data()!['posts'];

      // check user block post or not
      if (p.contains(postId)) {
        return;
      }

      // update collection
      await collection.update({
        'posts': FieldValue.arrayUnion([postId]),
      });
    }
  }

  @override
  Future setBlockPost({
    required String uid,
  }) async {
    final r = await _firestore
        .collection(_collection)
        .doc(uid)
        .collection('block')
        .doc(uid)
        .get();

    if (!r.exists) {
      return;
    }

    for (var element in r['posts']) {
      globals.blockPost.add(element);
    }
  }

  @override
  Future bookmarkPost({required String uid, required String pid}) async {
    final docRef = _firestore
        .collection(_collection)
        .doc(uid)
        .collection('bookmarks')
        .doc(pid);

    final r = await docRef.get();

    if (r.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'createdAt': DateTime.now(),
      });
    }
  }

  @override
  Future<List<String>> getBookmarkPost({
    required String uid,
    String? startAfterId,
  }) async {
    List<String> bookmarksPostId = [];

    final collection =
        _firestore.collection(_collection).doc(uid).collection('bookmarks');

    Query<Map<String, dynamic>>? query = collection;

    if (startAfterId != null) {
      final doc = await collection.doc(startAfterId).get();
      query = query.startAfterDocument(doc);
    }

    final r = await query.limit(10).get();

    for (var element in r.docs) {
      bookmarksPostId.add(element.id);
    }

    return bookmarksPostId;
  }
}
