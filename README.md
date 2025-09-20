# Universal Downloader

[![pub package](https://img.shields.io/pub/v/universal_downloader.svg)](https://pub.dartlang.org/packages/universal_downloader)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter package for downloading files on **all platforms**: Android, iOS, Web, Windows, macOS, and Linux.

**Supports ALL file types** - PDFs, music, videos, documents, archives, images, and any other format without restrictions.

## Features

✅ **Universal Compatibility**: Works on all Flutter platforms  
✅ **All File Types Supported**: PDFs, music, videos, documents, archives, images, and any format  
✅ **Progress Tracking**: Real-time download progress callbacks  
✅ **Platform-Optimized Storage**: Uses appropriate directories for each platform  
✅ **Automatic Permissions**: Handles storage permissions for mobile platforms  
✅ **Error Handling**: Comprehensive error reporting and recovery  
✅ **Simple API**: Easy-to-use interface with intuitive callbacks  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  universal_downloader: ^1.0.6
```

Then run:

```bash
flutter pub get
```

## Usage

### 🚀 **RECOMMENDED: downloadFromUrlStream()** (Best for all use cases)

Use `downloadFromUrlStream()` for **all downloads** - it's memory efficient, reliable, and works perfectly across all platforms:

```dart
import 'package:universal_downloader/universal_downloader.dart';

// RECOMMENDED: Use this for all downloads
final result = await UniversalDownloader.downloadFromUrlStream(
  url: "https://example.com/file.zip",
  filename: "file.zip",
  onProgress: (progress) {
    print("Progress: ${progress.percentage.toStringAsFixed(1)}%");
    print("Downloaded: ${progress.downloadedBytes}/${progress.totalBytes} bytes");
  },
  onComplete: (filePath) {
    print("✅ Download completed: $filePath");
  },
  onError: (error) {
    print("❌ Download failed: $error");
  },
);

if (result.isSuccess) {
  print("File saved at: ${result.filePath}");
} else {
  print("Error: ${result.errorMessage}");
}
```

### Simple Download (Basic)

```dart
import 'package:universal_downloader/universal_downloader.dart';

// Basic download without progress tracking
await UniversalDownloader.downloadFile(
  url: "https://example.com/file.pdf",
  fileName: "document.pdf",
);
```

## Platform Support

| Platform | Storage Location | Progress Tracking |
|----------|------------------|-------------------|
| **Android** | Downloads/Documents directory | ✅ |
| **iOS** | Documents directory | ✅ |
| **Web** | Browser downloads | ✅ |
| **Windows** | Downloads folder | ✅ |
| **macOS** | Downloads folder | ✅ |
| **Linux** | Downloads folder | ✅ |

## Mobile Permissions

The package automatically handles storage permissions for mobile platforms. Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

### Web Download (Enhanced for PDFs/Music)

For web-optimized downloads, use `downloadUrl()` which uses the browser's native download mechanism:

```dart
import 'package:universal_downloader/universal_downloader.dart';

// Web-optimized download using browser's native mechanism
await UniversalDownloader.downloadUrl(
  url: "https://example.com/song.mp3",
  filename: "song.mp3",
);
```

**Note:** On native platforms, `downloadUrl()` automatically falls back to `downloadFromUrlStream()` for better compatibility.

## API Reference

### Core Methods

#### `downloadFromUrlStream()` - **🚀 RECOMMENDED**
Downloads files with streaming for better memory efficiency and progress tracking.

```dart
static Future<DownloadResult> downloadFromUrlStream({
  required String url,
  required String filename,
  ProgressCallback? onProgress,
  CompleteCallback? onComplete,
  ErrorCallback? onError,
  bool allowSelfSignedCertificate = false,
})
```

#### `downloadFile()`
Simple file download with optional progress tracking and callbacks.

```dart
static Future<DownloadResult> downloadFile({
  required String url,
  required String fileName,
  ProgressCallback? onProgress,
  CompleteCallback? onComplete,
  ErrorCallback? onError,
  bool saveToDocuments = false,
  bool allowSelfSignedCertificate = false,
})
```

#### `downloadStream()`
Downloads a file from a Stream<int> and saves it with the given filename.

```dart
static Future<void> downloadStream({
  required Stream<int> stream,
  required String filename,
})
```

#### `downloadData()`
Downloads a file from binary data (Uint8List) and saves it with the given filename.

```dart
static Future<void> downloadData({
  required Uint8List data,
  required String filename,
})
```

#### `downloadUrl()`
Downloads a file directly from a URL. Web-optimized, uses browser's native download.

```dart
static Future<void> downloadUrl({
  required String url,
  String? filename,
})
```

### Utility Getters

#### `supportsDirectorySelection`
Checks if the current platform supports directory selection.

```dart
static bool get supportsDirectorySelection
```

#### `supportsProgressTracking`
Checks if the current platform supports progress tracking.

```dart
static bool get supportsProgressTracking
```

#### `platformName`
Gets the current platform name.

```dart
static String get platformName
```

### Models

#### DownloadProgress
```dart
class DownloadProgress {
  final int totalBytes;
  final int downloadedBytes;
  final double percentage;
  final double? speed;
}
```

#### DownloadResult
```dart
class DownloadResult {
  final String filePath;
  final String url;
  final String fileName;
  final int totalBytes;
  final bool isSuccess;
  final String? errorMessage;
}
```

## Error Handling

```dart
try {
  await UniversalDownloader.downloadFromUrlStream(
    url: "https://example.com/file.zip",
    filename: "file.zip",
  );
} on NetworkDownloadException catch (e) {
  print("Network error: $e");
} on PermissionDownloadException catch (e) {
  print("Permission error: $e");
} on DownloadException catch (e) {
  print("Download error: $e");
}
```

## Example

Check out the [example](example/) directory for a complete Flutter app:

```bash
cd example
flutter pub get
flutter run
```

## Changelog

### 1.0.6
- **Release**: Complete API documentation update
- **Updated**: README.md with all core methods and their signatures
- **Added**: Comprehensive method documentation for downloadStream, downloadData, downloadUrl
- **Fixed**: Web download example to use correct method (downloadUrl instead of non-existent downloadWebFile)
- **Enhanced**: API reference section with complete method signatures and parameters

### 1.0.5
- **Release**: Documentation update with enhanced README
- **Updated**: README.md with clearer method recommendations
- **Improved**: `downloadFromUrlStream()` prominently featured as recommended method
- **Enhanced**: Usage examples and platform support documentation

### 1.0.4
- **Release**: Enhanced documentation with clear recommendations
- **Updated**: `downloadFromUrlStream()` prominently featured as recommended method
- **Improved**: README structure and examples for better user experience
- **Fixed**: Version consistency across all documentation

### 1.0.3
- **Release**: Proper 1.0.3 release with complete platform support
- **Fixed**: All platform support issues resolved for pub.dev scoring
- **Updated**: Documentation and changelog for proper release
- **Verified**: All 6 platforms (Android, iOS, Web, Windows, macOS, Linux) fully supported

### 1.0.2
- **Release**: Platform support fixes and documentation updates
- **Fixed**: Added explicit platform declarations for better pub.dev detection
- **Updated**: CHANGELOG.md and README.md with platform support details
- **Improved**: Package metadata and documentation

### 1.0.1
- **Fixed**: Web downloader supports all file types without restrictions
- **Fixed**: Resolved CORS detection issues in web downloads
- **Fixed**: Corrected filename corruption in web downloads
- **Improved**: Enhanced error handling for web download failures
- **Improved**: Simplified download logic for better reliability

### 1.0.0
- **Initial Release** with full platform support
- Support for all Flutter platforms (Android, iOS, Web, Windows, macOS, Linux)
- Real-time download progress tracking
- Platform-optimized storage locations
- Comprehensive error handling
- Web support with enhanced CORS handling
- Easy-to-use API with callback support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
