import 'package:flutter/material.dart';

import '../../services/product_service.dart';
import '../artisan/product_details_screen.dart';

class ExploreProductsScreen extends StatefulWidget {
  const ExploreProductsScreen({super.key});

  @override
  State<ExploreProductsScreen> createState() => _ExploreProductsScreenState();
}

class _ExploreProductsScreenState extends State<ExploreProductsScreen> {
  static const Color navy = Color(0xFF03213A);
  static const Color gold = Color(0xFFD1AA5B);
  static const Color cream = Color(0xFFF1E6CF);
  static const Color fieldColor = Color(0xFF0B2D4A);

  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
    _searchController.addListener(_filterProducts);
  }

  Future<void> loadProducts() async {
    try {
      final snapshot = await _productService.getAllProducts();

      final loadedProducts = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        filteredProducts = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load products. Please try again.'),
        ),
      );
    }
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
        return;
      }

      filteredProducts = products.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        final category = (product['category'] ?? '').toString().toLowerCase();
        final craftType = (product['craftType'] ?? '').toString().toLowerCase();
        final description = (product['description'] ?? '')
            .toString()
            .toLowerCase();

        return name.contains(query) ||
            category.contains(query) ||
            craftType.contains(query) ||
            description.contains(query);
      }).toList();
    });
  }

  void _openProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
    final imageUrl = product['imageUrl']?.toString();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: Image.network(
          imageUrl,
          height: 170,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _imagePlaceholder();
          },
        ),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: const Center(
        child: Icon(Icons.handyman_outlined, color: gold, size: 54),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name']?.toString().trim().isNotEmpty == true
        ? product['name'].toString()
        : 'Unnamed Product';

    final category = product['category']?.toString() ?? 'Handicraft';
    final craftType = product['craftType']?.toString() ?? '';
    final description = product['description']?.toString() ?? '';

    final price = product['price'];
    final quantity = product['availableQuantity'];

    final double productPrice = price is num
        ? price.toDouble()
        : double.tryParse(price?.toString() ?? '') ?? 0;

    final int availableQuantity = quantity is num
        ? quantity.toInt()
        : int.tryParse(quantity?.toString() ?? '') ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      color: fieldColor,
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openProduct(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: cream,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _buildTag(category, Icons.category_outlined),
                      if (craftType.isNotEmpty)
                        _buildTag(craftType, Icons.handyman_outlined),
                    ],
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Text(
                        '₹${productPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: gold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      if (availableQuantity > 0)
                        Text(
                          '$availableQuantity available',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        const Text(
                          'Out of stock',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      const SizedBox(width: 8),

                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: gold,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: cream,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withValues(alpha: 0.08),
                border: Border.all(color: gold.withValues(alpha: 0.35)),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: gold,
                size: 44,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isSearching ? 'No matching products' : 'No products available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: cream,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isSearching
                  ? 'Try searching for another craft or product.'
                  : 'Products from artisans will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: cream,
        elevation: 0,
        title: const Text(
          'Explore Products',
          style: TextStyle(color: cream, fontWeight: FontWeight.w600),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: cream, fontSize: 14),
                    cursorColor: gold,
                    decoration: InputDecoration(
                      hintText: 'Search products, crafts or categories...',
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: gold),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white60,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: fieldColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: gold, width: 1.5),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        '${filteredProducts.length} '
                        '${filteredProducts.length == 1 ? 'product' : 'products'}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.swipe_down_rounded,
                        color: Colors.white38,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Pull to refresh',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: gold,
                          backgroundColor: fieldColor,
                          onRefresh: loadProducts,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(filteredProducts[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
