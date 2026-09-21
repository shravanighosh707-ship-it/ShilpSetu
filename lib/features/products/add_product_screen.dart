import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/smart_pricing_service.dart';
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
  final AIProductService _aiProductService = AIProductService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ProductService _productService = ProductService();
  final SmartPricingService _smartPricingService = SmartPricingService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _craftTypeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  File? _selectedImage;
  bool _isProcessing = false;
  Map<String, dynamic>? _pricingResult;
  bool _isPricing = false;

  static const Color navy = Color(0xFF051A37);
  static const Color cardColor = Color(0xFF0B2A50);
  static const Color gold = Color(0xFFD4AF6A);
  static const Color cream = Color(0xFFF4E8D0);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _craftTypeController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> _generateCatalog() async {
    if (_selectedImage == null) {
      _showMessage('Please select a product image first.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _isPricing = true;
      _pricingResult = null;
    });
    try {
      final catalog = await _aiProductService.generateProductCatalog(
        _selectedImage!,
      );

      if (!mounted) return;

      setState(() {
        _nameController.text = catalog['suggestedName']?.toString() ?? '';

        _descriptionController.text =
            catalog['suggestedDescription']?.toString() ?? '';

        _categoryController.text =
            catalog['suggestedCategory']?.toString() ?? '';

        _craftTypeController.text =
            catalog['suggestedCraftType']?.toString() ?? '';
      });

      _showMessage('AI catalog generated successfully!');
    } catch (e) {
      if (!mounted) return;

      _showMessage('AI catalog generation failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _generateSmartPrice() async {
    if (_nameController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _craftTypeController.text.trim().isEmpty) {
      _showMessage(
        'Please generate or enter the product name, category, and craft type first.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final pricing = await _smartPricingService.generateSmartPrice(
        productName: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        craftType: _craftTypeController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      final suggestedPrice = pricing['suggestedPrice'];

      setState(() {
        _pricingResult = pricing;
        _isPricing = false;
        _isProcessing = false;
      });

      if (suggestedPrice != null) {
        _priceController.text = suggestedPrice.toString();
      }

      _showMessage('AI suggested price: ₹${suggestedPrice ?? 'N/A'}');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showMessage('Smart pricing failed: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Please enter a product name.');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showMessage('Please enter a description.');
      return;
    }

    if (_categoryController.text.trim().isEmpty) {
      _showMessage('Please enter a category.');
      return;
    }

    if (_craftTypeController.text.trim().isEmpty) {
      _showMessage('Please enter a craft type.');
      return;
    }

    final double? price = double.tryParse(_priceController.text.trim());

    if (price == null || price < 0) {
      _showMessage('Please enter a valid price.');
      return;
    }

    final int? quantity = int.tryParse(_quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      _showMessage('Please enter a valid available quantity.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please login again.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      String? imageUrl;
      String? imagePublicId;

      // Upload image if one was selected.
      if (_selectedImage != null) {
        final uploadResult = await _cloudinaryService.uploadProductImage(
          _selectedImage!,
        );

        imageUrl = uploadResult['secure_url']?.toString();
        imagePublicId = uploadResult['public_id']?.toString();
      }

      await _productService.addProduct(
        artisanId: user.uid,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        craftType: _craftTypeController.text.trim(),
        price: price,
        availableQuantity: quantity,
        imageUrl: imageUrl,
        imagePublicId: imagePublicId,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
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
        _isProcessing = false;
      });

      _showMessage('Failed to save product: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
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
        borderSide: BorderSide(color: gold.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gold, width: 1.5),
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

            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withOpacity(0.4)),
                ),
                child: _selectedImage == null
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
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // AI button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _generateCatalog,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _isProcessing
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
              controller: _nameController,
              style: const TextStyle(color: cream),
              decoration: _inputDecoration(
                'Product Name',
                Icons.inventory_2_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: cream),
              maxLines: 4,
              decoration: _inputDecoration(
                'Description',
                Icons.description_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _categoryController,
              style: const TextStyle(color: cream),
              decoration: _inputDecoration('Category', Icons.category_outlined),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _craftTypeController,
              style: const TextStyle(color: cream),
              decoration: _inputDecoration(
                'Craft Type',
                Icons.handyman_outlined,
              ),
            ),

            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _priceController,
                  style: const TextStyle(color: cream),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    'Price',
                    Icons.currency_rupee_rounded,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _generateSmartPrice,
                    icon: const Icon(Icons.auto_awesome, color: gold),
                    label: const Text(
                      '✨ AI Smart Price',
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: gold.withOpacity(0.6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_isPricing)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: CircularProgressIndicator(color: gold)),
              ),

            if (_pricingResult != null) ...[
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: gold.withOpacity(0.55)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: gold),
                        SizedBox(width: 8),
                        Text(
                          'AI Smart Pricing',
                          style: TextStyle(
                            color: cream,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Suggested Price',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '₹${_pricingResult!['suggestedPrice'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Recommended range: '
                      '₹${_pricingResult!['minimumPrice'] ?? 'N/A'}'
                      ' – '
                      '₹${_pricingResult!['maximumPrice'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      _pricingResult!['reason']?.toString() ?? 'AI generated this estimate based on the product information.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final suggestedPrice =
                              _pricingResult!['suggestedPrice'];

                          if (suggestedPrice != null) {
                            _priceController.text = suggestedPrice.toString();
                          }

                          _showMessage('Suggested price applied.');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: gold,
                          side: BorderSide(color: gold.withOpacity(0.6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Use This Price',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            TextField(
              controller: _quantityController,
              style: const TextStyle(color: cream),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Available Quantity',
                Icons.inventory_outlined,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
