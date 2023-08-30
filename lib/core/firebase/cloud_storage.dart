import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

abstract class CloudStorage {
  Future<List<String>> getList(String path);

  Future<List<String>> uploadFiles(List<Uint8List> files, String idUser);

  Future removeImage(String url);
}

class CloudStorageImpl implements CloudStorage {
  final FirebaseStorage _cloudStorage = FirebaseStorage.instance;

  @override
  Future<List<String>> getList(String path) async {
    List<String> urls = [];

    final r = await _cloudStorage.ref().child(path).listAll();

    for (var element in r.items) {
      urls.add(await element.getDownloadURL());
    }

    return urls;
  }

  @override
  Future<List<String>> uploadFiles(
    List<Uint8List> files,
    String idUser,
  ) async {
    final List<String> results = [];

    for (var element in files) {
      final filename = DateTime.now().microsecondsSinceEpoch.toString();

      final ref = _cloudStorage.ref().child('posts/$idUser/$filename');

      await ref.putData(element, SettableMetadata(contentType: 'image/jpeg'));

      final url = await ref.getDownloadURL();

      results.add(url);
    }

    return results;
  }

  @override
  Future removeImage(String url) async {
    await _cloudStorage.refFromURL(url).delete();
  }
}
