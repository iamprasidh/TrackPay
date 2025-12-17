import 'package:hive/hive.dart';
part 'settings.g.dart';

@HiveType(typeId: 3)
class Settings {
  @HiveField(0)
  final String userName;
  @HiveField(1)
  final bool isDarkMode;
  @HiveField(2)
  final String currency;

  Settings({
    this.userName = 'User',
    this.isDarkMode = false,
    this.currency = 'INR',
  });

  Settings copyWith({
    String? userName,
    bool? isDarkMode,
    String? currency,
  }) {
    return Settings(
      userName: userName ?? this.userName,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
    );
  }

  static Settings defaultSettings() {
    return Settings();
  }
}