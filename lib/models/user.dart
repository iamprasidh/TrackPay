import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 5)
class user {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  user({
    required this.id,
    required this.name,
  });
}