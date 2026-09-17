import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../artisan/artisan_dashboard.dart';
import '../buyer/buyer_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String message = '';

  Future<void> login() async {
    try {
      final credential = await _authService.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Login failed');
      }

      final profile = await _firestoreService.getUserProfile(user.uid);

      if (!profile.exists) {
        throw Exception('User profile not found');
      }

      final data = profile.data();
      final role = data?['role'];
      if (role == 'artisan') {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ArtisanDashboard()),
        );
      } else if (role == 'buyer') {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BuyerDashboard()),
        );
      } else {
        setState(() {
          message = 'Unknown user role.';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Login failed: $e';
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            const SizedBox(height: 25),

            ElevatedButton(onPressed: login, child: const Text('Login')),

            const SizedBox(height: 20),

            Text(message),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
