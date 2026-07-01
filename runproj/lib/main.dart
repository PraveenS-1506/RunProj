import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
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
