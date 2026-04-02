import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameCtrl.text.trim());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') message = 'Password is too weak';
      if (e.code == 'email-already-in-use') message = 'Email already in use';
      if (e.code == 'invalid-email') message = 'Invalid email address';
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
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              const Text('Join OutfitHub',
                style: TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Create your account',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
              const Spacer(),
              Align(alignment: Alignment.centerLeft,
                child: Text('Full Name', style: TextStyle(color: Colors.grey[400], fontSize: 13))),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFE53935)),
                  hintText: 'Your full name',
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
                  hintText: 'Min 6 characters',
                  hintStyle: TextStyle(color: Colors.grey[600]),
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
                    onPressed: _register,
                    child: const Text('SIGN UP'),
                  ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}