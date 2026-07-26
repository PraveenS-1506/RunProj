import 'package:hive/hive.dart';
import 'run_location.dart';

part 'run.g.dart';

@HiveType(typeId: 0)
class Run extends HiveObject {
  Run({
    required this.date,
    required this.durationInSeconds,
    required this.distanceInMeters,
    required this.averagePace,
    required this.route,
  });

  factory Run.completed({
    required DateTime date,
    required int durationInSeconds,
    required double distanceInMeters,
    required List<RunLocation> route,
  }) {
    final averagePace = durationInSeconds > 0 && distanceInMeters > 0
        ? durationInSeconds / 60 / (distanceInMeters / 1000)
        : 0.0;

    return Run(
      date: date,
      durationInSeconds: durationInSeconds,
      distanceInMeters: distanceInMeters,
      averagePace: averagePace,
      route: route,
    );
  }

  bool get isValid => durationInSeconds > 0 && distanceInMeters > 0;

  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int durationInSeconds;

  @HiveField(2)
  double distanceInMeters;

  @HiveField(3)
  double averagePace;

  @HiveField(4)
  List<RunLocation> route;
}
