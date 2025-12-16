import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../intro/welcome_screen.dart';
import '../dashboard/dashboard_screen.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstTimeUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isFirstTimeUser = snapshot.data!;

        if (isFirstTimeUser) {
          return const WelcomeScreen();
        } else {
          return const DashboardScreen();
        }
      },
    );
  }

  Future<bool> _isFirstTimeUser() async {
    final box = await Hive.openBox('user');
    return box.get('name') == null;
  }
}
