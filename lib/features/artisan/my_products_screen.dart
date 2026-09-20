import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/product_service.dart';
import 'edit_product_screen.dart';
import 'product_details_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  static const Color navy = Color(0xFF03213A);
  static const Color gold = Color(0xFFD1AA5B);
  static const Color cream = Color(0xFFF1E6CF);
  static const Color fieldColor = Color(0xFF0B2D4A);

  final ProductService _productService = ProductService();

  bool isLoading = true;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {
      final snapshot = await _productService.getArtisanProducts(user.uid);

      final loadedProducts = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load your products.')),
      );
    }
  }

  Future<void> deleteProduct(String productId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: fieldColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete Product?',
            style: TextStyle(color: cream, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This product will be permanently removed from your catalog.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _productService.deleteProduct(productId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );

      await loadProducts();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete product. Please try again.'),
        ),
      );
    }
  }

  void _openProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  Future<void> _editProduct(Map<String, dynamic> product) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    if (updated == true) {
      await loadProducts();
    }
  }

  Widget _buildImage(Map<String, dynamic> product) {
    final imageUrl = product['imageUrl']?.toString();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: Image.network(
          imageUrl,
          height: 165,
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
      height: 165,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: const Center(
        child: Icon(Icons.handyman_outlined, color: gold, size: 52),
      ),
    );
  }

  Widget _tag(String text, IconData icon) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openProduct(product),
            child: _buildImage(product),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
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
                    _tag(category, Icons.category_outlined),
                    if (craftType.isNotEmpty)
                      _tag(craftType, Icons.handyman_outlined),
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

                const SizedBox(height: 14),

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
                    Text(
                      '$availableQuantity available',
                      style: TextStyle(
                        color: availableQuantity > 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _editProduct(product),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: gold,
                      size: 18,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(height: 28, width: 1, color: Colors.white12),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => deleteProduct(product['id']),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withValues(alpha: 0.08),
                border: Border.all(color: gold.withValues(alpha: 0.35)),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: gold,
                size: 46,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Products Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cream,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your products will appear here after you add them to your catalog.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: cream,
        elevation: 0,
        title: const Text(
          'My Products',
          style: TextStyle(color: cream, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!isLoading && products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${products.length}',
                  style: const TextStyle(
                    color: gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : products.isEmpty
          ? RefreshIndicator(
              color: gold,
              backgroundColor: fieldColor,
              onRefresh: loadProducts,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: _buildEmptyState(),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: gold,
              backgroundColor: fieldColor,
              onRefresh: loadProducts,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index]);
                },
              ),
            ),
    );
  }
}
