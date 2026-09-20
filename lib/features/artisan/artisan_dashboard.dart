import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/artisan_profile_service.dart';
import 'add_product_screen.dart';
import 'artisan_profile_screen.dart';
import 'my_products_screen.dart';

class ArtisanDashboard extends StatefulWidget {
  const ArtisanDashboard({super.key});

  @override
  State<ArtisanDashboard> createState() => _ArtisanDashboardState();
}

class _ArtisanDashboardState extends State<ArtisanDashboard> {
  final ArtisanProfileService _profileService = ArtisanProfileService();

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
        builder: (context) => ArtisanProfileScreen(uid: user.uid),
      ),
    );
  }

  void openAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  void openMyProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyProductsScreen()),
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
          height: 155,
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

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  color: cream,
                  fontSize: 17,
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
            icon: const Icon(
              Icons.account_circle_outlined,
              color: cream,
              size: 28,
            ),
          ),
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
                    // Header
                    const Text(
                      'Welcome, Artisan! 👋',
                      style: TextStyle(
                        color: cream,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Turn your craftsmanship into opportunities.',
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
                          icon: Icons.handyman_outlined,
                          title: 'Add Your Craft',
                          subtitle: 'Showcase your handmade products.',
                          onTap: openAddProduct,
                        ),

                        const SizedBox(width: 14),

                        dashboardCard(
                          icon: Icons.auto_awesome,
                          title: 'AI Cataloging',
                          subtitle: 'Create smart product catalogs.',
                          onTap: () {
                            showComingSoon('AI Cataloging');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        dashboardCard(
                          icon: Icons.currency_rupee,
                          title: 'Smart Pricing',
                          subtitle: 'Get intelligent pricing suggestions.',
                          onTap: () {
                            showComingSoon('Smart Pricing');
                          },
                        ),

                        const SizedBox(width: 14),

                        dashboardCard(
                          icon: Icons.people_outline,
                          title: 'Find Buyers',
                          subtitle: 'Connect with relevant buyers.',
                          onTap: () {
                            showComingSoon('Find Buyers');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Profile section
                    Row(
                      children: [
                        const Text(
                          'Manage Your Store',
                          style: TextStyle(
                            color: cream,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                      ],
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
                          icon: Icons.inventory_2_outlined,
                          title: 'My Products',
                          onTap: openMyProducts,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Small information card
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
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: gold,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Grow your craft business',
                                  style: TextStyle(
                                    color: cream,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add your products and complete your profile to reach more buyers.',
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
