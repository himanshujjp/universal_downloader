# Mobile Storage Permissions

## Overview
The Universal Downloader package automatically handles storage permissions for mobile platforms (Android and iOS).

## Android Permissions

### Android 12 and Below (API 32 and below)
- Requires `WRITE_EXTERNAL_STORAGE` permission
- Requires `READ_EXTERNAL_STORAGE` permission

### Android 13+ (API 33+)
- Uses scoped storage by default
- Requires specific media permissions for accessing media files:
  - `READ_MEDIA_IMAGES`
  - `READ_MEDIA_VIDEO` 
  - `READ_MEDIA_AUDIO`

## iOS Permissions
- Downloads go to app-specific directories by default
- No special permissions required for app-specific storage

## Permission Handling

### Automatic Permission Requests
The `UniversalDownloader.downloadFile()` method automatically:
1. Checks if storage permission is required for the current platform
2. Requests permission if needed before starting download
3. Shows helpful error messages if permission is denied

### Manual Permission Management
You can also manually check and request permissions:

```dart
import 'package:universal_downloader/universal_downloader.dart';

// Check if permission is granted
bool hasPermission = await PermissionUtils.requestStoragePermission();

if (!hasPermission) {
  // Show error message to user
  String errorMessage = PermissionUtils.getPermissionErrorMessage();
  print(errorMessage);
}

// Check if we should show permission rationale
bool shouldShow = await PermissionUtils.shouldShowPermissionRationale();
if (shouldShow) {
  // Show explanation to user before requesting permission
}
```

## Error Handling

If permission is denied, the download will fail with a `PermissionDownloadException`:

```dart
try {
  await UniversalDownloader.downloadFile(
    url: 'https://example.com/file.pdf',
    fileName: 'document.pdf',
  );
} catch (e) {
  if (e is PermissionDownloadException) {
    // Handle permission error
    print('Permission required: ${e.message}');
  }
}
```

## Platform-Specific Behavior

### Web
- No permissions required
- Uses browser's download mechanism

### Desktop (Windows, macOS, Linux)
- No permissions required
- Downloads to user-selected directory or default Downloads folder

### Mobile (Android, iOS)
- Automatically requests required permissions
- Downloads to platform-appropriate directories
- Provides user-friendly error messages when permission is denied

## Android Manifest Configuration

The example app includes the necessary Android permissions in `android/app/src/main/AndroidManifest.xml`:

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

## Best Practices

1. **Always handle permission errors gracefully**
2. **Show clear messages to users about why permissions are needed**
3. **Test on different Android versions** (especially API 33+ vs older versions)
4. **Provide fallback options** when permissions are denied
5. **Use the built-in permission checking** in UniversalDownloader for automatic handling
