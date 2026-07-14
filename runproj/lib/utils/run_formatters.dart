class RunFormatters {
  static String formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year} ${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
  }

  static String formatDistance(double meters) {
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String formatPace(double averagePace) {
    if (averagePace <= 0) {
      return '--:--';
    }

    final minutes = averagePace.floor();
    final seconds = ((averagePace - minutes) * 60).round();

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
