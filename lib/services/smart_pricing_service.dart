import 'package:cloud_functions/cloud_functions.dart';

class SmartPricingService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> generateSmartPrice({
    required String productName,
    required String category,
    required String craftType,
    String? description,
    String? location,
    String? material,
    String? experience,
  }) async {
    final callable = _functions.httpsCallable('generateSmartPrice');

    final result = await callable.call({
      'productName': productName,
      'category': category,
      'craftType': craftType,
      'description': description,
      'location': location,
      'material': material,
      'experience': experience,
    });

    final data = Map<String, dynamic>.from(result.data as Map);

    return Map<String, dynamic>.from(
      data['pricing'] as Map,
    );
  }
}