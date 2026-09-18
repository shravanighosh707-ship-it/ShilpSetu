import 'package:flutter/material.dart';

import '../../services/product_service.dart';
import '../artisan/product_details_screen.dart';

class ExploreProductsScreen extends StatefulWidget {
  const ExploreProductsScreen({super.key});

  @override
  State<ExploreProductsScreen> createState() => _ExploreProductsScreenState();
}

class _ExploreProductsScreenState extends State<ExploreProductsScreen> {
  final ProductService _productService = ProductService();

  bool isLoading = true;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
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
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Products')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(
              child: Text(
                'No products available yet.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadProducts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      title: Text(
                        product['name'] ?? 'Unnamed Product',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${product['category'] ?? 'No category'}\n'
                        '₹ ${product['price'] ?? 0}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
