import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // ✅ Register User
  Future<String?> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      return response.user != null ? null : 'Registration failed';
    } catch (e) {
      return e.toString();
    }
  }

  // ✅ Login User
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      return response.user != null ? null : 'Login failed';
    } catch (e) {
      return e.toString();
    }
  }

  // ✅ Logout User
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
