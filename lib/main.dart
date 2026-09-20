import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/auth/login_screen.dart';
import 'features/products/add_product_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (const bool.fromEnvironment('USE_FIREBASE_EMULATORS')) {
    FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
    FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5001);
    FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  }

  runApp(const ShilpSetuApp());
}

class ShilpSetuApp extends StatelessWidget {
  const ShilpSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShilpSetu',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF051A37),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _madhubaniAnimation;
  late Animation<Offset> _handloomAnimation;
  late Animation<Offset> _lotusAnimation;
  late Animation<Offset> _peacockAnimation;
  late Animation<Offset> _woodcraftAnimation;
  late Animation<Offset> _elephantAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _madhubaniAnimation = _createSlideAnimation(
      const Offset(-1.5, 0),
      const Offset(0, 0),
      0.0,
    );

    _handloomAnimation = _createSlideAnimation(
      const Offset(1.5, -0.5),
      const Offset(0, 0),
      0.1,
    );

    _lotusAnimation = _createSlideAnimation(
      const Offset(-1.5, 0),
      const Offset(0, 0),
      0.2,
    );

    _peacockAnimation = _createSlideAnimation(
      const Offset(1.5, 0),
      const Offset(0, 0),
      0.3,
    );

    _woodcraftAnimation = _createSlideAnimation(
      const Offset(-1.5, 1),
      const Offset(0, 0),
      0.4,
    );

    _elephantAnimation = _createSlideAnimation(
      const Offset(1.5, 1),
      const Offset(0, 0),
      0.5,
    );

