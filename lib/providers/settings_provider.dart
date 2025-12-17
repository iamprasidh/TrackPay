import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings.defaultSettings());

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