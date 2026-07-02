import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RunTrackingPage extends StatefulWidget {
  const RunTrackingPage({super.key});

  @override
  State<RunTrackingPage> createState() => _RunTrackingPageState();
}

enum RunState { idle, running, paused }

class _RunTrackingPageState extends State<RunTrackingPage> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  RunState _runState = RunState.idle;
  Position? _currentPosition;
  List<Position> _route = [];
  double _totalDistanceMeters = 0.0;
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> _startRun() async {
    setState(() {
      _runState = RunState.running;
      _elapsedSeconds = 0;
      _route = [];
      _totalDistanceMeters = 0.0;
      _currentPosition = null;
    });

    // Request permission and start location updates if allowed.
    final granted = await _ensureLocationPermission();
    if (granted) {
      _startLocationUpdates();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _pauseRun() {
    _timer?.cancel();
    _stopLocationUpdates();
    setState(() {
      _runState = RunState.paused;
    });
  }

  Future<void> _resumeRun() async {
    setState(() {
      _runState = RunState.running;
    });

    final granted = await _ensureLocationPermission();
    if (granted) {
      _startLocationUpdates();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopRun() {
    _timer?.cancel();
    _stopLocationUpdates();
    setState(() {
      _runState = RunState.idle;
      _elapsedSeconds = 0;
      _route = [];
      _totalDistanceMeters = 0.0;
      _currentPosition = null;
    });
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
      }
      return false;
    }

    return true;
  }

  void _startLocationUpdates() {
    _positionStreamSubscription?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen((
          position,
        ) {
          setState(() {
            if (_route.isNotEmpty) {
              final previousPosition = _route.last;
              final segmentDistance = Geolocator.distanceBetween(
                previousPosition.latitude,
                previousPosition.longitude,
                position.latitude,
                position.longitude,
              );
              _totalDistanceMeters += segmentDistance;
            }

            _route.add(position);
            _currentPosition = position;
          });
        });
  }

  void _stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDistance(double meters) {
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopLocationUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _StatItem(
              label: 'Distance',
              value: _formatDistance(_totalDistanceMeters),
            ),
            const Divider(height: 40),
            _StatItem(
              label: 'Duration',
              value: _formatDuration(_elapsedSeconds),
            ),
            const SizedBox(height: 12),
            _StatItem(
              label: 'Coordinates',
              value: _currentPosition != null
                  ? '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'
                  : '--, --',
            ),
            const Divider(height: 40),
            _StatItem(label: 'Average Pace', value: '--:--'),
            const Spacer(),
            if (_runState == RunState.idle) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _startRun();
                  },
                  child: const Text(
                    'START RUN',
                    style: TextStyle(fontSize: 18, letterSpacing: 1.2),
                  ),
                ),
              ),
            ] else if (_runState == RunState.running) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _pauseRun,
                  child: const Text(
                    'PAUSE',
                    style: TextStyle(fontSize: 18, letterSpacing: 1.2),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _resumeRun();
                        },
                        child: const Text(
                          'RESUME',
                          style: TextStyle(fontSize: 18, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _stopRun,
                        child: const Text(
                          'STOP',
                          style: TextStyle(fontSize: 18, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineLarge),
      ],
    );
  }
}
