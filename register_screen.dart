import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showSuccess("Registration successful! You can now log in.");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/register.jpg', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/reg.jpg', height: 300),
                    const SizedBox(height: 20),
                    const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration("Email", Icons.email)),
                    const SizedBox(height: 16),
                    TextFormField(controller: _passwordController, obscureText: true, decoration: _inputDecoration("Password", Icons.lock)),
                    const SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _register, style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.green), child: const Text("Register", style: TextStyle(fontSize: 16, color: Colors.white)))),
                    const SizedBox(height: 10),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())), child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(labelText: label, border: OutlineInputBorder(), prefixIcon: Icon(icon), filled: true, fillColor: Colors.white);
  }
}