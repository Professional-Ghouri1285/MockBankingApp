enum TransactionType {
  deposit,
  transfer,
  bill,
  received,
}

class TransactionRecord {
  final String id;
  final DateTime date;
  final double amount;
  final String to;
  final String from;
  final String? memo;
  final TransactionType type;

  TransactionRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.to,
    required this.from,
    this.memo,
    required this.type,
  });
  
  bool isIncoming(String currentUsername) {
    return type == TransactionType.received ||
        type == TransactionType.deposit ||
        (type == TransactionType.transfer && to == currentUsername);
  }

  String getDisplayAmount(String currentUsername) {
    if (isIncoming(currentUsername)) {
      return '+\$${amount.toStringAsFixed(2)}';
    } else {
      return '-\$${amount.toStringAsFixed(2)}';
    }
  }
}
