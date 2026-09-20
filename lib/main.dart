import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/auth/login_screen.dart';
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
      home: const LoginScreen(),
    );
  }
}
