import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/TransactionRecord.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  String _typeLabel(TransactionType t) {
    switch (t) {
      case TransactionType.deposit:
        return "Deposit";
      case TransactionType.transfer:
        return "Transfer";
      case TransactionType.bill:
        return "Bill Payment";
      case TransactionType.received:
        return "Received";
      default:
        return "Transaction";
    }
  }

  IconData _typeIcon(TransactionType t) {
    switch (t) {
      case TransactionType.deposit:
        return Icons.download_rounded;
      case TransactionType.transfer:
        return Icons.sync_alt;
      case TransactionType.bill:
        return Icons.receipt_long;
      case TransactionType.received:
        return Icons.call_received;
      default:
        return Icons.monetization_on;
    }
  }

  String _getAmountPrefix(TransactionType t) {
    if (t == TransactionType.deposit || t == TransactionType.received) {
      return '+';
    } else {
      return '-';
    }
  }

  Color _getAmountColor(TransactionType t) {
    if (t == TransactionType.deposit || t == TransactionType.received) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final txns = appState.transactions;
    final textColor = appState.darkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Transaction History', style: TextStyle(color: textColor)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: txns.isEmpty
          ? Center(
        child: Text(
          "No transactions yet",
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: txns.length,
        itemBuilder: (context, i) {
          final t = txns[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Icon(_typeIcon(t.type), size: 32, color: textColor),
              title: Text(
                _typeLabel(t.type),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: textColor),
              ),
              subtitle: Text(
                '${t.type == TransactionType.received ? "From" : "To"}: '
                    '${t.type == TransactionType.received ? t.from : t.to}\n'
                    'On: ${t.date.day}/${t.date.month}/${t.date.year}',
                style: TextStyle(
                  color: appState.darkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              trailing: Text(
                '${_getAmountPrefix(t.type)} Rs ${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _getAmountColor(t.type),
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
