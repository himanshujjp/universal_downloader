/// Represents the progress of a download operation
class DownloadProgress {
  /// Total bytes to be downloaded
  final int totalBytes;

  /// Bytes downloaded so far
  final int downloadedBytes;

  /// Progress percentage (0.0 to 100.0)
  final double percentage;

  /// Download speed in bytes per second
  final double? speed;

  const DownloadProgress({
    required this.totalBytes,
    required this.downloadedBytes,
    required this.percentage,
    this.speed,
  });

  /// Creates a DownloadProgress instance from bytes
  factory DownloadProgress.fromBytes({
    required int totalBytes,
    required int downloadedBytes,
    double? speed,
  }) {
    final percentage =
        totalBytes > 0 ? (downloadedBytes / totalBytes) * 100 : 0.0;
    return DownloadProgress(
      totalBytes: totalBytes,
      downloadedBytes: downloadedBytes,
      percentage: percentage,
      speed: speed,
    );
  }

  @override
  String toString() {
    return 'DownloadProgress(totalBytes: $totalBytes, downloadedBytes: $downloadedBytes, percentage: ${percentage.toStringAsFixed(2)}%, speed: $speed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DownloadProgress &&
        other.totalBytes == totalBytes &&
        other.downloadedBytes == downloadedBytes &&
        other.percentage == percentage &&
        other.speed == speed;
  }

  @override
  int get hashCode {
    return totalBytes.hashCode ^
        downloadedBytes.hashCode ^
        percentage.hashCode ^
        speed.hashCode;
  }
}
