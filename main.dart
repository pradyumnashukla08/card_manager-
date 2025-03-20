import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/card_model.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CardModelAdapter()); // Register Hive Adapter
  await Hive.openBox<CardModel>('cards');  // Open the Hive box

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // ✅ Show LoginScreen first
    );
  }
}
