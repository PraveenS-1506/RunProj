import 'package:flutter/material.dart';

import '../models/run.dart';
import '../services/run_storage.dart';
import '../services/statistics_service.dart';
import '../utils/run_formatters.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final RunStorage _runStorage = RunStorage();
  late Future<List<Run>> _runsFuture;

  @override
  void initState() {
    super.initState();
    _runsFuture = _loadRuns();
  }

  Future<List<Run>> _loadRuns() async {
    final runs = await _runStorage.getRuns();
    return runs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: FutureBuilder<List<Run>>(
        future: _runsFuture,
        initialData: const <Run>[],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Unable to load stats: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final runs = snapshot.data ?? <Run>[];
          final summary = StatisticsService.calculate(runs);

          if (runs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Running Snapshot',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A quick overview of your progress and milestones.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              _buildOverviewSection(context, summary),
              const SizedBox(height: 24),
              _buildPersonalRecordsSection(context, summary),
              const SizedBox(height: 24),
              _buildRecentActivitySection(context, summary),
              const SizedBox(height: 24),
              _buildMonthlySummarySection(context, summary),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insights_outlined,
                  size: 64,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 16),
                Text(
                  'No runs recorded yet.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your first run to see your statistics here.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    StatisticsSummary summary,
  ) {
    final cards = <_StatCardData>[
      _StatCardData(
        'Total Runs',
        summary.totalRuns.toString(),
        Icons.directions_run,
      ),
      _StatCardData(
        'Total Distance',
        RunFormatters.formatDistance(summary.totalDistanceInMeters.toDouble()),
        Icons.straighten,
      ),
      _StatCardData(
        'Total Running Time',
        RunFormatters.formatDuration(summary.totalDurationInSeconds),
        Icons.timer,
      ),
      _StatCardData(
        'Avg Pace',
        RunFormatters.formatPace(summary.averagePace),
        Icons.speed,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards.map((card) => _StatCard(card: card)).toList(),
    );
  }

  Widget _buildPersonalRecordsSection(
    BuildContext context,
    StatisticsSummary summary,
  ) {
    final records = <_InfoRowData>[
      _InfoRowData(
        'Longest Run',
        _formatDistance(summary.longestDistanceInMeters),
      ),
      _InfoRowData('Fastest Avg Pace', _formatPace(summary.fastestAveragePace)),
      _InfoRowData(
        'Longest Duration',
        _formatDuration(summary.longestDurationInSeconds),
      ),
    ];

    return _DashboardSection(
      title: 'Personal Records',
      icon: Icons.emoji_events_outlined,
      child: Column(
        children: records
            .map((record) => _InfoRow(label: record.label, value: record.value))
            .toList(),
      ),
    );
  }

  Widget _buildRecentActivitySection(
    BuildContext context,
    StatisticsSummary summary,
  ) {
    final recentRun = summary.recentRun;

    return _DashboardSection(
      title: 'Recent Activity',
      icon: Icons.history_outlined,
      child: recentRun == null
          ? const _InfoRow(label: 'Most Recent Run', value: '--')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most Recent Run',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Date',
                  value: RunFormatters.formatDate(recentRun.date),
                ),
                _InfoRow(
                  label: 'Distance',
                  value: RunFormatters.formatDistance(
                    recentRun.distanceInMeters,
                  ),
                ),
                _InfoRow(
                  label: 'Duration',
                  value: RunFormatters.formatDuration(
                    recentRun.durationInSeconds,
                  ),
                ),
                _InfoRow(
                  label: 'Average Pace',
                  value: RunFormatters.formatPace(recentRun.averagePace),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthlySummarySection(
    BuildContext context,
    StatisticsSummary summary,
  ) {
    return _DashboardSection(
      title: 'Monthly Summary',
      icon: Icons.calendar_month_outlined,
      child: Column(
        children: summary.monthlySummaries.map((monthSummary) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthSummary.monthLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${monthSummary.runCount} Runs',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    RunFormatters.formatDistance(
                      monthSummary.totalDistanceInMeters.toDouble(),
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDistance(int meters) {
    return meters > 0 ? RunFormatters.formatDistance(meters.toDouble()) : '--';
  }

  String _formatPace(double pace) {
    return pace > 0 ? RunFormatters.formatPace(pace) : '--';
  }

  String _formatDuration(int seconds) {
    return seconds > 0 ? RunFormatters.formatDuration(seconds) : '--';
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.card});

  final _StatCardData card;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(card.icon, color: Colors.deepOrange),
            const SizedBox(height: 8),
            Text(card.title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              card.value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _StatCardData {
  const _StatCardData(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;
}

class _InfoRowData {
  const _InfoRowData(this.label, this.value);

  final String label;
  final String value;
}
