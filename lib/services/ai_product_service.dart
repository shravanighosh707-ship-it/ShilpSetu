import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';

class AIProductService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> generateProductCatalog(File image) async {
    final bytes = await image.readAsBytes();
    final imageBase64 = base64Encode(bytes);

    final callable = _functions.httpsCallable('generateProductCatalog');

    final result = await callable.call({
      'imageBase64': imageBase64,
      'mimeType': 'image/jpeg',
    });

    final data = Map<String, dynamic>.from(result.data as Map);

    return Map<String, dynamic>.from(data['catalog'] as Map);
  }
}
