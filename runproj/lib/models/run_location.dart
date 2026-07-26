import 'package:hive/hive.dart';

part 'run_location.g.dart';

@HiveType(typeId: 1)
class RunLocation extends HiveObject {
  RunLocation({required this.latitude, required this.longitude});

  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;
}
