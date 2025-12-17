import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/settings.dart';

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings.defaultSettings()) {
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    try {
      final box = await Hive.openBox('user');
      final savedName = box.get('name');
      
      if (savedName != null && savedName is String && savedName.isNotEmpty) {
        state = state.copyWith(userName: savedName);
      }
    } catch (e) {
      // If there's an error loading saved settings, use defaults
      print('Error loading saved settings: $e');
    }
  }

  void updateUserName(String name) {
    state = state.copyWith(userName: name);
  }

  void updateDarkMode(bool isDarkMode) {
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  void resetToDefaults() {
    state = Settings.defaultSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(
  (ref) => SettingsNotifier(),
);