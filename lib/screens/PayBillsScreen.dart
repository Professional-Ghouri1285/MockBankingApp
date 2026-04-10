import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/AuthService.dart';

class PayBillsScreen extends StatefulWidget {
  const PayBillsScreen({super.key});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final _billIdCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _selectedBillType;
  bool _isLoading = false;
  Map<String, dynamic>? _fetchedBill;

  final List<String> _billTypes = ['Electricity', 'Water', 'Internet', 'Gas', 'Mobile'];

  void _fetchBillDetails() async {
    final billType = _selectedBillType;
    final billId = _billIdCtrl.text.trim();

    if (billType == null || billId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _fetchedBill = null;
      _amountCtrl.clear();
    });

    final billData = await authService.fetchBillByTypeAndId(billType, billId);

    setState(() {
      _isLoading = false;
      _fetchedBill = billData;
      if (billData != null) {
        _amountCtrl.text = billData['amount'].toString();
      }
    });

    if (billData == null) {
      _showDialog('Bill Not Found', 'No bill found with ID: $billId for $billType');
    }
  }

  void _payBill() async {
    final billType = _selectedBillType;
    final billId = _billIdCtrl.text.trim();
    final amountText = _amountCtrl.text.trim();

    if (billType == null) {
      _showDialog('Select bill type', 'Please select a bill type.');
      return;
    }
    if (billId.isEmpty) {
      _showDialog('Enter bill id', 'Please enter bill id.');
      return;
    }
    if (_fetchedBill == null) {
      _showDialog('Bill not verified', 'Please verify the bill first by entering Bill ID.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showDialog('Invalid amount', 'Please enter a valid amount.');
      return;
    }

    final billAmount = (_fetchedBill!['amount'] ?? 0.0).toDouble();
    if (amount != billAmount) {
      _showDialog('Amount Mismatch', 'Bill amount is Rs ${billAmount.toStringAsFixed(2)}. You entered Rs ${amount.toStringAsFixed(2)}');
      return;
    }

    if (amount > appState.balance) {
      _showDialog('Insufficient balance', 'You do not have enough balance.');
      return;
    }

    setState(() => _isLoading = true);
    bool ok = await appState.payBill(amount, billType, billId);
    setState(() => _isLoading = false);

    if (ok) {
      _showDialog('Payment Successful', 'You paid Rs ${amount.toStringAsFixed(2)} for $billType (ID: $billId).');
      _billIdCtrl.clear();
      _amountCtrl.clear();
      _fetchedBill = null;
    } else {
      _showDialog('Error', 'Could not pay the bill.');
    }
  }

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = appState.darkMode ? Colors.white : Colors.black;
    final cardColor = appState.darkMode ? Colors.grey.shade800 : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pay Bills', style: TextStyle(color: textColor)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Balance :', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                      const SizedBox(height: 6),
                      Text('Rs ${appState.balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Select Bill Type', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBillType,
                      hint: Text('Choose bill type', style: TextStyle(color: textColor.withOpacity(0.7))),
                      isExpanded: true,
                      dropdownColor: cardColor,
                      items: _billTypes.map((b) => DropdownMenuItem(value: b, child: Text(b, style: TextStyle(color: textColor)))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedBillType = v;
                          _fetchedBill = null;
                          _billIdCtrl.clear();
                          _amountCtrl.clear();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Bill ID', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _billIdCtrl,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter Bill ID',
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _fetchedBill = null;
                            _amountCtrl.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _fetchBillDetails,
                      child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
                if (_fetchedBill != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text('Bill Verified', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          ],
                        ),
                        if (_fetchedBill!['description'] != null) ...[
                          const SizedBox(height: 8),
                          Text(_fetchedBill!['description'], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountCtrl,
                  readOnly: _fetchedBill != null,
                  style: TextStyle(color: textColor),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.currency_rupee, color: textColor.withOpacity(0.7)),
                    hintText: 'Enter Amount',
                    filled: true,
                    fillColor: _fetchedBill != null ? Colors.grey.shade300 : cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _payBill,
                  child: const Text("PAY BILL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
