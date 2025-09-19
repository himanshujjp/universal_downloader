/// Represents the result of a download operation
class DownloadResult {
  /// The file path where the file was saved
  final String filePath;

  /// The original URL that was downloaded
  final String url;

  /// The filename used for saving
  final String fileName;

  /// Total bytes downloaded
  final int totalBytes;

  /// Whether the download was successful
  final bool isSuccess;

  /// Error message if download failed
  final String? errorMessage;

  const DownloadResult({
    required this.filePath,
    required this.url,
    required this.fileName,
    required this.totalBytes,
    required this.isSuccess,
    this.errorMessage,
  });

  /// Creates a successful download result
  factory DownloadResult.success({
    required String filePath,
    required String url,
    required String fileName,
    required int totalBytes,
  }) {
    return DownloadResult(
      filePath: filePath,
      url: url,
      fileName: fileName,
      totalBytes: totalBytes,
      isSuccess: true,
    );
  }

  /// Creates a failed download result
  factory DownloadResult.failure({
    required String url,
    required String fileName,
    required String errorMessage,
  }) {
    return DownloadResult(
      filePath: '',
      url: url,
      fileName: fileName,
      totalBytes: 0,
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'DownloadResult(filePath: $filePath, url: $url, fileName: $fileName, totalBytes: $totalBytes, isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DownloadResult &&
        other.filePath == filePath &&
        other.url == url &&
        other.fileName == fileName &&
        other.totalBytes == totalBytes &&
        other.isSuccess == isSuccess &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return filePath.hashCode ^
        url.hashCode ^
        fileName.hashCode ^
        totalBytes.hashCode ^
        isSuccess.hashCode ^
        errorMessage.hashCode;
  }
}
