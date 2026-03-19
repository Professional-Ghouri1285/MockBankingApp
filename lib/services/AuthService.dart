import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/SavingsGoal.dart';
import '../models/TransactionRecord.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateAccountNumber() {
    final random = Random();
    return '77${random.nextInt(90) + 10}${random.nextInt(90) + 10}${random.nextInt(90) + 10}${random.nextInt(90) + 10}${random.nextInt(90) + 10}';
  }

  String _generateCardNumber() {
    final random = Random();
    String cardNumber = '';
    for (int i = 0; i < 4; i++) {
      cardNumber += '${random.nextInt(9000) + 1000}';
      if (i < 3) cardNumber += ' ';
    }
    return cardNumber;
  }

  String _generateCVV() {
    final random = Random();
    return (random.nextInt(900) + 100).toString();
  }

  String _generateExpiryDate() {
    final now = DateTime.now();
    final expiryDate = DateTime(now.year + 5, now.month);
    return '${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year.toString().substring(2)}';
  }

  TransactionType _stringToTransactionType(String type) {
    switch (type) {
      case 'deposit':
        return TransactionType.deposit;
      case 'bill':
        return TransactionType.bill;
      case 'received':
        return TransactionType.received;
      case 'transfer':
      default:
        return TransactionType.transfer;
    }
  }

  Future<String?> signUp(String username, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String accountNumber = _generateAccountNumber();
      String cardNumber = _generateCardNumber();
      String cvv = _generateCVV();
      String expiryDate = _generateExpiryDate();
      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'accountNumber': accountNumber,
        'balance': 1000.0,
        'cardNumber': cardNumber,
        'cvv': cvv,
        'expiryDate': expiryDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  Future<void> updateBalance(double newBalance) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'balance': newBalance,
      });
    }
  }

  Future<Map<String, dynamic>?> findUserByAccountNumber(String accountNumber) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users')
          .where('accountNumber', isEqualTo: accountNumber.trim())
          .limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error finding user by account number: $e");
      return null;
    }
  }

  Future<void> updateRecipientBalance(String recipientUid, double newBalance) async {
    await _firestore.collection('users').doc(recipientUid).update({
      'balance': newBalance,
    });
  }

  Future<void> storeTransaction({
    required String userId,
    required String transactionId,
    required DateTime date,
    required double amount,
    required String to,
    required String from,
    required String type,
    String? memo,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .set({
      'id': transactionId,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'to': to,
      'from': from,
      'type': type,
      'memo': memo ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<TransactionRecord>> fetchUserTransactions(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      final currentUserData = await getCurrentUserData();
      final currentUsername = currentUserData?['username'] ?? '';

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final transactionType = _stringToTransactionType(data['type'] ?? 'transfer');
        final to = data['to'] ?? '';
        final from = data['from'] ?? '';

        TransactionType finalType = transactionType;
        if (transactionType == TransactionType.transfer && to == currentUsername) {
          finalType = TransactionType.received;
        }

        return TransactionRecord(
          id: data['id'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          amount: (data['amount'] ?? 0.0).toDouble(),
          to: to,
          from: from,
          memo: data['memo'],
          type: finalType,
        );
      }).toList();
    } catch (e) {
      print("Error fetching transactions: $e");
      return [];
    }
  }

  // Savings Goals Methods
  Future<void> createSavingsGoal(String userId, SavingsGoal goal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .doc(goal.id)
        .set(goal.toMap());
  }

  Future<List<SavingsGoal>> fetchSavingsGoals(String userId, {bool completedOnly = false}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('savings_goals')
          .get();

      List<SavingsGoal> allGoals = snapshot.docs.map((doc) {
        return SavingsGoal.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      List<SavingsGoal> filteredGoals = allGoals.where((goal) => goal.isCompleted == completedOnly).toList();
      filteredGoals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return filteredGoals;
    } catch (e) {
      print("Error fetching savings goals: $e");
      return [];
    }
  }

  Future<void> addMoneyToGoal(String userId, String goalId, double amount) async {
    DocumentReference goalRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .doc(goalId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(goalRef);
      if (snapshot.exists) {
        double currentAmount = (snapshot.get('currentAmount') ?? 0.0).toDouble();
        double targetAmount = (snapshot.get('targetAmount') ?? 0.0).toDouble();
        double newAmount = currentAmount + amount;

        transaction.update(goalRef, {
          'currentAmount': newAmount,
          'isCompleted': newAmount >= targetAmount,
        });
      }
    });
  }

  Future<void> completeGoalAndAddToBalance(String userId, String goalId) async {
    DocumentReference goalRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .doc(goalId);

    DocumentSnapshot goalSnapshot = await goalRef.get();
    if (goalSnapshot.exists) {
      double currentAmount = (goalSnapshot.get('currentAmount') ?? 0.0).toDouble();

      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        if (userSnapshot.exists) {
          double currentBalance = (userSnapshot.get('balance') ?? 0.0).toDouble();
          transaction.update(userRef, {'balance': currentBalance + currentAmount});
        }
      });

      await goalRef.update({'isCompleted': true});
    }
  }

  Future<void> deleteGoal(String userId, String goalId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .doc(goalId)
        .delete();
  }

  // Bills Methods
  Future<Map<String, dynamic>?> fetchBillByTypeAndId(String billType, String billId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('bills')
          .where('type', isEqualTo: billType)
          .where('id', isEqualTo: billId.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching bill: $e");
      return null;
    }
  }
}

final AuthService authService = AuthService();
