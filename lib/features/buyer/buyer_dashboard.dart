import 'package:flutter/material.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Dashboard')),
      body: const Center(
        child: Text('Welcome, Buyer!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
