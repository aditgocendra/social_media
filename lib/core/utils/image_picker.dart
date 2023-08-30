import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

Future<Uint8List?> pickerImageWeb() async {
  XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 25,
  );

  if (image != null) {
    return await image.readAsBytes();
  }

  return null;
}
