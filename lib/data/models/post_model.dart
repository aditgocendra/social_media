import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/core/values/globals.dart' as globals;

class PostModel {
  String id;
  String caption;
  String userId;
  List<String> content;
  List<String> tags;
  Map<String, int> counter;
  DateTime createdAt;

  PostModel({
    required this.id,
    required this.caption,
    required this.userId,
    required this.content,
    required this.tags,
    required this.counter,
    required this.createdAt,
  });

  PostModel.fromJson(Map<String, dynamic> json, String id)
      : this(
          id: id,
          caption: json['caption'] as String,
          userId: json['userId'] as String,
          content: List.from(json['content']),
          tags: List.from(json['tags']),
          counter: Map<String, int>.from(json['counter']),
          createdAt: json['createdAt'].toDate() as DateTime,
        );

  Map<String, dynamic> toJson() {
    return {
      'caption': caption,
      'userId': userId,
      'content': content,
      'tags': tags,
      'counter': counter,
      'createdAt': createdAt,
    };
  }

  static List<PostModel> fromJsonList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> data,
  ) {
    if (data.isEmpty) return [];

    final List<PostModel> list = [];

    for (var val in data) {
      if (globals.blockPost.contains(val.id)) continue;
      list.add(PostModel.fromJson(val.data(), val.id));
    }

    return list;
    // return data.map((val) {
    //   return PostModel.fromJson(val.data(), val.id);
    // }).toList();
  }
}
