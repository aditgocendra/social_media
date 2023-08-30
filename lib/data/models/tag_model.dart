class TagModel {
  String tag;
  int totalPost;

  TagModel({
    required this.tag,
    required this.totalPost,
  });

  TagModel.fromJson(Map<String, dynamic> json)
      : this(
          tag: json['tag'] as String,
          totalPost: json['totalPost'] as int,
        );

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'totalPost': totalPost,
    };
  }
}
