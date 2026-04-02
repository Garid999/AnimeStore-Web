import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') message = 'No user found with this email';
      if (e.code == 'wrong-password') message = 'Wrong password';
      if (e.code == 'invalid-email') message = 'Invalid email address';
      if (e.code == 'invalid-credential') message = 'Invalid email or password';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.checkroom, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 20),
              const Text('OutfitHub',
                style: TextStyle(color: Colors.white, fontSize: 28,
                  fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              const Text("Men's Fashion Store",
                style: TextStyle(color: Colors.grey, fontSize: 13, letterSpacing: 1.2)),
              const Spacer(),
              Align(alignment: Alignment.centerLeft,
                child: Text('Email', style: TextStyle(color: Colors.grey[400], fontSize: 13))),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFFE53935)),
                  hintText: 'email@example.com',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft,
                child: Text('Password', style: TextStyle(color: Colors.grey[400], fontSize: 13))),
              const SizedBox(height: 6),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFE53935)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                ? const CircularProgressIndicator(color: Color(0xFFE53935))
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('LOGIN'),     
                  ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account? ",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Sign Up',
                    style: TextStyle(color: Color(0xFFE53935), fontSize: 13,
                      fontWeight: FontWeight.w600)),
                ),
              ]),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}