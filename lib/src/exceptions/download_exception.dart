/// Exception thrown when download operations fail
class DownloadException implements Exception {
  /// The error message
  final String message;

  /// The original URL that failed to download
  final String? url;

  /// The underlying error that caused this exception
  final dynamic cause;

  const DownloadException(
    this.message, {
    this.url,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('DownloadException: $message');
    if (url != null) {
      buffer.write(' (URL: $url)');
    }
    if (cause != null) {
      buffer.write(' (Cause: $cause)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when network-related errors occur during download
class NetworkDownloadException extends DownloadException {
  const NetworkDownloadException(
    super.message, {
    super.url,
    super.cause,
  });
}

/// Exception thrown when file system operations fail during download
class FileSystemDownloadException extends DownloadException {
  const FileSystemDownloadException(
    super.message, {
    super.url,
    super.cause,
  });
}

/// Exception thrown when permission-related errors occur during download
class PermissionDownloadException extends DownloadException {
  const PermissionDownloadException(
    super.message, {
    super.url,
    super.cause,
  });
}

/// Exception thrown when CORS policy blocks downloads in web browsers
class CorsDownloadException extends DownloadException {
  const CorsDownloadException(
    super.message, {
    super.url,
    super.cause,
  });
}
