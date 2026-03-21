import 'package:flutter/material.dart';
import 'services/AuthService.dart';
import 'services/PreferencesService.dart';
import 'models/SavingsGoal.dart';
import 'models/TransactionRecord.dart';

class AppState extends ChangeNotifier {
  double _balance = 0.0;
  String username = "";
  String accountNumber = "";
  String cardNumber = "";
  String cvv = "";
  String expiryDate = "";
  bool darkMode = false;
  bool saveLoginInfo = false;
  List<TransactionRecord> transactions = [];
  List<SavingsGoal> savingsGoals = [];
  List<SavingsGoal> completedGoals = [];

  double get balance => _balance;

  Future<void> loadPreferences() async {
    darkMode = await preferencesService.getDarkMode();
    saveLoginInfo = await preferencesService.getSaveLoginInfo();
    notifyListeners();
    print("✅ Preferences loaded: darkMode=$darkMode, saveLoginInfo=$saveLoginInfo");
  }

  Future<void> loadUserData() async {
    final userData = await authService.getCurrentUserData();
    if (userData != null) {
      _balance = (userData['balance'] ?? 1000.0).toDouble();
      username = userData['username'] ?? "User";
      accountNumber = userData['accountNumber'] ?? "";
      cardNumber = userData['cardNumber'] ?? "";
      cvv = userData['cvv'] ?? "";
      expiryDate = userData['expiryDate'] ?? "";

      final uid = authService.currentUser?.uid;
      if (uid != null) {
        transactions = await authService.fetchUserTransactions(uid);
        savingsGoals = await authService.fetchSavingsGoals(uid, completedOnly: false);
        completedGoals = await authService.fetchSavingsGoals(uid, completedOnly: true);
      }

      notifyListeners();
      print("✅ User data loaded: $username, Balance: $_balance, Goals: ${savingsGoals.length}");
    }
  }

  Future<void> deposit(double amt) async {
    if (amt <= 0) return;
    _balance += amt;

    await authService.updateBalance(_balance);

    final transaction = TransactionRecord(
      id: 'DEP${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      amount: amt,
      to: 'Self (Deposit)',
      from: username,
      type: TransactionType.deposit,
    );

    transactions.insert(0, transaction);

    final uid = authService.currentUser?.uid;
    if (uid != null) {
      await authService.storeTransaction(
        userId: uid,
        transactionId: transaction.id,
        date: transaction.date,
        amount: transaction.amount,
        to: transaction.to,
        from: transaction.from,
        type: 'deposit',
        memo: transaction.memo,
      );
    }

    notifyListeners();
  }

  Future<bool> send(double amt, String recipientAccountNumber, {String memo = ''}) async {
    if (amt <= 0 || amt > _balance) {
      print("❌ Invalid amount or insufficient balance");
      return false;
    }

    if (recipientAccountNumber.trim() == accountNumber) {
      print("❌ Cannot transfer to your own account");
      return false;
    }

    print("🔄 Starting transfer: $amt to $recipientAccountNumber");

    final recipientData = await authService.findUserByAccountNumber(recipientAccountNumber.trim());
    if (recipientData == null) {
      print("❌ Recipient account not found: $recipientAccountNumber");
      return false;
    }

    print("✅ Recipient found: ${recipientData['username']}");

    try {
      _balance -= amt;
      await authService.updateBalance(_balance);
      print("✅ Sender balance updated");

      double recipientBalance = (recipientData['balance'] ?? 0.0).toDouble();
      recipientBalance += amt;
      await authService.updateRecipientBalance(recipientData['uid'], recipientBalance);
      print("✅ Recipient balance updated");

      final transactionId = 'TRF${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      final memoText = memo.isNotEmpty ? memo : 'Transfer';

      final senderTransaction = TransactionRecord(
        id: transactionId,
        date: now,
        amount: amt,
        to: recipientData['username'] ?? 'Unknown User',
        from: username,
        memo: memoText,
        type: TransactionType.transfer,
      );

      transactions.insert(0, senderTransaction);

      final senderUid = authService.currentUser?.uid;
      if (senderUid != null) {
        await authService.storeTransaction(
          userId: senderUid,
          transactionId: transactionId,
          date: now,
          amount: amt,
          to: recipientData['username'] ?? 'Unknown User',
          from: username,
          type: 'transfer',
          memo: memoText,
        );
      }

      await authService.storeTransaction(
        userId: recipientData['uid'],
        transactionId: transactionId,
        date: now,
        amount: amt,
        to: recipientData['username'] ?? 'Unknown User',
        from: username,
        type: 'transfer',
        memo: memoText,
      );

      notifyListeners();
      print("✅ Transfer completed successfully");
      return true;
    } catch (e) {
      print("❌ Transfer error: $e");
      _balance += amt;
      await authService.updateBalance(_balance);
      notifyListeners();
      return false;
    }
  }

