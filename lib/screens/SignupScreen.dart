import 'package:flutter/material.dart';
import '../services/AuthService.dart';
import '../app_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_userCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    if (_passCtrl.text != _confirmCtrl.text) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    final signupError = await authService.signUp(_userCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim());

    if (signupError != null) {
      setState(() => _isLoading = false);
      _showSnackBar(signupError);
      return;
    }

    final loginError = await authService.signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());

    if (loginError != null) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/login');
      _showSnackBar('Account created! Please login.');
      return;
    }

    await appState.loadUserData();
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      _showSnackBar('Welcome to QuadBank!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: const Color(0xFFFFF2CC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 50),
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
            const Text("your digital bank partner", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            TextField(
              controller: _userCtrl,
              style: const TextStyle(color: Colors.black),
              decoration: _inputDecoration("Enter Username"),
            ),
            const SizedBox(height: 20),
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
              decoration: _inputDecoration(
                "Enter Password",
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmCtrl,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.black),
              decoration: _inputDecoration("Confirm Password"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text("Login", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _signup,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                )
                    : const Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}
