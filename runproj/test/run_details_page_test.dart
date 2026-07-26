import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runproj/models/run.dart';
import 'package:runproj/pages/run_details_page.dart';

void main() {
  testWidgets('RunDetailsPage shows run details', (tester) async {
    final run = Run.completed(
      date: DateTime(2024, 1, 2, 13, 45),
      durationInSeconds: 3661,
      distanceInMeters: 5000,
      route: [],
    );

    await tester.pumpWidget(MaterialApp(home: RunDetailsPage(run: run)));

    expect(find.textContaining('02/01/2024'), findsOneWidget);
    expect(find.text('5.00 km'), findsOneWidget);
    expect(find.text('01:01:01'), findsOneWidget);
    expect(find.text('12:12'), findsOneWidget);
  });
}
