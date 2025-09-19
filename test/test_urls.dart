// Test file for universal downloader
// This file contains test URLs for different file types

/// Test URLs for different file formats
class TestUrls {
  // JSON - Works well with blob methods
  static const String jsonTest = 'https://jsonplaceholder.typicode.com/posts/1';

  // PNG Image - Works with no-credentials XMLHttpRequest
  static const String pngTest = 'https://picsum.photos/seed/a3f9e2b4c1/800/600';

  // PDF - May have CORS issues, needs fallback methods
  static const String pdfTest =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  // MP3 Audio - Test for audio file downloads
  static const String mp3Test =
      'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';

  // Alternative MP3 URLs (if the first one doesn't work)
  static const String mp3Test2 =
      'https://file-examples.com/storage/fe8c7e4e16e2a0b9ba60e3e/2017/11/file_example_MP3_700KB.mp3';

  // Small MP3 for testing
  static const String mp3Test3 =
      'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3';

  /// Get all test URLs with their expected filenames
  static Map<String, String> get allTests => {
        'test.json': jsonTest,
        'test.png': pngTest,
        'sample.pdf': pdfTest,
        'test.mp3': mp3Test,
        'sample_audio.mp3': mp3Test2,
        'kalimba.mp3': mp3Test3,
      };
}
