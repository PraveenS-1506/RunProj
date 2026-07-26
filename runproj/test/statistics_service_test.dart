import 'package:flutter_test/flutter_test.dart';
import 'package:runproj/models/run.dart';
import 'package:runproj/models/run_location.dart';
import 'package:runproj/services/statistics_service.dart';

void main() {
  group('StatisticsService', () {
    test('computes overview, records, and monthly summaries from runs', () {
      final runs = [
        Run(
          date: DateTime(2026, 7, 10, 18, 30),
          durationInSeconds: 3600,
          distanceInMeters: 5000,
          averagePace: 12.0,
          route: const <RunLocation>[],
        ),
        Run(
          date: DateTime(2026, 6, 20, 8, 0),
          durationInSeconds: 1800,
          distanceInMeters: 3000,
          averagePace: 10.0,
          route: const <RunLocation>[],
        ),
        Run(
          date: DateTime(2026, 7, 1, 7, 15),
          durationInSeconds: 5400,
          distanceInMeters: 9000,
          averagePace: 10.0,
          route: const <RunLocation>[],
        ),
      ];

      final summary = StatisticsService.calculate(runs);

      expect(summary.totalRuns, 3);
      expect(summary.totalDistanceInMeters, 17000);
      expect(summary.totalDurationInSeconds, 10800);
      expect(summary.averagePace, 10.666666666666666);
      expect(summary.longestDistanceInMeters, 9000);
      expect(summary.fastestAveragePace, 10.0);
      expect(summary.longestDurationInSeconds, 5400);
      expect(summary.monthlySummaries.length, 2);
      expect(summary.monthlySummaries.first.monthLabel, 'July 2026');
      expect(summary.monthlySummaries.first.runCount, 2);
      expect(summary.monthlySummaries.first.totalDistanceInMeters, 14000);
      expect(summary.recentRun?.date, DateTime(2026, 7, 10, 18, 30));
    });

    test('returns empty summary when there are no runs', () {
      final summary = StatisticsService.calculate(const <Run>[]);

      expect(summary.totalRuns, 0);
      expect(summary.totalDistanceInMeters, 0);
      expect(summary.totalDurationInSeconds, 0);
      expect(summary.averagePace, 0.0);
      expect(summary.longestDistanceInMeters, 0);
      expect(summary.fastestAveragePace, 0.0);
      expect(summary.longestDurationInSeconds, 0);
      expect(summary.monthlySummaries, isEmpty);
      expect(summary.recentRun, isNull);
    });
  });
}
