import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// Conditional import for device_info_plus to avoid platform conflicts
import 'package:device_info_plus/device_info_plus.dart'
    if (dart.library.io) 'package:device_info_plus/device_info_plus.dart';

/// Utility class for handling platform-specific permissions
class PermissionUtils {
  /// Checks and requests storage permission for mobile platforms
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestStoragePermission() async {
    // Skip permission check for web and desktop platforms
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return true;
    }

    // For Android and iOS
    if (Platform.isAndroid || Platform.isIOS) {
      return await _requestMobileStoragePermission();
    }

    return true;
  }

  /// Handles storage permission request for mobile platforms
  static Future<bool> _requestMobileStoragePermission() async {
    try {
      Permission permission;

      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), we need specific permissions
        if (await _isAndroid13OrHigher()) {
          // For Android 13+, we don't need WRITE_EXTERNAL_STORAGE
          // Downloads go to app-specific directory or use SAF
          return true;
        } else {
          // For Android 12 and below
          permission = Permission.storage;
        }
      } else if (Platform.isIOS) {
        // For iOS, we typically use app documents directory
        // No special permission needed for app-specific directories
        return true;
      } else {
        return true;
      }

      // Check current permission status
      PermissionStatus status = await permission.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        // Request permission
        status = await permission.request();
        return status.isGranted;
      }

      if (status.isPermanentlyDenied) {
        // Show dialog to user to go to settings
        return false;
      }

      return false;
    } catch (e) {
      // If permission handling fails, return false
      return false;
    }
  }

  /// Check if Android version is 13 or higher (API 33+)
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    try {
      // Try to get device info, but don't fail if it's not available
      if (kIsWeb) return false; // Web doesn't have Android versions

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    } catch (e) {
      // If we can't get version info, assume older Android for safety
      // This ensures backward compatibility
      return false;
    }
  }

  /// Get a user-friendly permission error message
  static String getPermissionErrorMessage() {
    if (Platform.isAndroid) {
      return 'Storage permission is required to download files. '
          'Please grant storage permission in your device settings.';
    } else if (Platform.isIOS) {
      return 'File access permission is required to download files. '
          'Please grant file access permission in your device settings.';
    }
    return 'Permission is required to download files.';
  }

  /// Check if we should show permission rationale
  static Future<bool> shouldShowPermissionRationale() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return false;
    }

    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        return false; // No storage permission needed for Android 13+
      }
      return await Permission.storage.shouldShowRequestRationale;
    }

    return false;
  }
}
