import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://bbsjmbnkylrufymmmhfn.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJic2ptYm5reWxydWZ5bW1taGZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ0NTcyMTIsImV4cCI6MjA2MDAzMzIxMn0.pHZf_QEZTlDq2sqbcT0xD6INkdTdHjtjj1llAZc1TJs';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
