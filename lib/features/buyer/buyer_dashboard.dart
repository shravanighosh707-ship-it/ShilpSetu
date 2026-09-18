import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'explore_products_screen.dart';
import '../../services/buyer_profile_service.dart';
import 'buyer_profile_screen.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  final BuyerProfileService _profileService = BuyerProfileService();

  bool isLoading = true;
  bool profileExists = false;

  @override
  void initState() {
    super.initState();
    checkProfile();
  }

  Future<void> checkProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {
      final profile = await _profileService.getProfile(user.uid);

      if (!mounted) return;

      setState(() {
        profileExists = profile.exists;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void openProfile() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyerProfileScreen(uid: user.uid),
      ),
    ).then((_) {
      checkProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Buyer!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: openProfile,
                      child: Text(
                        profileExists
                            ? 'View / Edit Profile'
                            : 'Complete Profile',
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExploreProductsScreen(),
                          ),
                        );
                      },
                      child: const Text('Explore Products'),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // My Requirements will be added later.
                      },
                      child: const Text('My Requirements'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
