import 'package:flutter/material.dart';
import 'run_tracking_page.dart';
import 'run_history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RunLog')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RunTrackingPage()),
              ),
              child: const Text('RUN'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RunHistoryPage()),
              ),
              child: const Text('VIEW RUNS'),
            ),
          ],
        ),
      ),
    );
  }
}
