import 'package:hive/hive.dart';
part 'settings.g.dart';

@HiveType(typeId: 3)
class Settings{
  @HiveField(0)
  bool isDarkMode;
  @HiveField(1)
  String currency;

  Settings({
      this.isDarkMode = false,
      this.currency = 'INR',
     });
}