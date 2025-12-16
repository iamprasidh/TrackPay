import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 5)
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  User({
    required this.id,
    required this.name,
  });
}