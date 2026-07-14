import 'package:flutter/material.dart';

import '../models/run.dart';
import '../utils/run_formatters.dart';

class RunDetailsPage extends StatelessWidget {
  const RunDetailsPage({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run Details')),
      body: SafeArea(
        child: Padding( 
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_run, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Run Summary',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _InfoTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Date & Time',
                        value: RunFormatters.formatDate(run.date),
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.straighten,
                        title: 'Distance',
                        value: RunFormatters.formatDistance(
                          run.distanceInMeters,
                        ),
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.timer_outlined,
                        title: 'Duration',
                        value: RunFormatters.formatDuration(
                          run.durationInSeconds,
                        ),
                      ),
                      const Divider(height: 24),
                      _InfoTile(
                        icon: Icons.speed,
                        title: 'Average Pace',
                        value: RunFormatters.formatPace(run.averagePace),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
