import 'dart:typed_data';

/// Stub implementation for native platforms (IO)
/// These functions are only meant to be used on web platform

/// Downloads a file from a stream - not supported on native platforms
Future<void> downloadFromStream(Stream<int> stream, String filename) async {
  throw UnsupportedError(
      'downloadFromStream is only supported on web platform');
}

/// Downloads a file from URL - not supported on native platforms
Future<void> downloadFromUrl(String url, [String? filename]) async {
  throw UnsupportedError('downloadFromUrl is only supported on web platform');
}

/// Downloads data - not supported on native platforms
Future<void> downloadData(Uint8List data, String filename) async {
  throw UnsupportedError('downloadData is only supported on web platform');
}

/// Web-specific download implementation
/// This function triggers a browser download using Blob and anchor element
Future<void> triggerWebDownload(Uint8List bytes, String fileName) async {
  // This is a stub for native platforms
  // The actual web implementation will be in web_downloader.dart
  throw UnsupportedError('Web download is not supported on this platform');
}
