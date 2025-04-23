import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/card_model.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_card_screen.dart';
import 'screens/edit_card_screen.dart'; // Import the EditCardScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bbsjmbnkylrufymmmhfn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJic2ptYm5reWxydWZ5bW1taGZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ0NTcyMTIsImV4cCI6MjA2MDAzMzIxMn0.pHZf_QEZTlDq2sqbcT0xD6INkdTdHjtjj1llAZc1TJs',
  );

  runApp(const CardManagementApp());
}

class CardManagementApp extends StatelessWidget {
  const CardManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Management',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/', // Initial screen route
      routes: {
        '/': (context) => const AuthGate(), // AuthGate for login check
        '/home': (context) => const HomeScreen(), // Home screen when logged in
        '/add_card': (context) => const AddCardPage(), // Add card screen
    '/edit_card': (context) {
    final card = ModalRoute.of(context)!.settings.arguments as CardModel;
    return EditCardScreen(card: card);
    }, // Edit card screen
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const HomeScreen(); // Logged in, show Home screen
        } else {
          return const LoginScreen(); // Not logged in, show Login screen
        }
      },
    );
  }
}
