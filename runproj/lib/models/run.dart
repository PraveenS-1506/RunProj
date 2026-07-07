import 'package:hive/hive.dart';

part 'run.g.dart';

@HiveType(typeId: 0)
class Run extends HiveObject {
  Run({
    required this.date,
    required this.durationInSeconds,
    required this.distanceInMeters,
    required this.averagePace,
  });

  factory Run.completed({
    required DateTime date,
    required int durationInSeconds,
    required double distanceInMeters,
  }) {
    final averagePace = durationInSeconds > 0 && distanceInMeters > 0
        ? durationInSeconds / 60 / (distanceInMeters / 1000)
        : 0.0;

    return Run(
      date: date,
      durationInSeconds: durationInSeconds,
      distanceInMeters: distanceInMeters,
      averagePace: averagePace,
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
}
