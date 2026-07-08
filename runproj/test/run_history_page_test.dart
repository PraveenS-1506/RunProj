import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runproj/models/run.dart';
import 'package:runproj/pages/run_history_page.dart';

void main() {
  testWidgets('shows an empty state when no runs are saved', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RunHistoryPage(initialRunsFuture: Future.value(const <Run>[])),
      ),
    );
    await tester.pump();

    expect(find.text('No runs yet. Start your first run!'), findsOneWidget);
  });
}
