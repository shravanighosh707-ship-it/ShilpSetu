import 'package:cloud_firestore/cloud_firestore.dart';

import 'matching_engine.dart';

class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MatchingEngine _engine = MatchingEngine();

  /// Finds products from one or more artisans that can collectively
  /// satisfy a buyer requirement.
  Future<Map<String, dynamic>> findMatches({
    required String requirementId,
  }) async {
    // ----------------------------------------------------------
    // 1. GET BUYER REQUIREMENT
    // ----------------------------------------------------------

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

    final int requiredQuantity =
        (requirement['quantity'] as num?)?.toInt() ?? 0;

    if (requiredQuantity <= 0) {
      throw Exception('Requirement quantity must be greater than zero.');
    }

    final String requiredCategory = (requirement['category'] ?? '').toString();

    final String requiredCraftType = (requirement['craftType'] ?? '')
        .toString();

    final double budgetMin =
        (requirement['budgetMin'] as num?)?.toDouble() ?? 0;

    final double budgetMax =
        (requirement['budgetMax'] as num?)?.toDouble() ?? 0;

    final String requiredLocation = (requirement['location'] ?? '').toString();

    // ----------------------------------------------------------
    // 2. GET ALL PRODUCTS
    // ----------------------------------------------------------

    final productsSnapshot = await _firestore.collection('products').get();

    if (productsSnapshot.docs.isEmpty) {
      return {
        'requirementId': requirementId,
        'requiredQuantity': requiredQuantity,
        'matchedQuantity': 0,
        'remainingQuantity': requiredQuantity,
        'fullyMatched': false,
        'matches': <Map<String, dynamic>>[],
      };
    }

    // ----------------------------------------------------------
    // 3. COLLECT UNIQUE ARTISAN IDS
    // ----------------------------------------------------------

    final Set<String> artisanIds = {};

    for (final productDocument in productsSnapshot.docs) {
      final product = productDocument.data();

      final String artisanId = (product['artisanId'] ?? '').toString();

      if (artisanId.isNotEmpty) {
        artisanIds.add(artisanId);
      }
    }

    // ----------------------------------------------------------
    // 4. LOAD ARTISAN LOCATIONS
    // ----------------------------------------------------------

    final Map<String, String> artisanLocations = {};

    for (final artisanId in artisanIds) {
      final artisanSnapshot = await _firestore
          .collection('artisan_profiles')
          .doc(artisanId)
          .get();

      if (artisanSnapshot.exists) {
        final artisan = artisanSnapshot.data();

        artisanLocations[artisanId] = (artisan?['location'] ?? '').toString();
      }
    }

    // ----------------------------------------------------------
    // 5. BUILD MATCHING CANDIDATES
    // ----------------------------------------------------------

    final List<Map<String, dynamic>> candidates = [];

    for (final productDocument in productsSnapshot.docs) {
      final product = productDocument.data();

      final String artisanId = (product['artisanId'] ?? '').toString();

      final int availableQuantity =
          (product['availableQuantity'] as num?)?.toInt() ?? 0;

      // Ignore products with no available supply.
      if (availableQuantity <= 0) {
        continue;
      }

      final String productCategory = (product['category'] ?? '').toString();

      final String productCraftType = (product['craftType'] ?? '').toString();

      final double productPrice = (product['price'] as num?)?.toDouble() ?? 0;

      final String artisanLocation = artisanLocations[artisanId] ?? '';

      // --------------------------------------------------------
      // USE MATCHING ENGINE
      // --------------------------------------------------------

      final double matchScore = _engine.calculateMatchScore(
        productCategory: productCategory,
        requiredCategory: requiredCategory,
        productCraftType: productCraftType,
        requiredCraftType: requiredCraftType,
        productPrice: productPrice,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        artisanLocation: artisanLocation,
        requiredLocation: requiredLocation,
      );

      // Ignore completely unrelated products.
      if (matchScore <= 0) {
        continue;
      }

      candidates.add({
        'productId': productDocument.id,
        'artisanId': artisanId,
        'productName': product['name'],
        'description': product['description'],
        'category': productCategory,
        'craftType': productCraftType,
        'price': productPrice,
        'availableQuantity': availableQuantity,
        'artisanLocation': artisanLocation,
        'matchScore': matchScore,
      });
    }

    // ----------------------------------------------------------
    // 6. ALLOCATE QUANTITY USING MATCHING ENGINE
    // ----------------------------------------------------------

    return _engine.allocateQuantity(
      requirementId: requirementId,
      requiredQuantity: requiredQuantity,
      candidates: candidates,
    );
  }
}
