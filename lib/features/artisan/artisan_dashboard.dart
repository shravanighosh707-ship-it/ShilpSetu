import 'package:flutter/material.dart';

class ArtisanDashboard extends StatelessWidget {
  const ArtisanDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artisan Dashboard')),
      body: const Center(
        child: Text('Welcome, Artisan!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
