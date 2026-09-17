import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'artisan_profile_screen.dart';

class ArtisanDashboard extends StatelessWidget {
  const ArtisanDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artisan Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Artisan!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
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
                },
                child: const Text('Complete Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
