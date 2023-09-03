import 'dart:js_interop';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../../core/firebase/cloud_storage.dart';

abstract class PostService {
  Future createPost({
    required String caption,
    required String userId,
    required DateTime createdAt,
    required List<String> tags,
    required List<Uint8List> images,
  });

  Future<List<PostModel>> getPosts({
    String? uid,
    String? searchKey,
    String? startAfterId,
  });

  Future<PostModel> getPost(String id);

  Future updatePost({
    required PostModel post,
    required List<Uint8List> newImage,
    required List<String> imageDeleted,
  });

  Future<int> updateCounter({
    required String postId,
    required String userId,
    required String field,
  });

  Future deletePost(PostModel post);

  Future<bool> isUserLikePost({
    required String userId,
    required String postId,
  });

  Future<bool> isUserBookmarkPost({
    required String userId,
    required String postId,
  });

  Future<CommentModel> createComment({
    required String id,
    required String userId,
    required String comment,
  });

  Future<List<CommentModel>> getComments({
    required String postId,
    String? startAfterId,
  });
}

class PostServiceImpl implements PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudStorage _cloudStorage = CloudStorageImpl();
  final String _collection = 'posts';

  @override
  Future createPost({
    required String caption,
    required String userId,
    required DateTime createdAt,
    required List<String> tags,
    required List<Uint8List> images,
  }) async {
    final content = await _cloudStorage.uploadFiles(images, userId);

    final PostModel post = PostModel(
      id: '',
      caption: caption,
      userId: userId,
      content: content,
      counter: {
        'likes': 0,
        'comments': 0,
        'bookmarks': 0,
      },
      createdAt: createdAt,
      tags: tags,
    );

    await _firestore.collection(_collection).add(post.toJson());
  }

  @override
  Future<List<PostModel>> getPosts({
    String? uid,
    String? searchKey,
    String? startAfterId,
  }) async {
    var collection = _firestore.collection(_collection);

    Query<Map<String, dynamic>>? query = collection;

    if (!uid.isNull) {
      query = query.where('userId', isEqualTo: uid);
    }

    if (!searchKey.isNull) {
      query = query.where('tags', arrayContains: searchKey);
    }

    query = query.orderBy('createdAt', descending: true);

    if (!startAfterId.isNull) {
      final r = await collection.doc(startAfterId).get();
      query = query.startAfterDocument(r);
    }

    final r = await query.limit(10).get();

    return PostModel.fromJsonList(r.docs);
  }

  @override
  Future<PostModel> getPost(String id) async {
    final r = await _firestore.collection(_collection).doc(id).get();

    if (!r.exists) throw Exception('Post not found');

    return PostModel.fromJson(r.data()!, r.id);
  }

  @override
  Future<int> updateCounter({
    required String postId,
    required String userId,
    required String field,
  }) async {
    final queryPostDoc = _firestore.collection(_collection).doc(postId);
    final post = await queryPostDoc.get();
    final queryPostCounter = queryPostDoc.collection(field);

    if (!post.exists) throw Exception('Post not found');

    final counter = await _firestore.runTransaction((transaction) async {
      final userLike = await transaction.get(queryPostCounter.doc(userId));

      if (!userLike.exists) {
        transaction.set(queryPostCounter.doc(userId), {
          'createdAt': DateTime.now(),
        });
      } else {
        transaction.delete(queryPostCounter.doc(userId));
      }

      final operation = userLike.exists ? false : true;

      final count = await queryPostCounter.count().get();
      final c = operation ? count.count + 1 : count.count - 1;

      transaction.update(queryPostDoc, {
        'counter.$field': c,
      });

      return c;
    }).catchError((e) {
      throw Exception(e.toString());
    });

    return counter;
  }

  @override
  Future<bool> isUserLikePost({
    required String userId,
    required String postId,
  }) async {
    final r = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .get();

    if (r.exists) return true;

    return false;
  }

  @override
  Future<bool> isUserBookmarkPost({
    required String userId,
    required String postId,
  }) async {
    final r = await _firestore
        .collection(_collection)
        .doc(postId)
        .collection('bookmarks')
        .doc(userId)
        .get();

    if (r.exists) return true;

    return false;
  }

  @override
  Future<CommentModel> createComment({
    required String id,
    required String userId,
    required String comment,
  }) async {
    final c = CommentModel(
      id: '',
      userId: userId,
      comment: comment,
      createdAt: DateTime.now(),
    );
    final q = _firestore.collection(_collection).doc(id).collection('comments');

    final r = await q.add(c.toJson());

    final count = await q.count().get();

    await _firestore.collection(_collection).doc(id).update(
      {'counter.comments': count.count},
    );

    c.id = r.id;

    return c;
  }

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    String? startAfterId,
  }) async {
    final collection =
        _firestore.collection(_collection).doc(postId).collection('comments');

    Query<Map<String, dynamic>>? query = collection;

    // Order
    query = query.orderBy('createdAt', descending: true);

    if (startAfterId != null) {
      final last = await collection.doc(startAfterId).get();
      query = query.startAfterDocument(last);
    }

    final r = await query.limit(10).get();

    return CommentModel.fromJsonList(r.docs);
  }

  @override
  Future deletePost(PostModel post) async {
    final batch = _firestore.batch();
    final doc = _firestore.collection(_collection).doc(post.id);

    await doc.collection('comments').get().then((snap) async {
      if (snap.docs.isEmpty) {
        return;
      }

      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
    });

    await doc.collection('likes').get().then((snap) async {
      if (snap.docs.isEmpty) {
        return;
      }

      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
    });

    await doc.collection('bookmarks').get().then((snap) async {
      if (snap.docs.isEmpty) {
        return;
      }

      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
    });

    batch.delete(doc);

    for (var element in post.content) {
      await _cloudStorage.removeImage(element);
    }

    batch.commit();
  }

  @override
  Future updatePost({
    required PostModel post,
    required List<Uint8List> newImage,
    required List<String> imageDeleted,
  }) async {
    // Delete old image
    for (var element in imageDeleted) {
      await _cloudStorage.removeImage(element);
      post.content.removeWhere((v) => v == element);
    }

    // Upload new image
    final n = await _cloudStorage.uploadFiles(newImage, post.userId);

    // Add all new image
    post.content.addAll(n);

    // Update post
    await _firestore.collection(_collection).doc(post.id).set(post.toJson());
  }
}
