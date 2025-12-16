import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/account.dart';
import '../dashboard/dashboard_screen.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  String userName = "User"; // default
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final List<Account> accounts = [];

  void _addAccount() async {
  final name = accountNameController.text.trim();
  final balanceText = balanceController.text.trim();
  if (name.isEmpty) return; // require account name

  final openingBalance = double.tryParse(balanceText) ?? 0.0;

  final account = Account(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    accountName: name,
    openingBalance: openingBalance,
  );

  // Save to Hive
  final box = await Hive.openBox<Account>('accounts');
  await box.put(account.id, account);

  setState(() {
    accounts.add(account); // update local list
    accountNameController.clear();
    balanceController.clear();
  });
}

  void _finishSetup() {
  if (accounts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please add at least one account")),
    );
    return;
  }

  // Navigate to Dashboard
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const DashboardScreen()),
  );
}

    @override
  void initState() {
    super.initState();
    _loadUserName();
  }

void _loadUserName() async {
  final box = await Hive.openBox('user');
  final name = box.get('name'); // get the saved name
  if (name != null && mounted) {
    setState(() {
      userName = name;
    });
  }
}


  @override
  void dispose() {
    accountNameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "Hello, $userName!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Let's add your first account",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),


            TextField(
              controller: accountNameController,
              decoration: const InputDecoration(
                labelText: "Account Name (e.g., Bank, Cash)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Opening Balance (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addAccount,
              child: const Text("Add Account"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _finishSetup,
              child: const Text("Finish Setup"),
            ),
          ],
        ),
      ),
    );
  }
}
