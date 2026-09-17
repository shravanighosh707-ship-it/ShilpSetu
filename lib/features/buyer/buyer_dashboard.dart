import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'buyer_profile_screen.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyerProfileScreen(uid: user.uid),
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
