class MatchingEngine {
  /// Calculates the match score for a product against a buyer requirement.
  ///
  /// Score:
  /// Category   = 30
  /// Craft type = 30
  /// Budget     = 25
  /// Location   = 15
  ///
  /// Maximum = 100
  double calculateMatchScore({
    required String productCategory,
    required String requiredCategory,
    required String productCraftType,
    required String requiredCraftType,
    required double productPrice,
    required double budgetMin,
    required double budgetMax,
    required String artisanLocation,
    required String requiredLocation,
  }) {
    double score = 0;

    if (_matches(productCategory, requiredCategory)) {
      score += 30;
    }

    if (_matches(productCraftType, requiredCraftType)) {
      score += 30;
    }

    score += _calculateBudgetScore(
      productPrice: productPrice,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
    );

    if (_matches(artisanLocation, requiredLocation)) {
      score += 15;
    }

    return score;
  }

  /// Selects products from multiple artisans and allocates the
  /// required quantity across them.
  ///
  /// Candidates must already contain a `matchScore` and
  /// `availableQuantity`.
  Map<String, dynamic> allocateQuantity({
    required String requirementId,
    required int requiredQuantity,
    required List<Map<String, dynamic>> candidates,
  }) {
    if (requiredQuantity <= 0) {
      throw Exception('Requirement quantity must be greater than zero.');
    }

    final sortedCandidates = List<Map<String, dynamic>>.from(candidates);

    // Highest scoring candidates are considered first.
    sortedCandidates.sort(
      (a, b) =>
          (b['matchScore'] as double).compareTo(a['matchScore'] as double),
    );

    final List<Map<String, dynamic>> matches = [];

    int remainingQuantity = requiredQuantity;

    for (final candidate in sortedCandidates) {
      if (remainingQuantity <= 0) {
        break;
      }

      final int availableQuantity =
          (candidate['availableQuantity'] as num?)?.toInt() ?? 0;

      if (availableQuantity <= 0) {
        continue;
      }

      final int allocatedQuantity = availableQuantity < remainingQuantity
          ? availableQuantity
          : remainingQuantity;

      if (allocatedQuantity <= 0) {
        continue;
      }

      matches.add({...candidate, 'allocatedQuantity': allocatedQuantity});

      remainingQuantity -= allocatedQuantity;
    }

    final int matchedQuantity = requiredQuantity - remainingQuantity;

    return {
      'requirementId': requirementId,
      'requiredQuantity': requiredQuantity,
      'matchedQuantity': matchedQuantity,
      'remainingQuantity': remainingQuantity,
      'fullyMatched': remainingQuantity == 0,
      'matches': matches,
    };
  }

  double _calculateBudgetScore({
    required double productPrice,
    required double budgetMin,
    required double budgetMax,
  }) {
    if (budgetMax < budgetMin || budgetMax <= 0) {
      return 0;
    }

    // Product is inside the buyer's budget.
    if (productPrice >= budgetMin && productPrice <= budgetMax) {
      return 25;
    }

    // Product is below the requested budget.
    if (productPrice < budgetMin) {
      if (budgetMin == 0) {
        return 0;
      }

      final double percentageDifference =
          (budgetMin - productPrice) / budgetMin;

      if (percentageDifference <= 0.10) {
        return 20;
      }

      if (percentageDifference <= 0.25) {
        return 15;
      }

      if (percentageDifference <= 0.50) {
        return 8;
      }

      return 0;
    }

    // Product is above the requested budget.
    final double percentageDifference = (productPrice - budgetMax) / budgetMax;

    if (percentageDifference <= 0.10) {
      return 20;
    }

    if (percentageDifference <= 0.25) {
      return 15;
    }

    if (percentageDifference <= 0.50) {
      return 8;
    }

    return 0;
  }

  bool _matches(String value1, String value2) {
    if (value1.trim().isEmpty || value2.trim().isEmpty) {
      return false;
    }

    return value1.trim().toLowerCase() == value2.trim().toLowerCase();
  }
}
