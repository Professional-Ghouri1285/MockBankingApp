import 'package:flutter/material.dart';
import '../app_state.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    appState.removeListener(() => setState(() {}));
    amountController.dispose();
    super.dispose();
  }

  void handleDeposit() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    await appState.deposit(amount);
    setState(() => _isLoading = false);

    if (mounted) {
      amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully deposited Rs ${amount.toStringAsFixed(2)}"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightYellow = Color(0xFFFFF2CC);
    final textColor = appState.darkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Deposit Funds',
          style: TextStyle(
            color: appState.darkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
          color: appState.darkMode ? Colors.white : Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3))],
              ),
              child: Column(
                children: [
                  Text("Current Balance", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7))),
                  const SizedBox(height: 6),
                  Text("Rs ${appState.balance.toStringAsFixed(2)}", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: amountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Enter Amount",
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.black54),
                  filled: true,
                  fillColor: lightYellow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _isLoading ? null : handleDeposit,
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                      : Text("Deposit", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
