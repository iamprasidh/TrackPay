import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'categories_screen.dart';
import 'accounts_screen.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text("User Name"),
                  subtitle: Text(settings.userName),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editUserName(context, ref, settings.userName),
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text("Dark Mode"),
                  value: settings.isDarkMode,
                  onChanged: (val) =>
                      ref.read(settingsProvider.notifier).updateDarkMode(val),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.currency_rupee_outlined),
                  title: const Text("Currency"),
                  subtitle: Text(settings.currency),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _changeCurrency(context, ref, settings.currency),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text("Manage Categories"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text("Manage Accounts"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editUserName(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit User Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "User Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              ref.read(settingsProvider.notifier).updateUserName(name);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _changeCurrency(BuildContext context, WidgetRef ref, String current) {
    const currencies = ['INR', 'USD', 'EUR', 'GBP'];
    String selected = (current.isNotEmpty ? current.toUpperCase() : 'INR');
    if (!currencies.contains(selected)) selected = 'INR';

    String symbolFor(String code) {
      switch (code.toUpperCase()) {
        case 'INR':
          return '₹';
        case 'USD':
          return '\$';
        case 'EUR':
          return '€';
        case 'GBP':
          return '£';
        default:
          return code;
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Currency"),
        content: DropdownButtonFormField<String>(
          value: selected,
          items: currencies
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text('$c  ${symbolFor(c)}'),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) selected = val;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateCurrency(selected);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
