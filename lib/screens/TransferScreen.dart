import 'package:flutter/material.dart';
import '../app_state.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    appState.removeListener(() => setState(() {}));
    _recipientController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _sendMoney() async {
    if (_recipientController.text.trim().isEmpty) {
      _showDialog("Missing Information", "Please enter recipient account number.");
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      _showDialog("Invalid Amount", "Please enter a valid amount to send.");
      return;
    }

    if (amount > appState.balance) {
      _showDialog("Insufficient Balance", "You don't have enough balance to complete this transfer.");
      return;
    }

    setState(() => _isLoading = true);
    final success = await appState.send(amount, _recipientController.text.trim(), memo: _memoController.text.trim());
    setState(() => _isLoading = false);

    if (success && mounted) {
      _recipientController.clear();
      _amountController.clear();
      _memoController.clear();
      Navigator.pushNamed(context, '/transferSuccess');
    } else if (mounted) {
      _showDialog("Transfer Failed", "Recipient account not found. Please check the account number and try again.");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool enabled = true, TextInputType type = TextInputType.number}) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: type,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = appState.darkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Transfer Money", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 24, color: Colors.black),
                      SizedBox(width: 10),
                      Text("TRANSFER MONEY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text("Current Balance:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 18, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text("Rs ${appState.balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Courier', color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text("Recipient Account Number:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                const SizedBox(height: 6),
                _buildField(_recipientController, "Enter account number", Icons.person, enabled: !_isLoading),
                const SizedBox(height: 16),
                Text("Amount to Send:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                const SizedBox(height: 6),
                _buildField(_amountController, "Enter amount", Icons.attach_money, enabled: !_isLoading),
                const SizedBox(height: 16),
                Text("Memo (Optional):", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                const SizedBox(height: 6),
                _buildField(_memoController, "Add a note", Icons.note, enabled: !_isLoading, type: TextInputType.text),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _sendMoney,
                  child: _isLoading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 20, color: Colors.black),
                      SizedBox(width: 10),
                      Text("SEND MONEY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
