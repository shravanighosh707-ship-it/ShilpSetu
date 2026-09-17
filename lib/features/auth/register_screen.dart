import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = 'artisan';
  String message = '';

  Future<void> register() async {
    try {
      final credential = await _authService.registerUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('User creation failed');
      }

      await _firestoreService.createUserProfile(
        uid: user.uid,
        name: nameController.text.trim(),
        email: user.email ?? emailController.text.trim(),
        role: selectedRole,
      );

      setState(() {
        message = 'Registration successful!';
      });
    } catch (e) {
      setState(() {
        message = 'Registration failed: $e';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),

            const SizedBox(height: 15),

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

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(labelText: 'Select Role'),
              items: const [
                DropdownMenuItem(value: 'artisan', child: Text('Artisan')),
                DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                  });
                }
              },
            ),

            const SizedBox(height: 25),

            ElevatedButton(onPressed: register, child: const Text('Register')),

            const SizedBox(height: 20),

            Text(message),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
