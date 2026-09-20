import 'package:flutter/material.dart';

import '../../services/artisan_profile_service.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final String uid;

  const ArtisanProfileScreen({super.key, required this.uid});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  static const Color navy = Color(0xFF03213A);
  static const Color gold = Color(0xFFD1AA5B);
  static const Color cream = Color(0xFFF1E6CF);
  static const Color fieldColor = Color(0xFF0B2D4A);

  final ArtisanProfileService _profileService = ArtisanProfileService();

  bool isLoading = true;
  bool isSaving = false;
  bool profileExists = false;

  String message = '';
  bool saveSuccess = false;

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

  Future<void> saveProfile() async {
    FocusScope.of(context).unfocus();

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        craftController.text.trim().isEmpty) {
      setState(() {
        saveSuccess = false;
        message = 'Please fill in all required fields.';
      });
      return;
    }

    setState(() {
      isSaving = true;
      message = '';
    });

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
        isSaving = false;
        saveSuccess = true;
        message = 'Profile saved successfully!';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
        saveSuccess = false;
        message = 'Failed to save profile. Please try again.';
      });
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = false,
  }) {
    return InputDecoration(
      labelText: requiredField ? '$label *' : label,
      hintText: hint,
      prefixIcon: Icon(icon, color: gold, size: 21),
      labelStyle: const TextStyle(color: cream, fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: gold,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
    );
  }

  Widget _profileField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int maxLines = 1,
    bool requiredField = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      style: const TextStyle(color: cream, fontSize: 15),
      cursorColor: gold,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
        requiredField: requiredField,
      ),
    );
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
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: cream,
        elevation: 0,
        title: const Text(
          'Artisan Profile',
          style: TextStyle(color: cream, fontWeight: FontWeight.w600),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile header
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: gold.withValues(alpha: 0.10),
                          border: Border.all(color: gold, width: 2),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: gold,
                          size: 48,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Your Artisan Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cream,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Showcase your skills and craftsmanship',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),

                    const SizedBox(height: 28),

                    // Personal information
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        color: gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _profileField(
                      controller: nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      requiredField: true,
                    ),

                    const SizedBox(height: 16),

                    _profileField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      requiredField: true,
                    ),

                    const SizedBox(height: 16),

                    _profileField(
                      controller: phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      requiredField: true,
                    ),

                    const SizedBox(height: 16),

                    _profileField(
                      controller: locationController,
                      label: 'Location',
                      hint: 'City, State',
                      icon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.next,
                      requiredField: true,
                    ),

                    const SizedBox(height: 28),

                    // Craft information
                    const Text(
                      'Craft & Experience',
                      style: TextStyle(
                        color: gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _profileField(
                      controller: craftController,
                      label: 'Craft / Skill',
                      hint: 'e.g. Pottery, Handloom, Woodcraft',
                      icon: Icons.handyman_outlined,
                      textInputAction: TextInputAction.next,
                      requiredField: true,
                    ),

                    const SizedBox(height: 16),

                    _profileField(
                      controller: experienceController,
                      label: 'Experience',
                      hint: 'e.g. 5 years',
                      icon: Icons.workspace_premium_outlined,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    _profileField(
                      controller: bioController,
                      label: 'About Your Craft',
                      hint: 'Tell buyers about your craft and skills',
                      icon: Icons.description_outlined,
                      maxLines: 5,
                    ),

                    const SizedBox(height: 22),

                    if (message.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: saveSuccess
                              ? Colors.greenAccent.withValues(alpha: 0.08)
                              : Colors.redAccent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: saveSuccess
                                ? Colors.greenAccent.withValues(alpha: 0.30)
                                : Colors.redAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              saveSuccess
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: saveSuccess
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              size: 19,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: saveSuccess
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 22),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: navy,
                          disabledBackgroundColor: gold.withValues(alpha: 0.55),
                          disabledForegroundColor: navy.withValues(alpha: 0.6),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: navy,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_outlined, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Save Profile',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
