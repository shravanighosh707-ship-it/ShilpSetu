import 'package:flutter/material.dart';

import '../../services/buyer_profile_service.dart';

class BuyerProfileScreen extends StatefulWidget {
  final String uid;

  const BuyerProfileScreen({super.key, required this.uid});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final BuyerProfileService _profileService = BuyerProfileService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final organizationController = TextEditingController();
  final interestController = TextEditingController();
  final bioController = TextEditingController();

  String message = '';

  Future<void> saveProfile() async {
    try {
      await _profileService.createProfile(
        uid: widget.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        location: locationController.text.trim(),
        organization: organizationController.text.trim(),
        interest: interestController.text.trim(),
        bio: bioController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        message = 'Profile saved successfully!';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = 'Failed to save profile: $e';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    organizationController.dispose();
    interestController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: organizationController,
              decoration: const InputDecoration(
                labelText: 'Organization / Business',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: interestController,
              decoration: const InputDecoration(
                labelText: 'Product / Craft Interest',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bio',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save Profile'),
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
