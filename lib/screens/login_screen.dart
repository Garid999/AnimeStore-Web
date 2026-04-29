import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'admin_screen.dart';
import 'register_screen.dart';

const String kAdminEmail = 'garidga@gmail.com';
const String _kSavedEmail = 'last_login_email';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _passFocus = FocusNode();
  bool _obscure    = true;
  bool _isLoading  = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kSavedEmail) ?? '';
    if (saved.isNotEmpty && mounted) setState(() => _emailCtrl.text = saved);
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedEmail, email);
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Имэйл болон нууц үгээ оруулна уу')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      await _saveEmail(_emailCtrl.text.trim());

      final userEmail = credential.user?.email?.trim().toLowerCase() ?? '';
      final isAdmin = userEmail == kAdminEmail.toLowerCase();

      if (!isAdmin) {
        try {
          final uid = credential.user!.uid;
          final ref = FirebaseFirestore.instance.collection('users').doc(uid);
          final snap = await ref.get();
          if (!snap.exists) {
            await ref.set({
              'email': userEmail,
              'displayName': credential.user?.displayName ?? '',
              'userDisplayId': 'U-${uid.substring(0, 6).toUpperCase()}',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (_) {}
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isAdmin ? const AdminScreen() : const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = switch (e.code) {
        'user-not-found'     => 'Энэ имэйлтэй хэрэглэгч олдсонгүй',
        'wrong-password'     => 'Нууц үг буруу байна',
        'invalid-email'      => 'Имэйл хаяг буруу байна',
        'invalid-credential' => 'Имэйл эсвэл нууц үг буруу байна',
        _                    => 'Алдаа гарлаа (${e.code})',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.primary),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Logo
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppTheme.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x20000000),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white,
                      child: const Center(
                        child: Text('AS',
                            style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 40,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text('Anime Store',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              const Text('Таны аниме фэшн дэлгүүр',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      letterSpacing: 0.3)),

              const SizedBox(height: 48),

              // Email
              _label('Имэйл хаяг'),
              const SizedBox(height: 8),
              _inputField(
                controller: _emailCtrl,
                hint: 'email@example.com',
                icon: Icons.mail_outline_rounded,
                inputType: TextInputType.emailAddress,
                action: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).requestFocus(_passFocus),
              ),

              const SizedBox(height: 20),

              // Password
              _label('Нууц үг'),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                focusNode: _passFocus,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) { if (!_isLoading) _login(); },
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppTheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textSecondary, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              _isLoading
                  ? const CircularProgressIndicator(color: AppTheme.primary)
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('НЭВТРЭХ',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                    ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Бүртгэл байхгүй юу? ',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('Бүртгүүлэх',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) =>
      TextField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: action,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primary),
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      );
}
