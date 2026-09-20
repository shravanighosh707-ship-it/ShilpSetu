import 'package:flutter/material.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color navy = Color(0xFF03213A);
  static const Color gold = Color(0xFFD1AA5B);
  static const Color cream = Color(0xFFF1E6CF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 25),

                      // Logo
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: gold, width: 2),
                        ),
                        child: const Icon(
                          Icons.spa_outlined,
                          size: 48,
                          color: gold,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // App name
                      const Text(
                        'ShilpSetu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cream,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tagline
                      const Text(
                        'Bridging Skills with Opportunities',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: gold,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Description
                      const Text(
                        'Empowering artisans by connecting their unique '
                        'craftsmanship with the right buyers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Get Started
                      SizedBox(
                        width: 190,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: navy,
                            elevation: 6,
                            shadowColor: Colors.black54,
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Secondary links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Explore Crafts will be implemented later.
                            },
                            child: const Text(
                              'Explore Crafts',
                              style: TextStyle(color: cream, fontSize: 12),
                            ),
                          ),

                          Container(height: 18, width: 1, color: gold),

                          TextButton(
                            onPressed: () {
                              // About Us will be implemented later.
                            },
                            child: const Text(
                              'About Us',
                              style: TextStyle(color: cream, fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
