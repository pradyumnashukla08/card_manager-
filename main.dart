import 'package:cards_management/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'services/card_service.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase with Correct Credentials
  await Supabase.initialize(
    url: 'https://tmyswxeugbvkuauvzffm.supabase.co',  // Your Supabase Project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRteXN3eGV1Z2J2a3VhdXZ6ZmZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMyNTI2MjgsImV4cCI6MjA1ODgyODYyOH0.qsdKD3NQKZMwou_0Ma2iEic0d63gUv8MIVAxTKm0cUg',  // Replace with the actual Supabase Anon Key
  );
  // Initialize Notifications
  await NotificationService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CardService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cards Management',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthCheck(), // ✅ Check Authentication First
      ),
    );
  }
}

// ✅ Authentication Check (Redirects based on login status)
class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.session != null) {
          return HomeScreen(); // ✅ User is logged in
        } else {
          return LoginScreen(); // ✅ User is logged out
        }
      },
    );
  }
}
