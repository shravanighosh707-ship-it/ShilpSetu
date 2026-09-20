import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  static const Color navy = Color(0xFF051A37);
  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFF5E6C8);
  static const Color cardColor = Color(0xFF0B2547);

  @override
  Widget build(BuildContext context) {
    final String name = product['name']?.toString() ?? 'Unnamed Product';

    final String description =
        product['description']?.toString() ?? 'No description available.';

    final String category = product['category']?.toString() ?? 'No category';

    final String craftType =
        product['craftType']?.toString() ?? 'No craft type';

    final double price = (product['price'] as num?)?.toDouble() ?? 0;

    final int availableQuantity =
        (product['availableQuantity'] as num?)?.toInt() ?? 0;

    final String imageUrl = product['imageUrl']?.toString() ?? '';

    final String artisanId = product['artisanId']?.toString() ?? '';

    return Scaffold(
      backgroundColor: navy,

      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: cream),
        title: const Text(
          'Product Details',
          style: TextStyle(color: cream, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              _buildProductImage(imageUrl),

              const SizedBox(height: 24),

              // Product name
              Text(
                name,
                style: const TextStyle(
                  color: cream,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // Category + craft type
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _infoChip(Icons.category_outlined, category),
                  _infoChip(Icons.handyman_outlined, craftType),
                ],
              ),

              const SizedBox(height: 22),

              // Price card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: gold.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.currency_rupee,
                        color: gold,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            color: cream.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '₹${_formatNumber(price)}',
                          style: const TextStyle(
                            color: cream,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Available',
                          style: TextStyle(
                            color: cream.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$availableQuantity',
                          style: const TextStyle(
                            color: gold,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description
              _sectionTitle(
                icon: Icons.description_outlined,
                title: 'About this Product',
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: gold.withOpacity(0.15)),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    color: cream.withOpacity(0.72),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Craft information
              _sectionTitle(
                icon: Icons.auto_awesome_outlined,
                title: 'Craft Information',
              ),

              const SizedBox(height: 12),

              _detailCard(
                icon: Icons.category_outlined,
                title: 'Category',
                value: category,
              ),

              const SizedBox(height: 10),

              _detailCard(
                icon: Icons.handyman_outlined,
                title: 'Craft Type',
                value: craftType,
              ),

              const SizedBox(height: 10),

              _detailCard(
                icon: Icons.inventory_2_outlined,
                title: 'Available Quantity',
                value: availableQuantity.toString(),
              ),

              const SizedBox(height: 24),

              // Artisan section
              _sectionTitle(icon: Icons.person_outline, title: 'Artisan'),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withOpacity(0.18)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: gold,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ShilpSetu Artisan',
                            style: TextStyle(
                              color: cream,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crafting unique handmade products',
                            style: TextStyle(
                              color: cream.withOpacity(0.6),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Keep the ID hidden from normal users, but retain
              // it for future artisan/contact integration.
              if (artisanId.isNotEmpty)
                Text(
                  'Product listed by a verified ShilpSetu artisan',
                  style: TextStyle(
                    color: cream.withOpacity(0.45),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: gold.withOpacity(0.2)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: gold, size: 60),
            SizedBox(height: 10),
            Text(
              'No product image',
              style: TextStyle(color: cream, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: 280,
        color: cardColor,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image_outlined, color: gold, size: 60),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(child: CircularProgressIndicator(color: gold));
          },
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: gold.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: cream.withOpacity(0.8), fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 21),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: cream,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 21),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(color: cream.withOpacity(0.6), fontSize: 12),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: cream,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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
