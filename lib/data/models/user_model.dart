import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String username;
  String photoProfile;
  String status;
  String gender;
  List<String> searchKey;
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.photoProfile,
    required this.status,
    required this.gender,
    required this.searchKey,
    required this.createdAt,
  });

  UserModel.fromJson(Map<String, dynamic> json, String id)
      : this(
          username: json['username'] as String,
          photoProfile: json['photoProfile'] as String,
          status: json['status'] as String,
          gender: json['gender'] as String,
          searchKey: List.from(json['searchKey']),
          createdAt: json['createdAt'].toDate() as DateTime,
          id: id,
        );

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'photoProfile': photoProfile,
      'status': status,
      'gender': gender,
      'searchKey': searchKey,
      'createdAt': createdAt,
    };
  }

  static List<UserModel> fromJsonList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> data,
  ) {
    if (data.isEmpty) return [];

    return data.map((val) {
      return UserModel.fromJson(val.data(), val.id);
    }).toList();
  }
}
