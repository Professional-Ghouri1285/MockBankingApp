import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/AuthService.dart';
import '../models/SavingsGoal.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  bool _showCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);

    final uid = authService.currentUser?.uid;
    if (uid != null) {
      appState.savingsGoals =
      await authService.fetchSavingsGoals(uid, completedOnly: false);

      appState.completedGoals =
      await authService.fetchSavingsGoals(uid, completedOnly: true);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showAddGoalDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    _showDialog(
      title: "New Goal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _textField(nameCtrl, "Goal Name", "New Car"),
          const SizedBox(height: 16),
          _textField(amountCtrl, "Target (Rs)", "50000", isNumber: true),
        ],
      ),
      onConfirm: () async {
        final name = nameCtrl.text.trim();
        final amount = double.tryParse(amountCtrl.text.trim());

        if (name.isNotEmpty && amount != null && amount > 0) {
          await appState.createSavingsGoal(name, amount);
          await _loadGoals();
          _snack("Goal created!", Colors.green);
        }
      },
    );
  }

  void _showAddMoneyDialog(SavingsGoal goal) {
    final amountCtrl = TextEditingController();

    _showDialog(
      title: "Add to ${goal.name}",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Saved: Rs ${goal.currentAmount.toStringAsFixed(0)}"),
          Text("Goal: Rs ${goal.targetAmount.toStringAsFixed(0)}"),
          const SizedBox(height: 16),
          _textField(amountCtrl, "Amount (Rs)", "", isNumber: true),
        ],
      ),
      onConfirm: () async {
        final amount = double.tryParse(amountCtrl.text.trim());

        if (amount != null && amount > 0) {
          final ok = await appState.addMoneyToSavingsGoal(goal.id, amount);
          await _loadGoals();

          _snack(ok ? "Added!" : "Insufficient balance",
              ok ? Colors.green : Colors.red);
        }
      },
    );
  }

  void _showDialog({
    required String title,
    required Widget content,
    required Function onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await onConfirm();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController c, String label, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = appState.darkMode ? Colors.white : Colors.black;
    final goals =
    _showCompleted ? appState.completedGoals : appState.savingsGoals;

    return Scaffold(
      appBar: AppBar(
        title: Text("Savings", style: TextStyle(color: textColor)),
        centerTitle: true,
        leading: BackButton(color: textColor),
        actions: [
          TextButton(
            onPressed: () => setState(() => _showCompleted = !_showCompleted),
            child: Text(
              _showCompleted ? "Active" : "Completed",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : goals.isEmpty
          ? _emptyState()
          : _goalsList(goals),
      floatingActionButton:
      _showCompleted ? null : _fab(context),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_showCompleted ? Icons.check_circle_outline : Icons.savings,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _showCompleted ? "No completed goals" : "No goals yet",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add, color: Colors.black),
      onPressed: _showAddGoalDialog,
    );
  }

  Widget _goalsList(List<SavingsGoal> goals) {
    return RefreshIndicator(
      onRefresh: _loadGoals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (_, i) => _goalCard(goals[i]),
      ),
    );
  }

  Widget _goalCard(SavingsGoal goal) {
    final textColor = appState.darkMode ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal.name,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                if (goal.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              minHeight: 6,
            ),

            const SizedBox(height: 8),

            Text(
              "Rs ${goal.currentAmount.toStringAsFixed(0)} / Rs ${goal.targetAmount.toStringAsFixed(0)} (${(goal.progress * 100).toStringAsFixed(0)}%)",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (goal.isCompleted) {
                    await appState.completeGoalAndAddToBalance(goal.id);
                    await _loadGoals();
                    _snack("Added to balance!", Colors.green);
                  } else {
                    _showAddMoneyDialog(goal);
                  }
                },
                style: goal.isCompleted
                    ? ElevatedButton.styleFrom(backgroundColor: Colors.green)
                    : null,
                child: Text(
                  goal.isCompleted ? "Transfer to Balance" : "Add Money",
                  style: TextStyle(
                      color: goal.isCompleted ? Colors.white : Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
