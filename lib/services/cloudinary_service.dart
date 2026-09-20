import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';

class CloudinaryService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> uploadProductImage(File image) async {
    final bytes = await image.readAsBytes();
    final imageBase64 = base64Encode(bytes);

    final callable = _functions.httpsCallable('uploadProductImage');

    final result = await callable.call({
      'imageBase64': imageBase64,
      'mimeType': 'image/jpeg',
    });

    return Map<String, dynamic>.from(result.data as Map);
  }
}
