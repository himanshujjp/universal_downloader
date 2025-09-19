// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';

/// Downloads a file from a [stream] into the destination [filename].
///
/// Uses base64 encoding which works reliably on web browsers.
/// - Works on all modern browsers
/// - Downloads directly without opening new tabs
Future<void> downloadFromStream(Stream<int> stream, String filename) async {
  filename = filename.replaceAll('/', '_').replaceAll('\\', '_');
  final bytes = await stream.toList();

  // Encode our file in base64
  final b64 = base64Encode(bytes);

  // Create the link with the file
  final anchor =
      html.AnchorElement(href: 'data:application/octet-stream;base64,$b64');

  // Add the name
  anchor.download = filename;

  // Trigger download
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

/// Downloads a file from a [url] into the destination [filename].
/// Uses blob-based download as primary method for maximum compatibility.
Future<void> downloadFromUrl(String url, [String? filename]) async {
  // Ensure filename is not null
  final actualFilename = filename ?? 'download.bin';
  final cleanFilename =
      actualFilename.replaceAll('/', '_').replaceAll('\\', '_');

  // Method 1: XMLHttpRequest Blob (Primary - most reliable for downloads)
  try {
    final request = html.HttpRequest();
    request.open('GET', url);
    request.responseType = 'blob';
    request.timeout = 30000;
    request.withCredentials = true;

    try {
      request.setRequestHeader('Accept', '*/*');
      request.setRequestHeader('Cache-Control', 'no-cache');
      request.setRequestHeader(
          'User-Agent', 'Mozilla/5.0 (compatible; UniversalDownloader)');
    } catch (headerError) {
      // Ignore header errors silently
    }

    final completer = Completer<void>();

    request.onLoad.listen((event) {
      if (request.status == 200 && request.response != null) {
        try {
          final blob = request.response as html.Blob;
          if (blob.size == 0) {
            completer.completeError(Exception('Empty response'));
            return;
          }

          final objectUrl = html.Url.createObjectUrl(blob);
          final anchor = html.AnchorElement(href: objectUrl)
            ..download = cleanFilename
            ..style.display = 'none'
            ..rel = 'noopener';

          anchor.setAttribute('download', cleanFilename);
          anchor.setAttribute('target', '_self');

          html.document.body?.append(anchor);

          Future.delayed(const Duration(milliseconds: 100), () {
            anchor.click();
          });

          Future.delayed(const Duration(milliseconds: 2000), () {
            html.Url.revokeObjectUrl(objectUrl);
            anchor.remove();
          });

          print('✅ Downloaded: $cleanFilename (${blob.size} bytes)');
          completer.complete();
        } catch (blobError) {
          completer.completeError(blobError);
        }
      } else {
        completer.completeError(Exception('HTTP ${request.status}'));
      }
    });

    request.onError.listen((event) {
      completer.completeError(Exception('Network error'));
    });

    request.onTimeout.listen((event) {
      completer.completeError(Exception('Timeout'));
    });

    request.send();
    await completer.future;
    return;
  } catch (e) {
    // Silently continue to next method
  }

  // Method 1.5: XMLHttpRequest Blob without credentials (fallback for CORS issues)
  try {
    final request = html.HttpRequest();
    request.open('GET', url);
    request.responseType = 'blob';
    request.timeout = 30000;
    request.withCredentials = false;

    try {
      request.setRequestHeader('Accept', '*/*');
    } catch (headerError) {
      // Ignore header errors
    }

    final completer = Completer<void>();

    request.onLoad.listen((event) {
      if (request.status == 200 && request.response != null) {
        try {
          final blob = request.response as html.Blob;
          if (blob.size == 0) {
            completer.completeError(Exception('Empty response'));
            return;
          }

          final objectUrl = html.Url.createObjectUrl(blob);
          final anchor = html.AnchorElement(href: objectUrl)
            ..download = cleanFilename
            ..style.display = 'none'
            ..rel = 'noopener';

          anchor.setAttribute('download', cleanFilename);
          anchor.setAttribute('target', '_self');

          html.document.body?.append(anchor);

          Future.delayed(const Duration(milliseconds: 100), () {
            anchor.click();
          });

          Future.delayed(const Duration(milliseconds: 2000), () {
            html.Url.revokeObjectUrl(objectUrl);
            anchor.remove();
          });

          print('✅ Downloaded: $cleanFilename (${blob.size} bytes)');
          completer.complete();
        } catch (blobError) {
          completer.completeError(blobError);
        }
      } else {
        completer.completeError(Exception('HTTP ${request.status}'));
      }
    });

    request.onError.listen((event) {
      completer.completeError(Exception('Network error'));
    });

    request.onTimeout.listen((event) {
      completer.completeError(Exception('Timeout'));
    });

    request.send();
    await completer.future;
    return;
  } catch (e) {
    // Silently continue to next method
  }

  // Method 2.5: Fetch API with no-cors mode (for PDFs and other restricted content)
  try {
    final response = await html.window.fetch(url, {
      'method': 'GET',
      'mode': 'no-cors',
    });

    try {
      final blob = await response.blob();

      if (blob.size == 0) {
        throw Exception('Empty response');
      }

      final objectUrl = html.Url.createObjectUrl(blob);

      final anchor = html.AnchorElement(href: objectUrl)
        ..download = cleanFilename
        ..style.display = 'none';

      anchor.setAttribute('download', cleanFilename);
      anchor.setAttribute('target', '_self');

      html.document.body?.append(anchor);

      Future.delayed(const Duration(milliseconds: 100), () {
        anchor.click();
      });

      Future.delayed(const Duration(milliseconds: 2000), () {
        html.Url.revokeObjectUrl(objectUrl);
        anchor.remove();
      });

      print('✅ Downloaded: $cleanFilename (${blob.size} bytes)');
      return;
    } catch (blobError) {
      // Silently continue to next method
    }
  } catch (e) {
    // Silently continue to next method
  }

  // Method 2.7: Special Fetch for media files (force download headers)
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.mp4') ||
        cleanFilename.toLowerCase().endsWith('.wav') ||
        cleanFilename.toLowerCase().endsWith('.m4a');

    if (isMediaFile) {
      final response = await html.window.fetch(url, {
        'method': 'GET',
        'headers': {
          'Accept': 'application/octet-stream, */*',
          'Cache-Control': 'no-cache',
        },
        'mode': 'cors',
      });

      if (response.status >= 200 && response.status < 300) {
        final blob = await response.blob();

        if (blob.size == 0) {
          throw Exception('Empty response');
        }

        final objectUrl = html.Url.createObjectUrl(blob);

        final anchor = html.AnchorElement(href: objectUrl)
          ..download = cleanFilename
          ..style.display = 'none'
          ..type = 'application/octet-stream';

        anchor.setAttribute('download', cleanFilename);
        anchor.setAttribute('target', '_blank');

        html.document.body?.append(anchor);

        Future.delayed(const Duration(milliseconds: 100), () {
          anchor.click();
        });

        Future.delayed(const Duration(milliseconds: 2000), () {
          html.Url.revokeObjectUrl(objectUrl);
          anchor.remove();
        });

        print('✅ Downloaded: $cleanFilename (${blob.size} bytes)');
        return;
      }
    }
  } catch (e) {
    // Silently continue to next method
  }

  // Method 2.8: Data URL approach for small media files
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.wav') ||
        cleanFilename.toLowerCase().endsWith('.m4a');

    if (isMediaFile) {
      final response = await html.window.fetch(url, {
        'method': 'GET',
        'mode': 'cors',
      });

      if (response.status >= 200 && response.status < 300) {
        final blob = await response.blob();

        if (blob.size == 0) {
          throw Exception('Empty response');
        }

        if (blob.size > 50 * 1024 * 1024) {
          throw Exception('File too large');
        }

        final reader = html.FileReader();
        reader.readAsDataUrl(blob);

        await reader.onLoad.first;

        final dataUrl = reader.result as String;

        final anchor = html.AnchorElement(href: dataUrl)
          ..download = cleanFilename
          ..style.display = 'none'
          ..type = 'application/octet-stream';

        anchor.setAttribute('download', cleanFilename);
        anchor.setAttribute('target', '_blank');

        html.document.body?.append(anchor);

        Future.delayed(const Duration(milliseconds: 100), () {
          anchor.click();
        });

        Future.delayed(const Duration(milliseconds: 1000), () {
          anchor.remove();
        });

        print('✅ Downloaded: $cleanFilename (${blob.size} bytes)');
        return;
      }
    }
  } catch (e) {
    // Silently continue to next method
  }

  // Method 3: Direct anchor download
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.mp4') ||
        cleanFilename.toLowerCase().endsWith('.avi') ||
        cleanFilename.toLowerCase().endsWith('.mov') ||
        cleanFilename.toLowerCase().endsWith('.wav');

    final anchor = html.AnchorElement(href: url)
      ..download = cleanFilename
      ..style.display = 'none'
      ..rel = 'noopener';

    if (isMediaFile) {
      anchor.setAttribute('target', '_blank');
      anchor.setAttribute('download', cleanFilename);
      anchor.attributes['download'] = cleanFilename;
    } else {
      anchor.setAttribute('target', '_self');
    }

    anchor.setAttribute('download', cleanFilename);

    html.document.body?.append(anchor);
    anchor.click();

    await Future.delayed(const Duration(milliseconds: 800));
    anchor.remove();

    print('✅ Downloaded: $cleanFilename');
    return;
  } catch (e) {
    // Silently continue to next method
  }

  // Method 3.5: Aggressive media file download
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.mp4') ||
        cleanFilename.toLowerCase().endsWith('.avi') ||
        cleanFilename.toLowerCase().endsWith('.mov') ||
        cleanFilename.toLowerCase().endsWith('.wav') ||
        cleanFilename.toLowerCase().endsWith('.m4a');

    if (isMediaFile) {
      final separator = url.contains('?') ? '&' : '?';
      final forceDownloadUrl =
          '$url${separator}download=1&force=1&t=${DateTime.now().millisecondsSinceEpoch}';

      final anchor = html.AnchorElement(href: forceDownloadUrl)
        ..download = cleanFilename
        ..style.display = 'none'
        ..rel = 'noopener'
        ..target = '_blank';

      anchor.setAttribute('download', cleanFilename);
      anchor.attributes['download'] = cleanFilename;

      html.document.body?.append(anchor);
      anchor.click();

      await Future.delayed(const Duration(milliseconds: 1000));
      anchor.remove();

      print('✅ Downloaded: $cleanFilename');
      return;
    }
  } catch (e) {
    // Silently continue to next method
  }

  // Method 4: Enhanced direct download with parameters
  try {
    final separator = url.contains('?') ? '&' : '?';
    final downloadUrl =
        '$url${separator}download=true&t=${DateTime.now().millisecondsSinceEpoch}';

    final anchor = html.AnchorElement(href: downloadUrl)
      ..download = cleanFilename
      ..style.display = 'none'
      ..rel = 'noopener';

    anchor.setAttribute('download', cleanFilename);
    anchor.setAttribute('target', '_self');

    html.document.body?.append(anchor);
    anchor.click();

    await Future.delayed(const Duration(milliseconds: 800));
    anchor.remove();

    print('✅ Downloaded: $cleanFilename');
    return;
  } catch (e) {
    // Silently continue to next method
  }

  // Method 5: Last resort - window.open
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.mp4') ||
        cleanFilename.toLowerCase().endsWith('.avi') ||
        cleanFilename.toLowerCase().endsWith('.mov') ||
        cleanFilename.toLowerCase().endsWith('.wav');

    if (isMediaFile) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.display = 'none'
        ..setAttribute('download', cleanFilename);

      html.document.body?.append(iframe);

      await Future.delayed(const Duration(milliseconds: 500));

      final downloadUrl = url.contains('?')
          ? '$url&download=1&force_download=1&filename=$cleanFilename&t=${DateTime.now().millisecondsSinceEpoch}'
          : '$url?download=1&force_download=1&filename=$cleanFilename&t=${DateTime.now().millisecondsSinceEpoch}';

      html.window.open(downloadUrl, '_blank');
      iframe.remove();

      print('✅ Downloaded: $cleanFilename');
    } else {
      final downloadUrl = url.contains('?')
          ? '$url&download=true&filename=$cleanFilename&t=${DateTime.now().millisecondsSinceEpoch}'
          : '$url?download=true&filename=$cleanFilename&t=${DateTime.now().millisecondsSinceEpoch}';

      html.window.open(downloadUrl, '_self');
      print('✅ Downloaded: $cleanFilename');
    }
  } catch (finalError) {
    print('❌ Download failed: $cleanFilename - $finalError');
    rethrow;
  }
}

/// Downloads a file from [data] into the destination [filename].
/// Uses base64 encoding approach which works reliably on web browsers.
Future<void> downloadData(Uint8List data, String filename) {
  filename = filename.replaceAll('/', '_').replaceAll('\\', '_');

  // Encode our file in base64
  final b64 = base64Encode(data);

  // Create the link with the file
  final anchor =
      html.AnchorElement(href: 'data:application/octet-stream;base64,$b64');

  // Add the name
  anchor.download = filename;

  // Trigger download
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  return Future.value();
}

/// Web-specific download implementation using browser APIs (backward compatibility)
Future<void> triggerWebDownload(Uint8List bytes, String fileName) async {
  await downloadData(bytes, fileName);
}
