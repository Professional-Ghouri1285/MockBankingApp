import 'package:flutter/material.dart';
import '../app_state.dart';

class VirtualCreditCardScreen extends StatefulWidget {
  const VirtualCreditCardScreen({super.key});

  @override
  State<VirtualCreditCardScreen> createState() =>
      _VirtualCreditCardScreenState();
}

class _VirtualCreditCardScreenState extends State<VirtualCreditCardScreen> {
  bool isTemporarilyDisabled = false;
  bool isPermanentlyDisabled = false;

  void toggleTemporaryDisable() {
    if (isPermanentlyDisabled) return;
    setState(() => isTemporarilyDisabled = !isTemporarilyDisabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isTemporarilyDisabled ? "Card temporarily disabled" : "Card re-enabled"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void permanentDisable() {
    if (isPermanentlyDisabled) return;
    setState(() {
      isPermanentlyDisabled = true;
      isTemporarilyDisabled = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Card permanently disabled"), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = appState.darkMode ? Colors.white : Colors.black;
    final cardTextColor = isPermanentlyDisabled || isTemporarilyDisabled
        ? Colors.grey.shade900
        : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Virtual Credit Card", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
        backgroundColor: appState.darkMode ? Theme.of(context).appBarTheme.backgroundColor : Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C2C2C), Color(0xFF000000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.credit_card, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 5),
                            Text("Quad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cardTextColor)),
                            Text("Bank", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Icon(Icons.wifi, color: cardTextColor, size: 26),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      appState.cardNumber.isNotEmpty ? appState.cardNumber : "•••• •••• •••• ••••",
                      style: TextStyle(fontSize: 22, color: cardTextColor, letterSpacing: 2.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.expiryDate.isNotEmpty ? "valid thru ${appState.expiryDate}" : "valid thru ••/••",
                      style: TextStyle(fontSize: 14, color: cardTextColor),
                    ),
                    const Spacer(),
                    Text(
                      appState.username.isNotEmpty ? appState.username.toUpperCase() : "CARDHOLDER NAME",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cardTextColor, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C2C2C), Color(0xFF000000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 20),
                    Container(height: 35, color: Colors.black),
                    const SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white,
                      width: 100,
                      height: 25,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        appState.cvv.isNotEmpty ? appState.cvv : "•••",
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: toggleTemporaryDisable,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isPermanentlyDisabled ? Colors.grey : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Temporary Disable",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: isPermanentlyDisabled ? null : permanentDisable,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: isPermanentlyDisabled ? Colors.grey : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Permanent Disable",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
