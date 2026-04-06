import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool _showBalance = true;
  bool _isRefreshing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    setState(() {});
  }

  Future<void> _refreshAccountData() async {
    setState(() => _isRefreshing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;

          appState.username = data['username'] ?? '';
          appState.accountNumber = data['accountNumber'] ?? '';
          appState.cardNumber = data['cardNumber'] ?? '';
          appState.cvv = data['cvv'] ?? '';
          appState.expiryDate = data['expiryDate'] ?? '';
          appState.darkMode = appState.darkMode;
          appState.saveLoginInfo = appState.saveLoginInfo;
          appState.transactions = appState.transactions;

          appState
            .._balance = (data['balance'] ?? 0.0).toDouble();

          appState.transactions =
          await authService.fetchUserTransactions(user.uid);

          appState.savingsGoals =
          await authService.fetchSavingsGoals(user.uid, completedOnly: false);

          appState.completedGoals =
          await authService.fetchSavingsGoals(user.uid, completedOnly: true);

          appState.notifyListeners();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account refreshed'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = appState.darkMode ? Colors.white : Colors.black;
    final iconColor = appState.darkMode ? Colors.white : Colors.black;

    if (appState.username.isEmpty || appState.accountNumber.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text("Loading your banking data...", style: TextStyle(color: textColor)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appState.darkMode ? Theme.of(context).appBarTheme.backgroundColor : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.settings, size: 28, color: iconColor),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        title: Image.asset(
          appState.darkMode ? 'assets/images/logo_b4.png' : 'assets/images/logo2.jpeg',
          height: 50,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            )
                : Icon(Icons.refresh, size: 28, color: iconColor),
            onPressed: _isRefreshing ? null : _refreshAccountData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              elevation: 4,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Current Balance:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black)),
                        IconButton(
                          icon: Icon(_showBalance ? Icons.visibility : Icons.visibility_off, size: 18, color: Colors.black),
                          onPressed: () => setState(() => _showBalance = !_showBalance),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Text(
                      _showBalance ? "Rs ${appState.balance.toStringAsFixed(2)}" : "Rs ••••••",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    const Text("Account Number:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
                    const SizedBox(height: 3),
                    Text(appState.accountNumber, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemHeight = (constraints.maxHeight - 32) / 3;
                  final itemWidth = (constraints.maxWidth - 16) / 2;

                  return GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: itemWidth / itemHeight,
                    children: [
                      _buildActionCard(Icons.download_rounded, "Deposit Money", '/deposit', textColor, iconColor),
                      _buildActionCard(Icons.sync_alt, "Transfer Money", '/transfer', textColor, iconColor),
                      _buildActionCard(Icons.receipt_long, "Pay Bills", '/paybills', textColor, iconColor),
                      _buildActionCard(Icons.credit_card, "Virtual Credit Card", '/virtual', textColor, iconColor),
                      _buildActionCard(Icons.history, "Transaction History", '/transactions', textColor, iconColor),
                      _buildActionCard(Icons.savings, "Savings Goals", '/savings', textColor, iconColor),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          onTap: (index) {
            if (index == 1) {
              Navigator.pushNamed(context, '/map').then((_) {
                setState(() => _tabController.index = 0);
              });
            }
            if (index == 2) {
              Navigator.pushNamed(context, '/account').then((_) {
                setState(() => _tabController.index = 0);
              });
            }
          },
          tabs: const [
            Tab(icon: Icon(Icons.home), text: "Home"),
            Tab(icon: Icon(Icons.map), text: "Maps"),
            Tab(icon: Icon(Icons.account_circle), text: "Account"),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, String route, Color textColor, Color iconColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: iconColor),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
          ],
        ),
      ),
    );
  }
}
