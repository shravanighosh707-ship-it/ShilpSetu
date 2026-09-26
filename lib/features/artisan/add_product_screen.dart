import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/ai_product_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImagePicker _picker = ImagePicker();

  final ProductService _productService = ProductService();
  final AIProductService _aiProductService = AIProductService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final craftTypeController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  XFile? selectedImage;

  bool isProcessing = false;
  String message = '';

  static const Color navy = Color(0xFF051A37);
  static const Color cardColor = Color(0xFF0B2A50);
  static const Color gold = Color(0xFFD4AF6A);
  static const Color cream = Color(0xFFF4E8D0);

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      selectedImage = image;
    });
  }

  Future<void> generateCatalog() async {
    if (selectedImage == null) {
      showMessage('Please select a product image first.');
      return;
    }

    setState(() {
      isProcessing = true;
      message = '';
    });

    try {
      final catalog = await _aiProductService.generateProductCatalog(
        selectedImage!,
      );

      if (!mounted) return;

      setState(() {
        nameController.text = catalog['suggestedName']?.toString() ?? '';

        descriptionController.text =
            catalog['suggestedDescription']?.toString() ?? '';

        categoryController.text =
            catalog['suggestedCategory']?.toString() ?? '';

        craftTypeController.text =
            catalog['suggestedCraftType']?.toString() ?? '';

        isProcessing = false;
      });

      showMessage('AI catalog generated successfully!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      showMessage('AI catalog generation failed: $e');
    }
  }

  Future<void> saveProduct() async {
    if (nameController.text.trim().isEmpty) {
      showMessage('Please enter a product name.');
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      showMessage('Please enter a description.');
      return;
    }

    if (categoryController.text.trim().isEmpty) {
      showMessage('Please enter a category.');
      return;
    }

    if (craftTypeController.text.trim().isEmpty) {
      showMessage('Please enter a craft type.');
      return;
    }

    final double? price = double.tryParse(priceController.text.trim());

    if (price == null || price < 0) {
      showMessage('Please enter a valid price.');
      return;
    }

    final int? quantity = int.tryParse(quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      showMessage('Please enter a valid available quantity.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login again.');
      return;
    }

    setState(() {
      isProcessing = true;
      message = '';
    });

    try {
      String? imageUrl;
      String? imagePublicId;

      if (selectedImage != null) {
        final uploadResult = await _cloudinaryService.uploadProductImage(
          selectedImage!,
        );

        imageUrl = uploadResult['secure_url']?.toString();
        imagePublicId = uploadResult['public_id']?.toString();
      }

      await _productService.addProduct(
        artisanId: user.uid,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        category: categoryController.text.trim(),
        craftType: craftTypeController.text.trim(),
        price: price,
        availableQuantity: quantity,
        imageUrl: imageUrl,
        imagePublicId: imagePublicId,
      );

      if (!mounted) return;

      setState(() {
        isProcessing = false;
        message = 'Product added successfully!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: gold,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
        message = 'Failed to add product: $e';
      });
    }
  }

  void showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: gold.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    craftTypeController.dispose();
    priceController.dispose();
    quantityController.dispose();
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
          'Add Your Craft',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Product',
              style: TextStyle(
                color: cream,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your handmade product and let AI help create its catalog.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Product image
            GestureDetector(
              onTap: isProcessing ? null : pickImage,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withValues(alpha: 0.4)),
                ),
                child: selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            color: gold,
                            size: 50,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tap to select product image',
                            style: TextStyle(
                              color: cream,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Choose an image from your gallery',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FutureBuilder<Uint8List>(
                          future: selectedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              );
                            }

                            return Image.memory(
                              snapshot.data!,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // AI catalog
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : generateCatalog,
                icon: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  isProcessing
                      ? 'Generating Catalog...'
                      : 'Generate Catalog with AI',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              style: const TextStyle(color: cream),
              decoration: inputDecoration(
                'Product Name',
                Icons.inventory_2_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              style: const TextStyle(color: cream),
              maxLines: 4,
              decoration: inputDecoration(
                'Description',
                Icons.description_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: categoryController,
              style: const TextStyle(color: cream),
              decoration: inputDecoration('Category', Icons.category_outlined),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: craftTypeController,
              style: const TextStyle(color: cream),
              decoration: inputDecoration(
                'Craft Type',
                Icons.handyman_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: priceController,
              style: const TextStyle(color: cream),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: inputDecoration(
                'Price',
                Icons.currency_rupee_rounded,
              ),
            ),

            const SizedBox(height: 16),

            // Available quantity
            TextField(
              controller: quantityController,
              style: const TextStyle(color: cream),
              keyboardType: TextInputType.number,
              decoration: inputDecoration(
                'Available Quantity',
                Icons.inventory_outlined,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isProcessing ? null : saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: navy,
                  disabledBackgroundColor: gold.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: navy,
                        ),
                      )
                    : const Text(
                        'Save Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            if (message.isNotEmpty)
              Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: cream),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
