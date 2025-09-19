import 'package:flutter_test/flutter_test.dart';
import 'package:universal_downloader/universal_downloader.dart';

void main() {
  group('UniversalDownloader', () {
    test('should provide platform information', () {
      expect(UniversalDownloader.platformName, isNotEmpty);
      expect(UniversalDownloader.supportsProgressTracking, isTrue);
    });

    test('DownloadProgress should calculate percentage correctly', () {
      final progress = DownloadProgress.fromBytes(
        totalBytes: 1000,
        downloadedBytes: 250,
      );

      expect(progress.percentage, equals(25.0));
      expect(progress.totalBytes, equals(1000));
      expect(progress.downloadedBytes, equals(250));
    });

    test('DownloadResult.success should create successful result', () {
      final result = DownloadResult.success(
        filePath: '/path/to/file.pdf',
        url: 'https://example.com/file.pdf',
        fileName: 'file.pdf',
        totalBytes: 1024,
      );

      expect(result.isSuccess, isTrue);
      expect(result.filePath, equals('/path/to/file.pdf'));
      expect(result.errorMessage, isNull);
    });

    test('DownloadResult.failure should create failed result', () {
      final result = DownloadResult.failure(
        url: 'https://example.com/file.pdf',
        fileName: 'file.pdf',
        errorMessage: 'Network error',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, equals('Network error'));
      expect(result.filePath, isEmpty);
    });

    test('DownloadException should format message correctly', () {
      const exception = DownloadException(
        'Test error',
        url: 'https://example.com/test',
      );

      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('https://example.com/test'));
    });
  });
}
