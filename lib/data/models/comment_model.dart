import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String id;
  String userId;
  String comment;
  DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.comment,
    required this.createdAt,
  });

  CommentModel.fromJson(Map<String, dynamic> json, String id)
      : this(
          id: id,
          userId: json['userId'] as String,
          comment: json['comment'] as String,
          createdAt: json['createdAt'].toDate() as DateTime,
        );

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  static List<CommentModel> fromJsonList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> data,
  ) {
    if (data.isEmpty) return [];

    return data.map((val) {
      return CommentModel.fromJson(val.data(), val.id);
    }).toList();
  }
}
