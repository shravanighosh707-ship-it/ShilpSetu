import 'package:cloud_firestore/cloud_firestore.dart';

class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Finds products that match a buyer requirement.
  ///
  /// Matching weights:
  /// Category   = 30
  /// Craft type = 30
  /// Budget     = 25
  /// Location   = 15
  ///
  /// Maximum score = 100
  Future<List<Map<String, dynamic>>> findMatches({
    required String requirementId,
  }) async {
    // Get requirement
    final requirementSnapshot = await _firestore
        .collection('requirements')
        .doc(requirementId)
        .get();

    if (!requirementSnapshot.exists) {
      throw Exception('Requirement not found.');
    }

    final requirement = requirementSnapshot.data();

    if (requirement == null) {
      throw Exception('Requirement data is empty.');
    }

    final String requiredCategory = (requirement['category'] ?? '').toString();

    final String requiredCraftType = (requirement['craftType'] ?? '')
        .toString();

    final double budgetMin =
        (requirement['budgetMin'] as num?)?.toDouble() ?? 0;

    final double budgetMax =
        (requirement['budgetMax'] as num?)?.toDouble() ?? 0;

    final String requiredLocation = (requirement['location'] ?? '').toString();

    // Get products
    final productsSnapshot = await _firestore.collection('products').get();

    final List<Map<String, dynamic>> matches = [];

    for (final productDocument in productsSnapshot.docs) {
      final product = productDocument.data();

      final String productCategory = (product['category'] ?? '').toString();

      final String productCraftType = (product['craftType'] ?? '').toString();

      final double productPrice = (product['price'] as num?)?.toDouble() ?? 0;

      final String artisanId = (product['artisanId'] ?? '').toString();

      double score = 0;

      // Category: 30 points
      if (_matches(productCategory, requiredCategory)) {
        score += 30;
      }

      // Craft type: 30 points
      if (_matches(productCraftType, requiredCraftType)) {
        score += 30;
      }

      // Budget: 25 points
      if (productPrice >= budgetMin && productPrice <= budgetMax) {
        score += 25;
      }

      // Location: 15 points
      String artisanLocation = '';

      if (artisanId.isNotEmpty) {
        final artisanSnapshot = await _firestore
            .collection('artisan_profiles')
            .doc(artisanId)
            .get();

        if (artisanSnapshot.exists) {
          final artisan = artisanSnapshot.data();

          artisanLocation = (artisan?['location'] ?? '').toString();

          if (_matches(artisanLocation, requiredLocation)) {
            score += 15;
          }
        }
      }

      // Keep products with at least one matching factor.
      if (score > 0) {
        matches.add({
          'productId': productDocument.id,
          'artisanId': artisanId,
          'productName': product['name'],
          'description': product['description'],
          'category': productCategory,
          'craftType': productCraftType,
          'price': productPrice,
          'artisanLocation': artisanLocation,
          'matchScore': score,
        });
      }
    }

    // Highest score first.
    matches.sort(
      (a, b) =>
          (b['matchScore'] as double).compareTo(a['matchScore'] as double),
    );

    return matches;
  }

  bool _matches(String value1, String value2) {
    if (value1.isEmpty || value2.isEmpty) {
      return false;
    }

    return value1.trim().toLowerCase() == value2.trim().toLowerCase();
  }
}
