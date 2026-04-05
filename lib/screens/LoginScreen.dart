import 'package:flutter/material.dart';
import '../services/AuthService.dart';
import '../services/PreferencesService.dart';
import '../app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final saveLoginInfo = await preferencesService.getSaveLoginInfo();
    if (saveLoginInfo) {
      final credentials = await preferencesService.getSavedCredentials();
      if (credentials['email']!.isNotEmpty) {
        setState(() {
          _emailCtrl.text = credentials['email']!;
          _passCtrl.text = credentials['password']!;
          _rememberMe = true;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email to receive a password reset link."),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black),
              decoration: _inputDecoration("your@email.com"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              final error = await authService.resetPassword(email);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? "Password reset email sent!"),
                    backgroundColor: error == null ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text("Send Reset Link"),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await authService.signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());

    if (error != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    await appState.loadUserData();

    final currentSaveLoginSetting = await preferencesService.getSaveLoginInfo();

    if (_rememberMe || currentSaveLoginSetting) {
      await preferencesService.setSaveLoginInfo(true);
      await preferencesService.saveCredentials(_emailCtrl.text.trim(), _passCtrl.text.trim());
      appState.saveLoginInfo = true;
      appState.notifyListeners();
      print("✅ Credentials saved");
    } else {
      await preferencesService.setSaveLoginInfo(false);
      await preferencesService.clearCredentials();
      appState.saveLoginInfo = false;
      appState.notifyListeners();
      print("✅ Credentials cleared");
    }

    setState(() => _isLoading = false);

    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: const Color(0xFFFFF2CC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? "assets/images/logo_bll.png"
                  : "assets/images/logo.jpg",
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text.rich(
              TextSpan(children: [
                TextSpan(text: "Quad", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                TextSpan(text: "Bank", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
              ]),
            ),
            const SizedBox(height: 10),
            const Text("welcome back!", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 50),
            TextField(
              controller: _emailCtrl,
              style: const TextStyle(color: Colors.black),
              decoration: _inputDecoration("Enter Email"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.black),
              decoration: _inputDecoration("Enter Password").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      activeColor: const Color(0xFFD4AF37),
                    ),
                    const Text("Remember Me", style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                GestureDetector(
                  onTap: _showForgotPasswordDialog,
                  child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                )
                    : const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                  child: const Text("Sign Up", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
