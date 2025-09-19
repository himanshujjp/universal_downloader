import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'models/download_progress.dart';
import 'models/download_result.dart';
import 'exceptions/download_exception.dart';
import 'utils/permission_utils.dart';

// Conditional imports for platform-specific implementations
import 'platform/web_downloader.dart'
    if (dart.library.html) 'platform/web_downloader.dart'
    if (dart.library.io) 'platform/io_downloader.dart';

/// Callback function for download progress updates
typedef ProgressCallback = void Function(DownloadProgress progress);

/// Callback function for download completion
typedef CompleteCallback = void Function(String filePath);

/// Callback function for download errors
typedef ErrorCallback = void Function(String error);

/// Universal downloader that works on all Flutter platforms
class UniversalDownloader {
  UniversalDownloader._();

  /// Downloads a file from the given URL and saves it with the specified filename
  ///
  /// [url] - The URL to download from
  /// [fileName] - The name to save the file as
  /// [onProgress] - Optional callback for progress updates
  /// [onComplete] - Optional callback when download completes successfully
  /// [onError] - Optional callback when download fails
  /// [saveToDocuments] - Whether to save to Documents directory instead of Downloads (mobile only)
  /// [allowSelfSignedCertificate] - Whether to allow self-signed SSL certificates (native platforms only)
  ///
  /// Returns a Future<DownloadResult> with the download result
  static Future<DownloadResult> downloadFile({
    required String url,
    required String fileName,
    ProgressCallback? onProgress,
    CompleteCallback? onComplete,
    ErrorCallback? onError,
    bool saveToDocuments = false,
    bool allowSelfSignedCertificate = false,
  }) async {
    try {
      // Validate inputs
      if (url.isEmpty) {
        throw const DownloadException('URL cannot be empty');
      }
      if (fileName.isEmpty) {
        throw const DownloadException('Filename cannot be empty');
      }

      // Check storage permission for mobile platforms
      if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
        final hasPermission = await PermissionUtils.requestStoragePermission();
        if (!hasPermission) {
          throw PermissionDownloadException(
            PermissionUtils.getPermissionErrorMessage(),
            url: url,
          );
        }
      }

      // Use platform-specific implementation
      if (kIsWeb) {
        return await _downloadForWeb(
          url: url,
          fileName: fileName,
          onProgress: onProgress,
          onComplete: onComplete,
          onError: onError,
        );
      } else {
        return await _downloadForNative(
          url: url,
          fileName: fileName,
          onProgress: onProgress,
          onComplete: onComplete,
          onError: onError,
          saveToDocuments: saveToDocuments,
          allowSelfSignedCertificate: allowSelfSignedCertificate,
        );
      }
    } catch (e) {
      final errorMessage = e.toString();
      onError?.call(errorMessage);
      return DownloadResult.failure(
        url: url,
        fileName: fileName,
        errorMessage: errorMessage,
      );
    }
  }

  /// Platform-specific download for web
  static Future<DownloadResult> _downloadForWeb({
    required String url,
    required String fileName,
    ProgressCallback? onProgress,
    CompleteCallback? onComplete,
    ErrorCallback? onError,
  }) async {
    try {
      // For web platform, use the improved direct download method
      await downloadFromUrl(url, fileName);

      // Report success
      onProgress?.call(const DownloadProgress(
        totalBytes: 0,
        downloadedBytes: 0,
        percentage: 100.0,
      ));
      onComplete?.call(fileName);

      return DownloadResult.success(
        filePath: fileName,
        url: url,
        fileName: fileName,
        totalBytes: 0,
      );
    } catch (e) {
      String errorMessage = 'Download failed: ${e.toString()}';

      // Provide simple, helpful guidance
      errorMessage += '\n\n💡 Try these solutions:';
      errorMessage += '\n• Check if the URL is accessible in your browser';
      errorMessage += '\n• Right-click the URL and select "Save As"';
      errorMessage += '\n• Some servers block automatic downloads';

      onError?.call(errorMessage);
      return DownloadResult.failure(
        url: url,
        fileName: fileName,
        errorMessage: errorMessage,
      );
    }
  }

  /// Platform-specific download for native platforms using stream-based approach
  static Future<DownloadResult> _downloadForNative({
    required String url,
    required String fileName,
    ProgressCallback? onProgress,
    CompleteCallback? onComplete,
    ErrorCallback? onError,
    bool saveToDocuments = false,
    bool allowSelfSignedCertificate = false,
  }) async {
    try {
      // Get the appropriate directory for the platform
      final directory = await _getDownloadDirectory(saveToDocuments);
      final filePath = path.join(directory.path, fileName);

      // Create HTTP client with SSL certificate handling
      final client = _createHttpClient(allowSelfSignedCertificate);

      try {
        // Always use streaming approach for consistent performance
        final request = http.Request('GET', Uri.parse(url));

        // Add headers for better compatibility
        request.headers.addAll({
          'User-Agent':
              'UniversalDownloader/1.0.0 (Flutter ${io.Platform.operatingSystem})',
          'Accept': '*/*',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
        });

        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode != 200) {
          throw NetworkDownloadException(
            'Failed to download file: HTTP ${streamedResponse.statusCode}',
            url: url,
          );
        }

        // Stream-based download with progress tracking
        final totalBytes = streamedResponse.contentLength ?? 0;
        var downloadedBytes = 0;

        // Convert the HTTP stream to a Stream<int> for our downloadStream method
        final byteStream = streamedResponse.stream.expand((chunk) => chunk);

        // Create the file
        final file = io.File(filePath);
        final sink = file.openWrite();

        // Process stream with progress tracking
        await for (final byte in byteStream) {
          sink.add([byte]);
          downloadedBytes++;

          // Report progress periodically (every 1KB to avoid too many updates)
          if (downloadedBytes % 1024 == 0 || downloadedBytes == totalBytes) {
            if (totalBytes > 0) {
              onProgress?.call(DownloadProgress.fromBytes(
                totalBytes: totalBytes,
                downloadedBytes: downloadedBytes,
              ));
            }
          }
        }

        await sink.close();

        onComplete?.call(filePath);

        return DownloadResult.success(
          filePath: filePath,
          url: url,
          fileName: fileName,
          totalBytes: downloadedBytes,
        );
      } finally {
        client.close();
      }
    } catch (e) {
      String errorMessage = e.toString();

      // Add helpful error messages for native platforms
      if (errorMessage.contains('certificate') ||
          errorMessage.contains('SSL') ||
          errorMessage.contains('TLS')) {
        errorMessage +=
            '\n\n💡 Solution: SSL certificate error. Try:\n• Using HTTP instead of HTTPS for testing\n• Ensure the server has a valid SSL certificate\n• Check your system\'s certificate store';
      } else if (errorMessage.contains('SocketException') ||
          errorMessage.contains('Connection')) {
        errorMessage +=
            '\n\n💡 Solution: Network connection error. Try:\n• Check your internet connection\n• Verify the URL is accessible\n• Try a different URL';
      } else if (errorMessage.contains('FileSystemException')) {
        errorMessage +=
            '\n\n💡 Solution: File system error. Try:\n• Check write permissions to Downloads folder\n• Ensure sufficient disk space\n• Try a different filename';
      }

      onError?.call(errorMessage);
      return DownloadResult.failure(
        url: url,
        fileName: fileName,
        errorMessage: errorMessage,
      );
    }
  }

  /// Gets the appropriate download directory for the current platform
  static Future<io.Directory> _getDownloadDirectory(
      bool saveToDocuments) async {
    if (kIsWeb) {
      throw const DownloadException('Cannot get directory on web platform');
    }

    try {
      if (io.Platform.isAndroid || io.Platform.isIOS) {
        // Mobile platforms
        if (saveToDocuments) {
          return await getApplicationDocumentsDirectory();
        } else {
          // Try to get Downloads directory, fall back to Documents
          try {
            return await getDownloadsDirectory() ??
                await getApplicationDocumentsDirectory();
          } catch (e) {
            return await getApplicationDocumentsDirectory();
          }
        }
      } else {
        // Desktop platforms (Windows, macOS, Linux)
        return await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      throw FileSystemDownloadException(
        'Failed to get download directory: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Checks if the current platform supports directory selection
  static bool get supportsDirectorySelection {
    return !kIsWeb &&
        (io.Platform.isWindows || io.Platform.isMacOS || io.Platform.isLinux);
  }

  /// Checks if the current platform supports progress tracking
  static bool get supportsProgressTracking {
    return true; // All platforms support progress tracking
  }

  /// Gets the platform name
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (io.Platform.isAndroid) return 'Android';
    if (io.Platform.isIOS) return 'iOS';
    if (io.Platform.isWindows) return 'Windows';
    if (io.Platform.isMacOS) return 'macOS';
    if (io.Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Creates an HTTP client with optional SSL certificate bypass
  static http.Client _createHttpClient(bool allowSelfSignedCertificate) {
    if (kIsWeb) {
      return http.Client();
    }

    if (allowSelfSignedCertificate) {
      // Create HTTP client that bypasses SSL certificate verification
      final httpClient = io.HttpClient();
      httpClient.badCertificateCallback =
          (io.X509Certificate cert, String host, int port) {
        // Allow all certificates (including self-signed)
        return true;
      };

      // Set other useful properties for better connectivity
      httpClient.connectionTimeout = const Duration(seconds: 30);
      httpClient.idleTimeout = const Duration(seconds: 30);

      return _IOClientWrapper(httpClient);
    } else {
      return http.Client();
    }
  }

  /// Downloads a file from a stream and saves it to the given filename.
  /// Works on all platforms (web, mobile, desktop).
  static Future<void> downloadStream({
    required Stream<int> stream,
    required String filename,
  }) async {
    if (kIsWeb) {
      // Use web-specific downloader
      await downloadFromStream(stream, filename);
    } else {
      // On native platforms, write to file
      final dir = await getApplicationDocumentsDirectory();
      final file = io.File(path.join(dir.path, filename));
      final sink = file.openWrite();

      // Convert Stream<int> to the bytes that sink expects
      await for (final byte in stream) {
        sink.add([byte]);
      }

      await sink.close();
    }
  }

  /// Downloads a file from binary data (Uint8List) and saves it with the given filename.
  /// Works on all platforms (web, mobile, desktop).
  static Future<void> downloadData({
    required Uint8List data,
    required String filename,
  }) async {
    if (kIsWeb) {
      // Use web-specific downloader
      await triggerWebDownload(data, filename);
    } else {
      // On native platforms, write to file
      final dir = await getApplicationDocumentsDirectory();
      final file = io.File(path.join(dir.path, filename));
      await file.writeAsBytes(data);
    }
  }

  /// Downloads a file from URL using stream method with progress tracking.
  /// Works on all platforms and provides better memory efficiency.
  static Future<DownloadResult> downloadFromUrlStream({
    required String url,
    required String filename,
    ProgressCallback? onProgress,
    CompleteCallback? onComplete,
    ErrorCallback? onError,
    bool allowSelfSignedCertificate = false,
  }) async {
    try {
      // Check storage permission for mobile platforms
      if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
        final hasPermission = await PermissionUtils.requestStoragePermission();
        if (!hasPermission) {
          throw PermissionDownloadException(
            PermissionUtils.getPermissionErrorMessage(),
            url: url,
          );
        }
      }

      // For web platform, use the existing optimized download method
      if (kIsWeb) {
        return await _downloadForWeb(
          url: url,
          fileName: filename,
          onProgress: onProgress,
          onComplete: onComplete,
          onError: onError,
        );
      }

      // For native platforms, use stream-based approach
      // Create HTTP client
      final client = _createHttpClient(allowSelfSignedCertificate);

      try {
        // Make HTTP request to get stream
        final request = http.Request('GET', Uri.parse(url));
        request.headers.addAll({
          'User-Agent': 'UniversalDownloader/1.0.0 (Flutter Stream)',
          'Accept': '*/*',
        });

        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode != 200) {
          throw NetworkDownloadException(
            'Failed to download file: HTTP ${streamedResponse.statusCode}',
            url: url,
          );
        }

        final totalBytes = streamedResponse.contentLength ?? 0;
        var downloadedBytes = 0;

        // Convert HTTP stream to Stream<int> and track progress
        final streamController = StreamController<int>();

        streamedResponse.stream.listen(
          (chunk) {
            for (final byte in chunk) {
              streamController.add(byte);
              downloadedBytes++;
            }

            // Report progress
            if (totalBytes > 0 && onProgress != null) {
              onProgress(DownloadProgress.fromBytes(
                totalBytes: totalBytes,
                downloadedBytes: downloadedBytes,
              ));
            }
          },
          onDone: () {
            streamController.close();
          },
          onError: (error) {
            streamController.addError(error);
          },
        );

        // Use downloadStream to save the file
        await downloadStream(
          stream: streamController.stream,
          filename: filename,
        );

        onComplete?.call(filename);

        return DownloadResult.success(
          filePath: filename,
          url: url,
          fileName: filename,
          totalBytes: downloadedBytes,
        );
      } finally {
        client.close();
      }
    } catch (e) {
      final errorMessage = e.toString();
      onError?.call(errorMessage);
      return DownloadResult.failure(
        url: url,
        fileName: filename,
        errorMessage: errorMessage,
      );
    }
  }

  /// Downloads a file directly from a URL (web only - uses browser's native download).
  /// On native platforms, use downloadFromUrlStream() method instead.
  static Future<void> downloadUrl({
    required String url,
    String? filename,
  }) async {
    if (kIsWeb) {
      // Use web-specific downloader
      await downloadFromUrl(url, filename);
    } else {
      // On native platforms, use the stream-based method
      await downloadFromUrlStream(
        url: url,
        filename: filename ?? 'download.bin',
      );
    }
  }
}

/// Wrapper class for HttpClient to work with http.Client interface
class _IOClientWrapper extends http.BaseClient {
  final io.HttpClient _httpClient;

  _IOClientWrapper(this._httpClient);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final ioRequest = await _httpClient.openUrl(request.method, request.url);

    // Add headers
    request.headers.forEach((name, value) {
      ioRequest.headers.set(name, value);
    });

    // Add body if present
    if (request.contentLength != null) {
      ioRequest.contentLength = request.contentLength!;
    }

    if (request is http.Request) {
      ioRequest.write(request.body);
    } else if (request is http.StreamedRequest) {
      await request.finalize().pipe(ioRequest);
    }

    final ioResponse = await ioRequest.close();

    final headers = <String, String>{};
    ioResponse.headers.forEach((name, values) {
      headers[name] = values.join(',');
    });

    return http.StreamedResponse(
      ioResponse,
      ioResponse.statusCode,
      contentLength: ioResponse.contentLength,
      request: request,
      headers: headers,
      isRedirect: ioResponse.isRedirect,
      reasonPhrase: ioResponse.reasonPhrase,
    );
  }

  @override
  void close() {
    _httpClient.close();
  }
}