    _controller.forward();
  }

  Animation<Offset> _createSlideAnimation(
    Offset begin,
    Offset end,
    double delay,
  ) {
    final start = delay;
    final finish = (delay + 0.5).clamp(0.0, 1.0);

    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, finish, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background
          Container(decoration: const BoxDecoration(color: Color(0xFF051A37))),

          // Madhubani torn JPG
          Positioned(
            top: -20,
            left: -75,
            child: SlideTransition(
              position: _madhubaniAnimation,
              child: _artwork(
                assetPath: 'assets/artworks/torn_madhubani-removebg.png',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
                rotation: -0.08,
              ),
            ),
          ),

          // Handloom+pottery image
          Positioned(
            top: -10,
            right: -80,
            child: _artwork(
              assetPath: 'assets/artworks/svg_potteryandhandloom.png',
              width: 350,
              height: 270,
              fit: BoxFit.contain,
              rotation: 0.00,
            ),
          ),

          // Lotus image
          Positioned(
            top: size.height * 0.34,
            left: -18,
            child: SlideTransition(
              position: _lotusAnimation,
              child: _artwork(
                assetPath: 'assets/artworks/transparent_lotus.png',
                width: 135,
                height: 135,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Peacock image
          Positioned(
            top: size.height * 0.34,
            right: -30,
            child: SlideTransition(
              position: _peacockAnimation,
              child: _artwork(
                assetPath: 'assets/artworks/transparent_peacock.png',
                width: 135,
                height: 135,
                fit: BoxFit.contain,
                rotation: 0.00,
              ),
            ),
          ),

          // Woodcraft image
          Positioned(
            bottom: 0,
            left: -45,
            child: SlideTransition(
              position: _woodcraftAnimation,
              child: _artwork(
                assetPath: 'assets/artworks/svg_woodcraft.png',
                width: 280,
                height: 200,
                fit: BoxFit.contain,
                rotation: 0.00,
              ),
            ),
          ),

          // Elephant image
          Positioned(
            bottom: 0,
            right: -45,
            child: SlideTransition(
              position: _elephantAnimation,
              child: _artwork(
                assetPath: 'assets/artworks/svg_elephant.png',
                width: 280,
                height: 220,
                fit: BoxFit.contain,
                rotation: 0.00,
              ),
            ),
          ),

          // Dark overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF051A37).withOpacity(0.05),
                  const Color(0xFF051A37).withOpacity(0.25),
                  const Color(0xFF051A37).withOpacity(0.55),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),

                    // ShilpSetu logo
                    Image.asset(
                      'assets/artworks/logo_image-removebg-preview.png',
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFFD4AF6A),
                          size: 40,
                        );
                      },
                    ),

                    // App name
                    const Text(
                      'ShilpSetu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF4E8D0),
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    const Text(
                      'Bridging Skills with Opportunities',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD4AF6A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Description
                    const Text(
                      'Empowering artisans by connecting their unique '
                      'craftsmanship with the right buyers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF4E8D0),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 34),

                    // Get started button
                    SizedBox(
                      width: 220,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoleSelectionScreen(),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF6A),
                          foregroundColor: const Color(0xFF051A37),
                          elevation: 6,
                          shadowColor: const Color(0xFFD4AF6A)
                              .withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Bottom actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Explore Crafts',
                            style: TextStyle(
                              color: Color(0xFFF4E8D0),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          height: 18,
                          width: 1,
                          color: const Color(0xFFD4AF6A),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'About Us',
                            style: TextStyle(
                              color: Color(0xFFF4E8D0),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _artwork({
    required String assetPath,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
    double rotation = 0,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.transparent,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white54,
              size: 30,
            ),
          );
        },
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const Color navy = Color(0xFF051A37);
  static const Color cardColor = Color(0xFF0B2A50);
  static const Color gold = Color(0xFFD4AF6A);
  static const Color cream = Color(0xFFF4E8D0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Choose Your Role',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold.withOpacity(0.12),
                  border: Border.all(color: gold.withOpacity(0.45), width: 1.2),
                ),
                child: const Icon(
                  Icons.diversity_3_rounded,
                  color: gold,
                  size: 42,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Welcome to ShilpSetu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cream,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'How would you like to use ShilpSetu?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose an option to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              Image.asset(
                'assets/artworks/traditional.png',
                width: double.infinity,
                height: 150,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              // Artisan
              _roleCard(
                context: context,
                icon: Icons.handyman_rounded,
                title: 'I am an Artisan',
                subtitle: 'Showcase your craftsmanship',
                description:
                    'Create your catalog, display your products, '
                    'and connect with potential buyers.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              // Buyer
              _roleCard(
                context: context,
                icon: Icons.shopping_bag_rounded,
                title: 'I am a Buyer',
                subtitle: 'Discover unique handmade crafts',
                description:
                    'Explore authentic products and connect '
                    'with talented artisans.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white38,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'You can change your role later',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: gold.withOpacity(0.12),
        highlightColor: gold.withOpacity(0.05),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold.withOpacity(0.45), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold.withOpacity(0.13),
                ),
                child: Icon(icon, color: gold, size: 42),
              ),

              const SizedBox(height: 18),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: cream,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: gold.withOpacity(0.6)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: cream,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: gold, size: 17),
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

class ArtisanDashboard extends StatelessWidget {
  const ArtisanDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF051A37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF051A37),
        foregroundColor: const Color(0xFFF4E8D0),
        elevation: 0,
        title: const Text(
          'Artisan Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Artisan! 👋',
              style: TextStyle(
                color: Color(0xFFF4E8D0),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Showcase your craftsmanship and reach more buyers.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 30),

            _dashboardCard(
              context,
              Icons.add_a_photo_rounded,
              'Add Your Craft',
              'Upload photos and details of your handmade products.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                );
              },
            ),

            _dashboardCard(
              context,
              Icons.auto_awesome_rounded,
              'AI Cataloging',
              'Generate product descriptions using AI.',
            ),

            _dashboardCard(
              context,
              Icons.currency_rupee_rounded,
              'Smart Pricing',
              'Get assistance with pricing your products.',
            ),

            _dashboardCard(
              context,
              Icons.people_alt_rounded,
              'Find Buyers',
              'Connect with potential buyers and retailers.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context,
    IconData icon,
    String title,
    String description, {
    VoidCallback? onTap,
  }) {
    return Card(
      color: const Color(0xFF0B2A50),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: const Color(0xFFD4AF6A), size: 32),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFF4E8D0),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Color(0xFFD4AF6A),
          size: 16,
        ),
        onTap:
            onTap ??
            () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$title selected!')));
            },
      ),
    );
  }
}
