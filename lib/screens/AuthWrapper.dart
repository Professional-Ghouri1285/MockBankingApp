import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginScreen.dart';
import 'SignupScreen.dart';
import 'DashboardScreen.dart';
import '../app_state.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _dataLoaded = false;
  User? _user;
  late final Stream<User?> _authStream;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();

    _authSubscription = _authStream.listen((user) async {
      setState(() {
        _isLoading = true;
        _user = user;
      });

      if (user != null) {
        print("🔄 User is logged in, loading data...");
        await appState.loadUserData();
        print("✅ User data loaded");
        setState(() {
          _dataLoaded = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _dataLoaded = false;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Loading your account..."),
            ],
          ),
        ),
      );
    }

    if (_user != null && _dataLoaded) {
      return const DashboardScreen();
    }

    return const SignupScreen();
  }
}
