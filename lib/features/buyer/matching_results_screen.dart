import 'package:flutter/material.dart';

import '../../services/matching_service.dart';

class MatchingResultsScreen extends StatefulWidget {
  final String requirementId;

  const MatchingResultsScreen({super.key, required this.requirementId});

  @override
  State<MatchingResultsScreen> createState() => _MatchingResultsScreenState();
}

class _MatchingResultsScreenState extends State<MatchingResultsScreen> {
  final MatchingService _matchingService = MatchingService();

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? result;

  static const Color navy = Color(0xFF051A37);
  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFF5E6C8);
  static const Color cardColor = Color(0xFF0B2547);

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    try {
      final matchingResult = await _matchingService.findMatches(
        requirementId: widget.requirementId,
      );

      if (!mounted) return;

      setState(() {
        result = matchingResult;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: cream),
        title: const Text(
          'Matching Results',
          style: TextStyle(color: cream, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : errorMessage != null
            ? _buildError()
            : _buildResults(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: gold, size: 55),
            const SizedBox(height: 18),
            const Text(
              'Unable to find matches',
              style: TextStyle(
                color: cream,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cream.withOpacity(0.65), fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadMatches();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navy,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final data = result ?? {};

    final int requiredQuantity =
        (data['requiredQuantity'] as num?)?.toInt() ?? 0;

    final int matchedQuantity = (data['matchedQuantity'] as num?)?.toInt() ?? 0;

    final int remainingQuantity =
        (data['remainingQuantity'] as num?)?.toInt() ?? 0;

    final bool fullyMatched = data['fullyMatched'] == true;

    final List<dynamic> matches = (data['matches'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Matches',
            style: TextStyle(
              color: cream,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Products that match your requirement.',
            style: TextStyle(color: cream.withOpacity(0.65), fontSize: 13),
          ),

          const SizedBox(height: 22),

          _buildSummaryCard(
            requiredQuantity: requiredQuantity,
            matchedQuantity: matchedQuantity,
            remainingQuantity: remainingQuantity,
            fullyMatched: fullyMatched,
          ),

          const SizedBox(height: 25),

          if (matches.isEmpty)
            _buildNoMatches()
          else
            ...matches.map(
              (match) =>
                  _buildMatchCard(Map<String, dynamic>.from(match as Map)),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required int requiredQuantity,
    required int matchedQuantity,
    required int remainingQuantity,
    required bool fullyMatched,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  fullyMatched
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: gold,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  fullyMatched
                      ? 'Requirement Fully Matched'
                      : 'Partial Match Found',
                  style: const TextStyle(
                    color: cream,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _summaryItem('Required', requiredQuantity.toString()),
              _summaryItem('Matched', matchedQuantity.toString()),
              _summaryItem('Remaining', remainingQuantity.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: gold,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: cream.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final String productName =
        match['productName']?.toString() ?? 'Unnamed Product';

    final String description = match['description']?.toString() ?? '';

    final String category = match['category']?.toString() ?? '';

    final String craftType = match['craftType']?.toString() ?? '';

    final String location = match['artisanLocation']?.toString() ?? 'Unknown';

    final double price = (match['price'] as num?)?.toDouble() ?? 0;

    final int availableQuantity =
        (match['availableQuantity'] as num?)?.toInt() ?? 0;

    final int allocatedQuantity =
        (match['allocatedQuantity'] as num?)?.toInt() ?? 0;

    final double matchScore = (match['matchScore'] as num?)?.toDouble() ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.handyman_outlined,
                  color: gold,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        color: cream,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$craftType • $category',
                      style: TextStyle(
                        color: cream.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${matchScore.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          if (description.isNotEmpty) ...[
            const SizedBox(height: 14),

            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cream.withOpacity(0.65),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 17),

          _detailRow(Icons.currency_rupee, 'Price', _formatNumber(price)),

          const SizedBox(height: 9),

          _detailRow(
            Icons.inventory_2_outlined,
            'Available',
            availableQuantity.toString(),
          ),

          const SizedBox(height: 9),

          _detailRow(
            Icons.shopping_cart_outlined,
            'Allocated for you',
            allocatedQuantity.toString(),
          ),

          const SizedBox(height: 9),

          _detailRow(
            Icons.location_on_outlined,
            'Artisan Location',
            location.isEmpty ? 'Not available' : location,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 18),

        const SizedBox(width: 8),

        Text(
          '$title:',
          style: TextStyle(color: cream.withOpacity(0.55), fontSize: 12),
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: cream,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoMatches() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, color: gold.withOpacity(0.8), size: 45),

          const SizedBox(height: 15),

          const Text(
            'No Matching Products',
            style: TextStyle(
              color: cream,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'We could not find products matching this requirement yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cream.withOpacity(0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
