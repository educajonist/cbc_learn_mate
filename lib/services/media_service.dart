import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class MediaService {
  // IMAGE (WEB SAFE)
  static Future<String?> pickImageBase64() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return null;

    final bytes = result.files.first.bytes;
    if (bytes == null) return null;

    return base64Encode(bytes);
  }

  static Uint8List fromBase64(String data) {
    return base64Decode(data);
  }
}
