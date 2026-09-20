import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import 'my_requirements_screen.dart';
import 'create_requirement_screen.dart';
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

  // ShilpSetu theme
  static const Color navy = Color(0xFF051A37);
  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFF5E6C8);
  static const Color cardColor = Color(0xFF0B2547);

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

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(color: cream, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to logout from ShilpSetu?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void openExploreProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExploreProductsScreen()),
    );
  }

  void showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon'),
        backgroundColor: gold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 165,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: gold, size: 25),
              ),
              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: cream,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cream.withOpacity(0.65),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: gold.withOpacity(0.18)),
          ),
          child: Column(
            children: [
              Icon(icon, color: gold, size: 24),
              const SizedBox(height: 7),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: cream,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,

      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'ShilpSetu',
          style: TextStyle(
            color: gold,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: openProfile,
            tooltip: 'Profile',
            icon: const Icon(
              Icons.account_circle_outlined,
              color: cream,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: gold, size: 24),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Buyer! 👋',
                      style: TextStyle(
                        color: cream,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Discover unique crafts and connect with artisans.',
                      style: TextStyle(
                        color: cream.withOpacity(0.68),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Main feature cards
                    Row(
                      children: [
                        dashboardCard(
                          icon: Icons.explore_outlined,
                          title: 'Explore Crafts',
                          subtitle: 'Discover unique handmade products.',
                          onTap: openExploreProducts,
                        ),

                        const SizedBox(width: 14),

                        dashboardCard(
                          icon: Icons.people_outline,
                          title: 'Find Artisans',
                          subtitle: 'Discover skilled artisans and makers.',
                          onTap: () {
                            showComingSoon('Find Artisans');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        dashboardCard(
                          icon: Icons.assignment_outlined,
                          title: 'Post Requirement',
                          subtitle: 'Tell artisans what you are looking for.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateRequirementScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 14),

                        dashboardCard(
                          icon: Icons.list_alt_outlined,
                          title: 'My Requirements',
                          subtitle: 'View and manage your requirements.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MyRequirementsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Manage Your Account',
                      style: TextStyle(
                        color: cream,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        bottomAction(
                          icon: Icons.person_outline,
                          title: profileExists
                              ? 'View / Edit Profile'
                              : 'Complete Profile',
                          onTap: openProfile,
                        ),

                        const SizedBox(width: 12),

                        bottomAction(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Explore Products',
                          onTap: openExploreProducts,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Information card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [cardColor, navy]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: gold.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: gold.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.search, color: gold),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Discover something unique',
                                  style: TextStyle(
                                    color: cream,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Explore handcrafted products and discover the people behind the craft.',
                                  style: TextStyle(
                                    color: cream.withOpacity(0.6),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