  Future<void> createSavingsGoal(String name, double targetAmount) async {
    final uid = authService.currentUser?.uid;
    if (uid == null) return;

    final goal = SavingsGoal(
      id: 'GOAL${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0.0,
      createdAt: DateTime.now(),
    );

    await authService.createSavingsGoal(uid, goal);
    savingsGoals.insert(0, goal);
    notifyListeners();
  }

  Future<bool> addMoneyToSavingsGoal(String goalId, double amount) async {
    if (amount <= 0 || amount > _balance) return false;

    final uid = authService.currentUser?.uid;
    if (uid == null) return false;

    try {
      _balance -= amount;
      await authService.updateBalance(_balance);
      await authService.addMoneyToGoal(uid, goalId, amount);

      savingsGoals = await authService.fetchSavingsGoals(uid, completedOnly: false);
      completedGoals = await authService.fetchSavingsGoals(uid, completedOnly: true);

      notifyListeners();
      return true;
    } catch (e) {
      _balance += amount;
      await authService.updateBalance(_balance);
      return false;
    }
  }

  Future<void> completeGoalAndAddToBalance(String goalId) async {
    final uid = authService.currentUser?.uid;
    if (uid == null) return;

    final goal = completedGoals.firstWhere((g) => g.id == goalId);
    _balance += goal.currentAmount;

    await authService.completeGoalAndAddToBalance(uid, goalId);
    await authService.deleteGoal(uid, goalId);

    completedGoals.removeWhere((g) => g.id == goalId);
    notifyListeners();
  }

  Future<bool> payBill(double amt, String billType, String billId) async {
    if (amt <= 0 || amt > _balance) return false;
    _balance -= amt;

    await authService.updateBalance(_balance);

    final transaction = TransactionRecord(
      id: 'BIL${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      amount: amt,
      to: billType,
      from: username,
      memo: 'Bill ID: $billId',
      type: TransactionType.bill,
    );

    transactions.insert(0, transaction);

    final uid = authService.currentUser?.uid;
    if (uid != null) {
      await authService.storeTransaction(
        userId: uid,
        transactionId: transaction.id,
        date: transaction.date,
        amount: transaction.amount,
        to: transaction.to,
        from: transaction.from,
        type: 'bill',
        memo: transaction.memo,
      );
    }

    notifyListeners();
    return true;
  }

  Future<void> toggleDarkMode(bool v) async {
    darkMode = v;
    await preferencesService.setDarkMode(v);
    notifyListeners();
    print("✅ Dark mode ${v ? 'enabled' : 'disabled'} and saved");
  }

  Future<void> toggleSaveLogin(bool v) async {
    saveLoginInfo = v;
    await preferencesService.setSaveLoginInfo(v);

    if (!v) {
      await preferencesService.clearCredentials();
    }

    notifyListeners();
    print("✅ Save login info ${v ? 'enabled' : 'disabled'} and saved");
  }

  void logout() {
    _balance = 0.0;
    username = "";
    accountNumber = "";
    cardNumber = "";
    cvv = "";
    expiryDate = "";
    transactions.clear();
    savingsGoals.clear();
    completedGoals.clear();
    notifyListeners();
  }
}

final AppState appState = AppState();
