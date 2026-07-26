import '../models/run.dart';

class StatisticsSummary {
  StatisticsSummary({
    required this.totalRuns,
    required this.totalDistanceInMeters,
    required this.totalDurationInSeconds,
    required this.averagePace,
    required this.longestDistanceInMeters,
    required this.fastestAveragePace,
    required this.longestDurationInSeconds,
    required this.recentRun,
    required this.monthlySummaries,
  });

  final int totalRuns;
  final int totalDistanceInMeters;
  final int totalDurationInSeconds;
  final double averagePace;
  final int longestDistanceInMeters;
  final double fastestAveragePace;
  final int longestDurationInSeconds;
  final Run? recentRun;
  final List<MonthlySummary> monthlySummaries;
}

class MonthlySummary {
  MonthlySummary({
    required this.monthKey,
    required this.monthLabel,
    required this.runCount,
    required this.totalDistanceInMeters,
  });

  final DateTime monthKey;
  final String monthLabel;
  final int runCount;
  final int totalDistanceInMeters;
}

class StatisticsService {
  static StatisticsSummary calculate(List<Run> runs) {
    if (runs.isEmpty) {
      return StatisticsSummary(
        totalRuns: 0,
        totalDistanceInMeters: 0,
        totalDurationInSeconds: 0,
        averagePace: 0.0,
        longestDistanceInMeters: 0,
        fastestAveragePace: 0.0,
        longestDurationInSeconds: 0,
        recentRun: null,
        monthlySummaries: const <MonthlySummary>[],
      );
    }

    var totalDistanceInMeters = 0;
    var totalDurationInSeconds = 0;
    var totalPace = 0.0;
    var longestDistanceInMeters = 0;
    var fastestAveragePace = double.infinity;
    var longestDurationInSeconds = 0;
    Run? recentRun;

    final monthlyMap = <String, _MonthlyAccumulator>{};

    for (final run in runs) {
      totalDistanceInMeters += run.distanceInMeters.toInt();
      totalDurationInSeconds += run.durationInSeconds;
      totalPace += run.averagePace;

      if (run.distanceInMeters > longestDistanceInMeters) {
        longestDistanceInMeters = run.distanceInMeters.toInt();
      }

      if (run.averagePace > 0 && run.averagePace < fastestAveragePace) {
        fastestAveragePace = run.averagePace;
      }

      if (run.durationInSeconds > longestDurationInSeconds) {
        longestDurationInSeconds = run.durationInSeconds;
      }

      final currentRecent = recentRun;
      if (currentRecent == null || run.date.isAfter(currentRecent.date)) {
        recentRun = run;
      }

      final monthKey = DateTime(run.date.year, run.date.month);
      final monthKeyText =
          '${monthKey.year}-${monthKey.month.toString().padLeft(2, '0')}';
      final accumulator = monthlyMap.putIfAbsent(
        monthKeyText,
        () => _MonthlyAccumulator(monthKey: monthKey),
      );
      accumulator.runCount += 1;
      accumulator.totalDistanceInMeters += run.distanceInMeters.toInt();
    }

    final monthlySummaries =
        monthlyMap.values
            .map(
              (accumulator) => MonthlySummary(
                monthKey: accumulator.monthKey,
                monthLabel: _formatMonthLabel(accumulator.monthKey),
                runCount: accumulator.runCount,
                totalDistanceInMeters: accumulator.totalDistanceInMeters,
              ),
            )
            .toList()
          ..sort((a, b) => b.monthKey.compareTo(a.monthKey));

    return StatisticsSummary(
      totalRuns: runs.length,
      totalDistanceInMeters: totalDistanceInMeters,
      totalDurationInSeconds: totalDurationInSeconds,
      averagePace: runs.isEmpty ? 0.0 : totalPace / runs.length,
      longestDistanceInMeters: longestDistanceInMeters,
      fastestAveragePace: fastestAveragePace == double.infinity
          ? 0.0
          : fastestAveragePace,
      longestDurationInSeconds: longestDurationInSeconds,
      recentRun: recentRun,
      monthlySummaries: monthlySummaries,
    );
  }

  static String _formatMonthLabel(DateTime monthKey) {
    final monthName = _monthNames[monthKey.month - 1];
    return '$monthName ${monthKey.year}';
  }

  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}

class _MonthlyAccumulator {
  _MonthlyAccumulator({required this.monthKey});

  final DateTime monthKey;
  int runCount = 0;
  int totalDistanceInMeters = 0;
}
