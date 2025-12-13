import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding

  await Hive.initFlutter();
  
  runApp(const MyApp());
}