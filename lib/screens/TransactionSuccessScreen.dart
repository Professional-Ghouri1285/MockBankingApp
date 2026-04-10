import 'package:flutter/material.dart';
import '../app_state.dart';

class TransactionSuccessScreen extends StatelessWidget {
  const TransactionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final latest = appState.transactions.isNotEmpty ? appState.transactions.first : null;
    final textColor = appState.darkMode ? Colors.white : Colors.black;

    String tid = latest?.id ?? 'N/A';
    String dateStr = latest != null
        ? "${latest.date.day}/${latest.date.month}/${latest.date.year} at ${latest.date.hour}:${latest.date.minute.toString().padLeft(2, '0')}"
        : 'N/A';
    String amount = latest != null ? "Rs ${latest.amount.toStringAsFixed(2)}" : "Rs 0.00";
    String to = latest?.to ?? "Unknown";
    String from = latest?.from ?? "Unknown";
    String memo = latest?.memo ?? "No memo";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Transaction Success', style: TextStyle(color: textColor)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
                ),
                const SizedBox(height: 20),
                Text("Transfer Successful!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Text("Your money has been sent", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7))),
                const SizedBox(height: 30),
                Container(
                  width: MediaQuery.of(context).size.width > 400 ? 400 : double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3D4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text(amount, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black))),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.black26),
                      const SizedBox(height: 15),
                      _buildDetailRow("Transaction ID", tid),
                      const SizedBox(height: 12),
                      _buildDetailRow("Date & Time", dateStr),
                      const SizedBox(height: 12),
                      _buildDetailRow("From", from),
                      const SizedBox(height: 12),
                      _buildDetailRow("To", to),
                      const SizedBox(height: 12),
                      _buildDetailRow("Memo", memo),
                      const SizedBox(height: 12),
                      _buildDetailRow("Charges", "Rs 0.00"),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width > 400 ? 400 : double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 3,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_rounded, size: 22),
                        SizedBox(width: 10),
                        Text("Back to Home", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    text: 'Quad',
                    style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w700),
                    children: [
                      TextSpan(text: 'Bank', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700)),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text("$label:", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black))),
      ],
    );
  }
}
