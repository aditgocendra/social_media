import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/data/models/tag_model.dart';

abstract class TagService {
  Future<TagModel?> createTag(TagModel tag);
}

class TagServiceImpl implements TagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tags';

  @override
  Future<TagModel?> createTag(TagModel tag) async {
    var collection = _firestore.collection(_collection);
    final r = await collection.where('tag', isEqualTo: tag.tag).get();

    if (r.docs.isEmpty) return null;

    await collection.add(tag.toJson());

    return tag;
  }
}
