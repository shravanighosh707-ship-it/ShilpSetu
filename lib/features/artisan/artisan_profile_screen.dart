import 'package:flutter/material.dart';

import '../../services/artisan_profile_service.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final String uid;

  const ArtisanProfileScreen({super.key, required this.uid});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  final ArtisanProfileService _profileService = ArtisanProfileService();

  bool isLoading = true;
  bool profileExists = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final craftController = TextEditingController();
  final experienceController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _profileService.getProfile(widget.uid);

      if (profile.exists) {
        final data = profile.data();

        if (data != null) {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          locationController.text = data['location'] ?? '';
          craftController.text = data['craft'] ?? '';
          experienceController.text = data['experience'] ?? '';
          bioController.text = data['bio'] ?? '';
        }

        profileExists = true;
      }
    } catch (e) {
      message = 'Failed to load profile: $e';
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  String message = '';
  Future<void> saveProfile() async {
    try {
      if (profileExists) {
        await _profileService.updateProfile(
          uid: widget.uid,
          data: {
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'location': locationController.text.trim(),
            'craft': craftController.text.trim(),
            'experience': experienceController.text.trim(),
            'bio': bioController.text.trim(),
          },
        );
      } else {
        await _profileService.createProfile(
          uid: widget.uid,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          location: locationController.text.trim(),
          craft: craftController.text.trim(),
          experience: experienceController.text.trim(),
          bio: bioController.text.trim(),
        );

        profileExists = true;
      }

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
    craftController.dispose();
    experienceController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artisan Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: craftController,
                    decoration: const InputDecoration(
                      labelText: 'Craft / Skill',
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: experienceController,
                    decoration: const InputDecoration(labelText: 'Experience'),
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
