import 'package:flutter/material.dart';

import '../../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductService _productService = ProductService();

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController categoryController;
  late final TextEditingController craftTypeController;
  late final TextEditingController priceController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product['name'] ?? '');

    descriptionController = TextEditingController(
      text: widget.product['description'] ?? '',
    );

    categoryController = TextEditingController(
      text: widget.product['category'] ?? '',
    );

    craftTypeController = TextEditingController(
      text: widget.product['craftType'] ?? '',
    );

    priceController = TextEditingController(
      text: '${widget.product['price'] ?? ''}',
    );
  }

  Future<void> updateProduct() async {
    final price = double.tryParse(priceController.text.trim());

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _productService.updateProduct(
        productId: widget.product['id'],
        data: {
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
          'category': categoryController.text.trim(),
          'craftType': craftTypeController.text.trim(),
          'price': price,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update product: $e')));
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
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
      appBar: AppBar(title: const Text('Edit Product')),
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
                onPressed: isSaving ? null : updateProduct,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Update Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
