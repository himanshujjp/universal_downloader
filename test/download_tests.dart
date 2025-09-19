import 'package:universal_downloader/universal_downloader.dart';
import 'test_urls.dart';

/// Test script to download various file types
Future<void> testAllDownloads() async {
  print('🚀 Starting comprehensive download tests...\n');

  for (final entry in TestUrls.allTests.entries) {
    final filename = entry.key;
    final url = entry.value;

    print('📁 Testing: $filename from $url');

    try {
      final result = await UniversalDownloader.downloadFile(
        url: url,
        fileName: filename,
      );

      if (result.isSuccess) {
        print('✅ SUCCESS: $filename downloaded successfully\n');
      } else {
        print('❌ FAILED: $filename - Error: ${result.errorMessage}\n');
      }
    } catch (e) {
      print('❌ FAILED: $filename - Error: $e\n');
    }

    // Small delay between tests
    await Future.delayed(const Duration(seconds: 2));
  }

  print('🎉 Download tests completed!');
}

/// Test individual file types
Future<void> testJson() async {
  final result = await UniversalDownloader.downloadFile(
    url: TestUrls.jsonTest,
    fileName: 'test.json',
  );
  print('JSON Test Result: ${result.isSuccess ? "SUCCESS" : "FAILED"}');
}

Future<void> testImage() async {
  final result = await UniversalDownloader.downloadFile(
    url: TestUrls.pngTest,
    fileName: 'test.png',
  );
  print('Image Test Result: ${result.isSuccess ? "SUCCESS" : "FAILED"}');
}

Future<void> testPdf() async {
  final result = await UniversalDownloader.downloadFile(
    url: TestUrls.pdfTest,
    fileName: 'sample.pdf',
  );
  print('PDF Test Result: ${result.isSuccess ? "SUCCESS" : "FAILED"}');
}

Future<void> testMp3() async {
  final result = await UniversalDownloader.downloadFile(
    url: TestUrls.mp3Test,
    fileName: 'test.mp3',
  );
  print('MP3 Test Result: ${result.isSuccess ? "SUCCESS" : "FAILED"}');
}

Future<void> testMp3Alternative() async {
  final result = await UniversalDownloader.downloadFile(
    url: TestUrls.mp3Test2,
    fileName: 'sample_audio.mp3',
  );
  print(
      'MP3 Alternative Test Result: ${result.isSuccess ? "SUCCESS" : "FAILED"}');
}

/// Test CORS-restricted server specifically
Future<void> testCorsRestrictedPdf() async {
  print('🧪 Testing CORS-restricted PDF download...');
  final result = await UniversalDownloader.downloadFile(
    url: TestUrls.pdfTest,
    fileName: 'cors_test.pdf',
  );
  print('CORS PDF Test Result: ${result.isSuccess ? "SUCCESS" : "FAILED"}');
  if (!result.isSuccess) {
    print('Error: ${result.errorMessage}');
  }
}
