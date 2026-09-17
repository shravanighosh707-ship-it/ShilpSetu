import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductService _productService = ProductService();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final craftTypeController = TextEditingController();
  final priceController = TextEditingController();

  String message = '';

  Future<void> saveProduct() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not logged in');
      }

      final price = double.tryParse(priceController.text.trim());

      if (price == null) {
        throw Exception('Please enter a valid price');
      }

      await _productService.addProduct(
        artisanId: user.uid,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        category: categoryController.text.trim(),
        craftType: craftTypeController.text.trim(),
        price: price,
      );

      if (!mounted) return;

      setState(() {
        message = 'Product added successfully!';
      });

      nameController.clear();
      descriptionController.clear();
      categoryController.clear();
      craftTypeController.clear();
      priceController.clear();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = 'Failed to add product: $e';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    craftTypeController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: craftTypeController,
              decoration: const InputDecoration(labelText: 'Craft Type'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '₹ ',
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProduct,
                child: const Text('Add Product'),
              ),
            ),

            const SizedBox(height: 20),

            Text(message),
          ],
        ),
      ),
    );
  }
}
