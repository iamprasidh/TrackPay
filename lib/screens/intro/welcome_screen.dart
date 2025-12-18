import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../accounts/add_account_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

      void _saveNameAndContinue() async {
        String name = nameController.text.trim();

        // Default to "User" only if empty
        if (name.isEmpty) name = "User";

        // Open box
        final box = await Hive.openBox('user');

        // Save the name
        await box.put('name', name);

        // Navigate
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddAccountScreen()),
        );
      }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Welcome to TrackPay",
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "A simple, minimal way to track your money.",
                  style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Enter your name (optional)",
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveNameAndContinue,
                    child: const Text("Continue"),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    // Default name if user skips
                    final box = await Hive.openBox('user');
                    await box.put('name', 'User');

                    // Navigate to Add Account Screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AddAccountScreen()),
                    );
                  },
                  child: const Text("Skip"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
