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
✅ **Web Support**: Browser-based downloads with enhanced CORS handling  
✅ **SSL Support**: Bypass self-signed certificates on native platforms  
✅ **Type Safety**: Full Dart type safety with comprehensive models  

## Platform-Specific Behavior

| Platform | Storage Location | Progress Tracking | Notes |
|----------|------------------|-------------------|-------|
| **Android** | Downloads/Documents directory | ✅ | Uses `path_provider` |
| **iOS** | Documents directory | ✅ | Uses `path_provider` |
| **Web** | Browser downloads | ✅ | Enhanced download with multiple strategies |
| **Windows** | Downloads folder | ✅ | Uses system Downloads directory |
| **macOS** | Downloads folder | ✅ | Uses system Downloads directory |
| **Linux** | Downloads folder | ✅ | Uses system Downloads directory |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  universal_downloader: ^1.0.3
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:universal_downloader/universal_downloader.dart';

// Simple download
await UniversalDownloader.downloadFile(
  url: "https://example.com/file.pdf",
  fileName: "myfile.pdf",
);
```

### Advanced Usage with Callbacks

```dart
import 'package:universal_downloader/universal_downloader.dart';

final result = await UniversalDownloader.downloadFile(
  url: "https://example.com/largefile.zip",
  fileName: "largefile.zip",
  onProgress: (progress) {
    print("Progress: ${progress.percentage.toStringAsFixed(1)}%");
    print("Downloaded: ${progress.downloadedBytes}/${progress.totalBytes} bytes");
  },
  onComplete: (filePath) {
    print("File saved at: $filePath");
  },
  onError: (error) {
    print("Download failed: $error");
  },
  saveToDocuments: false, // Use Downloads folder (mobile only)
);

if (result.isSuccess) {
  print("Download completed: ${result.filePath}");
} else {
  print("Download failed: ${result.errorMessage}");
}
```

### Download from Stream

```dart
import 'package:universal_downloader/universal_downloader.dart';

// Download from a byte stream
await UniversalDownloader.downloadStream(
  stream: myByteStream,
  filename: "streamed_file.pdf",
);
```

### Download Binary Data

```dart
import 'package:universal_downloader/universal_downloader.dart';
import 'dart:typed_data';

// Download from binary data
Uint8List imageData = /* your image data */;
await UniversalDownloader.downloadData(
  data: imageData,
  filename: "image.png",
);
```

### Stream-based URL Download

```dart
import 'package:universal_downloader/universal_downloader.dart';

// More memory-efficient for large files
final result = await UniversalDownloader.downloadFromUrlStream(
  url: "https://example.com/largefile.zip",
  filename: "largefile.zip",
  onProgress: (progress) {
    print("Progress: ${progress.percentage.toStringAsFixed(1)}%");
  },
);
```

### Enhanced Web Download (Recommended for PDFs/Music)

```dart
import 'package:universal_downloader/universal_downloader.dart';

// Better handling for PDFs, music files, and media content
final result = await UniversalDownloader.downloadWebFile(
  url: "https://example.com/song.mp3",
  filename: "song.mp3",
  onComplete: (filePath) {
    print("Music file downloaded: $filePath");
  },
  onError: (error) {
    print("Download failed: $error");
  },
);
```

### Simple URL Download

```dart
import 'package:universal_downloader/universal_downloader.dart';

// Simple download without progress tracking
await UniversalDownloader.downloadUrl(
  url: "https://example.com/file.pdf",
  filename: "document.pdf", // Optional
);
```

### Platform Detection

```dart
// Check current platform
print("Current platform: ${UniversalDownloader.platformName}");

// Check platform capabilities
if (UniversalDownloader.supportsDirectorySelection) {
  print("This platform supports directory selection");
}

if (UniversalDownloader.supportsProgressTracking) {
  print("This platform supports progress tracking");
}
```

## Mobile Permissions

### Automatic Permission Handling

The Universal Downloader automatically handles storage permissions for mobile platforms:

```dart
// Permission is automatically requested before download starts
final result = await UniversalDownloader.downloadFile(
  url: "https://example.com/file.pdf",
  fileName: "document.pdf",
);

