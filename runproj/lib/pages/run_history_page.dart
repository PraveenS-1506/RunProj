import 'package:flutter/material.dart';

import '../models/run.dart';
import '../services/run_storage.dart';
import '../utils/run_formatters.dart';
import 'run_details_page.dart';

class RunHistoryPage extends StatefulWidget {
  const RunHistoryPage({super.key, this.initialRunsFuture});

  final Future<List<Run>>? initialRunsFuture;

  @override
  State<RunHistoryPage> createState() => _RunHistoryPageState();
}

class _RunHistoryPageState extends State<RunHistoryPage>
    with WidgetsBindingObserver {
  final RunStorage _runStorage = RunStorage();
  late Future<List<Run>> _runsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runsFuture = widget.initialRunsFuture ?? Future.value(const <Run>[]);
    if (widget.initialRunsFuture == null) {
      _loadRuns();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadRuns();
    }
  }

  void _loadRuns() {
    setState(() {
      _runsFuture = _runStorage.getRuns();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run History')),
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
                  'Unable to load runs: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final runs = snapshot.data ?? <Run>[];

          if (runs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No runs yet. Start your first run!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: runs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final run = runs[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => RunDetailsPage(run: run),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          RunFormatters.formatDate(run.date),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _RunDetailItem(
                                label: 'Distance',
                                value: RunFormatters.formatDistance(
                                  run.distanceInMeters,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _RunDetailItem(
                                label: 'Duration',
                                value: RunFormatters.formatDuration(
                                  run.durationInSeconds,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _RunDetailItem(
                          label: 'Avg Pace',
                          value: RunFormatters.formatPace(run.averagePace),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RunDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _RunDetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
