import 'package:hive/hive.dart';
import '../models/run.dart';

class RunStorage {
  static const String _boxName = 'runs';

  Future<Box<Run>> openBox() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RunAdapter());
    }

    return Hive.openBox<Run>(_boxName);
  }

  Future<List<Run>> getRuns() async {
    final box = await openBox();
    final runs = box.values.toList();
    runs.sort((a, b) => b.date.compareTo(a.date));
    return runs;
  }

  Future<void> addRun(Run run) async {
    final box = await openBox();
    await box.add(run);
  }

  Future<void> clearRuns() async {
    final box = await openBox();
    await box.clear();
  }
}