// If permission is denied, you'll get a PermissionDownloadException
```

### Manual Permission Management

You can also manually check and request permissions:

```dart
import 'package:universal_downloader/universal_downloader.dart';

// Check if permission is granted
bool hasPermission = await PermissionUtils.requestStoragePermission();

if (!hasPermission) {
  // Show error message to user
  String errorMessage = PermissionUtils.getPermissionErrorMessage();
  showDialog(/* show error dialog */);
}
```

### Required Android Permissions

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Internet permission for downloading files -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Storage permissions for Android 12 and below -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />

<!-- For Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

## API Reference

### UniversalDownloader.downloadFile()

Downloads a file from a URL and saves it locally.

**Parameters:**
- `url` (String, required): The URL to download from
- `fileName` (String, required): The filename to save as
- `onProgress` (ProgressCallback?, optional): Progress update callback
- `onComplete` (CompleteCallback?, optional): Success callback
- `onError` (ErrorCallback?, optional): Error callback
- `saveToDocuments` (bool, optional): Save to Documents instead of Downloads (mobile only)
- `allowSelfSignedCertificate` (bool, optional): Allow self-signed SSL certificates (native platforms only)

**Returns:** `Future<DownloadResult>`

### UniversalDownloader.downloadStream()

Downloads a file from a byte stream and saves it locally.

**Parameters:**
- `stream` (Stream<int>, required): The byte stream to download from
- `filename` (String, required): The filename to save as

**Returns:** `Future<void>`

### UniversalDownloader.downloadData()

Downloads a file from binary data and saves it locally.

**Parameters:**
- `data` (Uint8List, required): The binary data to save
- `filename` (String, required): The filename to save as

**Returns:** `Future<void>`

### UniversalDownloader.downloadFromUrlStream()

Downloads a file from a URL using streaming with progress tracking. More memory-efficient for large files.

**Parameters:**
- `url` (String, required): The URL to download from
- `filename` (String, required): The filename to save as
- `onProgress` (ProgressCallback?, optional): Progress update callback
- `onComplete` (CompleteCallback?, optional): Success callback
- `onError` (ErrorCallback?, optional): Error callback
- `allowSelfSignedCertificate` (bool, optional): Allow self-signed SSL certificates (native platforms only)

**Returns:** `Future<DownloadResult>`

### UniversalDownloader.downloadWebFile()

Enhanced web download method with better CORS and file type handling. Recommended for PDFs, music files, and other media content that browsers typically try to open instead of download.

**Parameters:**
- `url` (String, required): The URL to download from
- `fileName` (String, required): The filename to save as
- `onProgress` (ProgressCallback?, optional): Progress update callback
- `onComplete` (CompleteCallback?, optional): Success callback
- `onError` (ErrorCallback?, optional): Error callback

**Returns:** `Future<DownloadResult>`

**Example:**
```dart
import 'package:universal_downloader/universal_downloader.dart';

