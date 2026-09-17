import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ShilpSetuApp());
}

class ShilpSetuApp extends StatelessWidget {
  const ShilpSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShilpSetu',
      home: Scaffold(
        appBar: AppBar(title: const Text('ShilpSetu')),
        body: const Center(
          child: Text(
            'Firebase Connected Successfully!',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
