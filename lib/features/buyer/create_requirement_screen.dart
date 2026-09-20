import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/requirement_service.dart';

class CreateRequirementScreen extends StatefulWidget {
  const CreateRequirementScreen({super.key});

  @override
  State<CreateRequirementScreen> createState() =>
      _CreateRequirementScreenState();
}

class _CreateRequirementScreenState extends State<CreateRequirementScreen> {
  final RequirementService _requirementService = RequirementService();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final craftTypeController = TextEditingController();
  final quantityController = TextEditingController();
  final budgetMinController = TextEditingController();
  final budgetMaxController = TextEditingController();
  final locationController = TextEditingController();

  bool isSaving = false;

  static const Color navy = Color(0xFF051A37);
  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFF5E6C8);
  static const Color cardColor = Color(0xFF0B2547);

  Future<void> submitRequirement() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty ||
        craftTypeController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        budgetMinController.text.trim().isEmpty ||
        budgetMaxController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      showMessage('Please fill all fields.');
      return;
    }

    final quantity = int.tryParse(quantityController.text.trim());
    final budgetMin = double.tryParse(budgetMinController.text.trim());
    final budgetMax = double.tryParse(budgetMaxController.text.trim());

    if (quantity == null || quantity <= 0) {
      showMessage('Please enter a valid quantity.');
      return;
    }

    if (budgetMin == null || budgetMin < 0) {
      showMessage('Please enter a valid minimum budget.');
      return;
    }

    if (budgetMax == null || budgetMax < 0) {
      showMessage('Please enter a valid maximum budget.');
      return;
    }

    if (budgetMax < budgetMin) {
      showMessage('Maximum budget cannot be less than minimum budget.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login again.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _requirementService.createRequirement(
        buyerId: user.uid,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: categoryController.text.trim(),
        craftType: craftTypeController.text.trim(),
        quantity: quantity,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        location: locationController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Requirement posted successfully!'),
          backgroundColor: gold,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage('Failed to post requirement.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: cream.withOpacity(0.65)),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: cardColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: gold.withOpacity(0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: gold, width: 1.3),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    craftTypeController.dispose();
    quantityController.dispose();
    budgetMinController.dispose();
    budgetMaxController.dispose();
    locationController.dispose();

    super.dispose();
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
          'Post Requirement',
          style: TextStyle(color: cream, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us what you need',
                style: TextStyle(
                  color: cream,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Share your requirements and connect with suitable artisans.',
                style: TextStyle(color: cream.withOpacity(0.65), fontSize: 13),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: titleController,
                style: const TextStyle(color: cream),
                decoration: inputDecoration(
                  label: 'Requirement Title',
                  icon: Icons.title,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: descriptionController,
                style: const TextStyle(color: cream),
                maxLines: 4,
                decoration: inputDecoration(
                  label: 'Description',
                  icon: Icons.description_outlined,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: categoryController,
                style: const TextStyle(color: cream),
                decoration: inputDecoration(
                  label: 'Category',
                  icon: Icons.category_outlined,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: craftTypeController,
                style: const TextStyle(color: cream),
                decoration: inputDecoration(
                  label: 'Craft Type',
                  icon: Icons.handyman_outlined,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: quantityController,
                style: const TextStyle(color: cream),
                keyboardType: TextInputType.number,
                decoration: inputDecoration(
                  label: 'Quantity',
                  icon: Icons.numbers,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: budgetMinController,
                      style: const TextStyle(color: cream),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: inputDecoration(
                        label: 'Min Budget',
                        icon: Icons.currency_rupee,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextField(
                      controller: budgetMaxController,
                      style: const TextStyle(color: cream),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: inputDecoration(
                        label: 'Max Budget',
                        icon: Icons.currency_rupee,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              TextField(
                controller: locationController,
                style: const TextStyle(color: cream),
                decoration: inputDecoration(
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : submitRequirement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: navy,
                    disabledBackgroundColor: gold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: navy,
                          ),
                        )
                      : const Text(
                          'Post Requirement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