// Better for PDFs and music files
final result = await UniversalDownloader.downloadWebFile(
  url: "https://example.com/document.pdf",
  fileName: "document.pdf",
  onComplete: (filePath) {
    print("PDF downloaded successfully: $filePath");
  },
  onError: (error) {
    print("Download failed: $error");
  },
);
```

### Platform Properties

#### UniversalDownloader.platformName
Gets the current platform name as a string.

**Returns:** `String` ("Android", "iOS", "Web", "Windows", "macOS", "Linux", or "Unknown")

#### UniversalDownloader.supportsDirectorySelection
Checks if the current platform supports custom directory selection.

**Returns:** `bool` (true for Windows, macOS, Linux; false for Android, iOS, Web)

#### UniversalDownloader.supportsProgressTracking
Checks if the current platform supports download progress tracking.

**Returns:** `bool` (true for all platforms)

### Models

#### DownloadProgress
```dart
class DownloadProgress {
  final int totalBytes;        // Total bytes to download
  final int downloadedBytes;   // Bytes downloaded so far
  final double percentage;     // Progress percentage (0.0-100.0)
  final double? speed;         // Download speed (bytes/second)
}
```

#### DownloadResult
```dart
class DownloadResult {
  final String filePath;      // Where the file was saved
  final String url;           // Original download URL
  final String fileName;      // Filename used
  final int totalBytes;       // Total bytes downloaded
  final bool isSuccess;       // Whether download succeeded
  final String? errorMessage; // Error message if failed
}
```

### Callbacks

```dart
typedef ProgressCallback = void Function(DownloadProgress progress);
typedef CompleteCallback = void Function(String filePath);
typedef ErrorCallback = void Function(String error);
```

## Web Download Improvements

### Enhanced File Type Support
The web downloader now supports **ALL file types** without any restrictions:

- ✅ **PDF Files**: Enhanced handling to force download instead of opening in browser
- ✅ **Music Files**: MP3, WAV, OGG, and other audio formats
- ✅ **Video Files**: MP4, WebM, AVI, MOV, and other video formats
- ✅ **Document Files**: DOC, DOCX, XLS, XLSX, PPT, PPTX
- ✅ **Archive Files**: ZIP, RAR, 7Z, TAR, GZ
- ✅ **Image Files**: JPG, PNG, GIF, BMP, SVG, WEBP
- ✅ **All Other Formats**: Any file type is supported

### Universal Download Support
- **No file extension restrictions** - all file types work
- **Automatic file type detection** and optimal handling
- **Smart download strategies** based on file characteristics
- **Fallback mechanisms** for problematic scenarios

### Multiple Download Strategies
When standard download fails, the package now tries several fallback methods:

1. **Fetch + Base64**: Downloads file data and encodes it for reliable transfer
2. **Direct Link**: Creates download links with proper attributes
3. **Aggressive Methods**: Uses iframes and multiple anchor strategies for stubborn files
4. **Window Methods**: Falls back to window.open with download parameters

### CORS Handling
- Automatic detection of CORS issues
- Graceful fallback when cross-origin requests are blocked
- Better error messages with specific solutions

### Browser Compatibility
- Works across all modern browsers (Chrome, Firefox, Safari, Edge)
- Handles browser-specific quirks for different file types
- Provides clear feedback when manual intervention is needed

## Error Handling

The package provides comprehensive error handling with specific exception types:

```dart
try {
  await UniversalDownloader.downloadFile(
    url: "invalid-url",
    fileName: "test.pdf",
  );
} on NetworkDownloadException catch (e) {
  print("Network error: $e");
} on FileSystemDownloadException catch (e) {
  print("File system error: $e");
} on PermissionDownloadException catch (e) {
  print("Permission error: $e");
} on DownloadException catch (e) {
  print("General download error: $e");
}
```

## Example

Check out the [example](example/) directory for a complete Flutter app demonstrating all features of the universal_downloader package.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### 1.0.3
- **Release**: Proper 1.0.3 release with complete platform support
- **Fixed**: All platform support issues resolved for pub.dev scoring
- **Updated**: Documentation and changelog for proper release
- **Verified**: All 6 platforms (Android, iOS, Web, Windows, macOS, Linux) fully supported

### 1.0.0
- **Initial Release** with full platform support
- **Fixed**: Added explicit platform declarations for all 6 platforms (Android, iOS, Web, Windows, macOS, Linux)
- **Fixed**: Resolved pub.dev platform support detection issues
- Support for all Flutter platforms (Android, iOS, Web, Windows, macOS, Linux)
- Real-time download progress tracking with percentage and bytes
- Platform-optimized storage locations
- Comprehensive error handling with specific exception types
- Web support using browser download mechanism
- Easy-to-use API with callback support
- Complete example application
- Full documentation and usage examples
