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
        children: [
          /// 🔹 User Name
          ListTile(
            title: const Text("User Name"),
            subtitle: Text(settings.userName),
            trailing: const Icon(Icons.edit),
            onTap: () => _editUserName(context, ref, settings.userName),
          ),

          /// 🔹 Dark Mode
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: settings.isDarkMode,
            onChanged: (val) =>
                ref.read(settingsProvider.notifier).updateDarkMode(val),
          ),

          /// 🔹 Currency
          ListTile(
            title: const Text("Currency"),
            subtitle: Text(settings.currency),
            trailing: const Icon(Icons.edit),
            onTap: () => _changeCurrency(context, ref, settings.currency),
          ),

          const Divider(),

          /// 🔹 Categories management
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text("Manage Categories"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
          ),

          /// 🔹 Accounts management
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text("Manage Accounts"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountsScreen()),
              );
            },
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
    final controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Currency"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Currency"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final currency = controller.text.trim();
              if (currency.isEmpty) return;
              ref.read(settingsProvider.notifier).updateCurrency(currency);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
