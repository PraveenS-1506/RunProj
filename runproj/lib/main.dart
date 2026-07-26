import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/run.dart';
import 'models/run_location.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RunLocationAdapter());
  Hive.registerAdapter(RunAdapter());
  await Hive.openBox<Run>('runs');
  runApp(const RunLogApp());
}

class RunLogApp extends StatelessWidget {
  const RunLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RunLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const HomePage(),
    );
  }
}
