import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

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
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = 'data:application/octet-stream;base64,$b64';

  // Add the name
  anchor.download = filename;

  // Trigger download
  web.document.body?.append(anchor);
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

  // Method 1: HTTP GET with base64 encoding (Primary - most reliable for downloads)
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Exception('Empty response');
      }

      // Encode our file in base64
      final b64 = base64Encode(bytes);

      // Create the link with the file
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = 'data:application/octet-stream;base64,$b64';
      anchor.download = cleanFilename;

      // Trigger download
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      return;
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  } catch (e) {
    // Method 1 failed, continue to Method 1.5
  }

  // Method 1.5: HTTP GET with base64 encoding without credentials (fallback for CORS issues)
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Exception('Empty response');
      }

      // Encode our file in base64
      final b64 = base64Encode(bytes);

      // Create the link with the file
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = 'data:application/octet-stream;base64,$b64';
      anchor.download = cleanFilename;

      // Trigger download
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      return;
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  } catch (e) {
    // Method 1.5 failed, continue to Method 2.5
  }

  // Method 2.5: Direct anchor download with no-cors (for PDFs and other restricted content)
  try {
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = cleanFilename;
    anchor.style.display = 'none';
    anchor.rel = 'noopener';

    anchor.setAttribute('download', cleanFilename);
    anchor.setAttribute('target', '_self');

    web.document.body?.append(anchor);
    anchor.click();

    await Future.delayed(const Duration(milliseconds: 800));
    anchor.remove();

    return;
  } catch (e) {
    // Method 2.5 failed, continue to Method 2.7
  }

  // Method 2.7: Direct anchor download for media files
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.mp4') ||
        cleanFilename.toLowerCase().endsWith('.wav') ||
        cleanFilename.toLowerCase().endsWith('.m4a');

    if (isMediaFile) {
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = cleanFilename;
      anchor.style.display = 'none';
      anchor.type = 'application/octet-stream';

      anchor.setAttribute('download', cleanFilename);
      anchor.setAttribute('target', '_blank');

      web.document.body?.append(anchor);

      Future.delayed(const Duration(milliseconds: 100), () {
        anchor.click();
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        anchor.remove();
      });

      return;
    }
  } catch (e) {
    // Method 2.7 failed, continue to Method 2.8
  }

  // Method 2.8: Data URL approach for small media files
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.wav') ||
        cleanFilename.toLowerCase().endsWith('.m4a');

    if (isMediaFile) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (bytes.length > 50 * 1024 * 1024) {
          throw Exception('File too large');
        }

        final b64 = base64Encode(bytes);
        final dataUrl = 'data:application/octet-stream;base64,$b64';

        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = dataUrl;
        anchor.download = cleanFilename;
        anchor.style.display = 'none';
        anchor.type = 'application/octet-stream';

        anchor.setAttribute('download', cleanFilename);
        anchor.setAttribute('target', '_blank');

        web.document.body?.append(anchor);

        Future.delayed(const Duration(milliseconds: 100), () {
          anchor.click();
        });

        Future.delayed(const Duration(milliseconds: 1000), () {
          anchor.remove();
        });

        return;
      }
    }
  } catch (e) {
    // Method 2.8 failed, continue to Method 3
  }

  // Method 3: Direct anchor download
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.mp4') ||
        cleanFilename.toLowerCase().endsWith('.avi') ||
        cleanFilename.toLowerCase().endsWith('.mov') ||
        cleanFilename.toLowerCase().endsWith('.wav');

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = cleanFilename;
    anchor.style.display = 'none';
    anchor.rel = 'noopener';

    if (isMediaFile) {
      anchor.setAttribute('target', '_blank');
      anchor.setAttribute('download', cleanFilename);
    } else {
      anchor.setAttribute('target', '_self');
    }

    anchor.setAttribute('download', cleanFilename);

    web.document.body?.append(anchor);
    anchor.click();

    await Future.delayed(const Duration(milliseconds: 800));
    anchor.remove();

    return;
  } catch (e) {
    // Method 3 failed, continue to Method 3.5
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

      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = forceDownloadUrl;
      anchor.download = cleanFilename;
      anchor.style.display = 'none';
      anchor.rel = 'noopener';
      anchor.target = '_blank';

      anchor.setAttribute('download', cleanFilename);

      web.document.body?.append(anchor);
      anchor.click();

      await Future.delayed(const Duration(milliseconds: 1000));
      anchor.remove();

      return;
    }
  } catch (e) {
    // Method 3.5 failed, continue to Method 4
  }

  // Method 4: Enhanced direct download with parameters
  try {
    final separator = url.contains('?') ? '&' : '?';
    final downloadUrl =
        '$url${separator}download=true&t=${DateTime.now().millisecondsSinceEpoch}';

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = downloadUrl;
    anchor.download = cleanFilename;
    anchor.style.display = 'none';
    anchor.rel = 'noopener';

    anchor.setAttribute('download', cleanFilename);
    anchor.setAttribute('target', '_self');

    web.document.body?.append(anchor);
    anchor.click();

    await Future.delayed(const Duration(milliseconds: 800));
    anchor.remove();

    return;
  } catch (e) {
    // Method 4 failed, continue to Method 5
  }

  // Method 5: Last resort - window.open
  try {
    final isMediaFile = cleanFilename.toLowerCase().endsWith('.mp3') ||
        cleanFilename.toLowerCase().endsWith('.mp4') ||
        cleanFilename.toLowerCase().endsWith('.avi') ||
        cleanFilename.toLowerCase().endsWith('.mov') ||
        cleanFilename.toLowerCase().endsWith('.wav');

    if (isMediaFile) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.src = url;
      iframe.style.display = 'none';
      iframe.setAttribute('download', cleanFilename);

      web.document.body?.append(iframe);

      await Future.delayed(const Duration(milliseconds: 500));

      final downloadUrl = url.contains('?')
          ? '$url&download=1&force_download=1&filename=$cleanFilename&t=${DateTime.now().millisecondsSinceEpoch}'
          : '$url?download=1&force_download=1&filename=$cleanFilename&t=${DateTime.now().millisecondsSinceEpoch}';

      web.window.open(downloadUrl, '_blank');
      iframe.remove();

      // Download initiated
    } else {
      final downloadUrl = url.contains('?')
          ? '$url&download=true&filename=$cleanFilename&t=${DateTime.now().millisecondsSinceEpoch}'
          : '$url?download=true&filename=$cleanFilename&t=${DateTime.now().millisecondsSinceEpoch}';

      web.window.open(downloadUrl, '_self');
      // Download initiated
    }
  } catch (finalError) {
    // Download failed
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
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = 'data:application/octet-stream;base64,$b64';

  // Add the name
  anchor.download = filename;

  // Trigger download
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  return Future.value();
}

/// Web-specific download implementation using browser APIs (backward compatibility)
Future<void> triggerWebDownload(Uint8List bytes, String fileName) async {
  await downloadData(bytes, fileName);
}
