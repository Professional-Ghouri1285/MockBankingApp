import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/AuthWrapper.dart';
import 'app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await appState.loadPreferences();

  runApp(const QuadBankApp());
}

class QuadBankApp extends StatefulWidget {
  const QuadBankApp({super.key});

  @override
  State<QuadBankApp> createState() => _QuadBankAppState();
}

class _QuadBankAppState extends State<QuadBankApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _performLogout();
    }
  }

  void _performLogout() async {
    try {
      await authService.signOut();
      appState.logout();
      print("✅ User logged out due to app lifecycle change");
    } catch (e) {
      print("❌ Error during auto logout: $e");
    }
  }

  void _onAppStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuadBank',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: appState.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthWrapper(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/deposit': (context) => const DepositScreen(),
        '/transfer': (context) => const TransferScreen(),
        '/virtual': (context) => const VirtualCreditCardScreen(),
        '/transferSuccess': (context) => const TransactionSuccessScreen(),
        '/paybills': (context) => const PayBillsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/transactions': (context) => const TransactionHistoryScreen(),
        '/account': (context) => const AccountScreen(),
        '/map': (context) => const MapScreen(),
        '/savings': (context) => const SavingsScreen(),
      },
    );
    }
}

const Color _goldColor = Color(0xFFD4AF37);

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: _goldColor,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: _goldColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFF2CC),
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _goldColor,
      foregroundColor: Colors.black,
    ),
  ),
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: _goldColor,
  scaffoldBackgroundColor: const Color(0xFF1A1A1A),
  colorScheme: const ColorScheme.dark(
    primary: _goldColor,
    surface: Color(0xFF2D2D2D),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2D2D2D),
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _goldColor,
      foregroundColor: Colors.black,
    ),
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF2D2D2D),
  ),
);
