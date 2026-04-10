import 'package:flutter/material.dart';
import '../app_state.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _showBalance = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    appState.removeListener(() => setState(() {}));
    super.dispose();
  }

  Widget _buildCard(String title, String value, IconData icon, {Widget? trailing}) {
    final textColor = appState.darkMode ? Colors.white : Colors.black;
    final subtitleColor = appState.darkMode ? Colors.white70 : Colors.grey;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: appState.darkMode ? Colors.white70 : Colors.grey.shade700, size: 20),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor))),
                if (trailing != null) trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = appState.darkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text("Account Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Theme.of(context).primaryColor,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 24),
              _buildCard("Account Holder Name", appState.username, Icons.person_outline),
              const SizedBox(height: 12),
              _buildCard("Account Number", appState.accountNumber, Icons.account_balance),
              const SizedBox(height: 12),
              _buildCard(
                "Account Balance",
                _showBalance ? "Rs ${appState.balance.toStringAsFixed(2)}" : "Rs ••••••",
                Icons.account_balance_wallet,
                trailing: IconButton(
                  icon: Icon(_showBalance ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).primaryColor),
                  onPressed: () => setState(() => _showBalance = !_showBalance),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
