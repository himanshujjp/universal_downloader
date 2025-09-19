import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:universal_downloader/universal_downloader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Downloader Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Universal Downloader Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  double _progress = 0.0;
  String _status = 'Ready to download';
  bool _isDownloading = false;
  bool _allowSelfSignedCertificate = false;
  String _permissionStatus = 'Checking permissions...';
  bool _hasStoragePermission = false;

  @override
  void initState() {
    super.initState();
    // Set some example values that work better with web CORS
    _urlController.text = 'https://jsonplaceholder.typicode.com/posts/1';
    _fileNameController.text = 'test-file.json';
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermission = await PermissionUtils.requestStoragePermission();
      setState(() {
        _hasStoragePermission = hasPermission;
        if (hasPermission) {
          _permissionStatus = 'Storage permission granted ✓';
        } else {
          _permissionStatus = 'Storage permission required ⚠️';
        }
      });
    } catch (e) {
      setState(() {
        _permissionStatus = 'Permission check failed: $e';
        _hasStoragePermission = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _downloadFile() async {
    if (_urlController.text.isEmpty || _fileNameController.text.isEmpty) {
      setState(() {
        _status = 'Please enter URL and filename';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _status = 'Starting stream-based download...';
    });

    try {
      final result = await UniversalDownloader.downloadFromUrlStream(
        url: _urlController.text,
        filename: _fileNameController.text,
        allowSelfSignedCertificate: _allowSelfSignedCertificate,
        onProgress: (progress) {
          setState(() {
            _progress = progress.percentage / 100;
            _status =
                'Downloading... ${progress.percentage.toStringAsFixed(1)}%';
          });
        },
        onComplete: (filePath) {
          setState(() {
            _isDownloading = false;
            _status = 'Stream download completed! Saved to: $filePath';
          });
        },
        onError: (error) {
          setState(() {
            _isDownloading = false;
            _status = 'Stream download failed: $error';
          });
        },
      );

      if (!result.isSuccess) {
        setState(() {
          _isDownloading = false;
          _status = 'Download failed: ${result.errorMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _status = 'Download failed: $e';
      });
    }
  }

  Future<void> _testStreamDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _status = 'Testing stream download...';
    });

    try {
      // Create a simple stream of bytes (Hello World text)
      final text =
          'Hello World from Stream Download!\nThis is a test file created from a stream.';
      final bytes = utf8.encode(text);
      final stream = Stream<int>.fromIterable(bytes);

      await UniversalDownloader.downloadStream(
        stream: stream,
        filename: 'stream-test.txt',
      );

      setState(() {
        _status = 'Stream download completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Stream download failed: $e';
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _testDataDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _status = 'Testing data download...';
    });

    try {
      // Create some binary data (a simple text file)
      final text =
          'Hello World from Data Download!\nThis is a test file created from Uint8List data.';
      final data = Uint8List.fromList(utf8.encode(text));

      await UniversalDownloader.downloadData(
        data: data,
        filename: 'data-test.txt',
      );

      setState(() {
        _status = 'Data download completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Data download failed: $e';
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Current Platform: ${UniversalDownloader.platformName}'),
                      Text('Download Method: Stream-based (all platforms)'),
                      Text(
                          'Supports Directory Selection: ${UniversalDownloader.supportsDirectorySelection}'),
                      Text(
                          'Supports Progress Tracking: ${UniversalDownloader.supportsProgressTracking}'),
                      const SizedBox(height: 8),
                      Text(
                        'Storage Permission: $_permissionStatus',
                        style: TextStyle(
                          color: _hasStoragePermission
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_hasStoragePermission)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Storage permission is required for downloading files on mobile devices.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _checkPermissions,
                          icon: const Icon(Icons.security),
                          label: const Text('Request Permission'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Download URL',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the URL to download',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: 'File Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the filename to save as',
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Allow Self-Signed SSL Certificates'),
                subtitle:
                    const Text('⚠️ Only use for testing - reduces security'),
                value: _allowSelfSignedCertificate,
                onChanged: _isDownloading
                    ? null
                    : (value) {
                        setState(() {
                          _allowSelfSignedCertificate = value ?? false;
                        });
                      },
                dense: true,
              ),
              const SizedBox(height: 16),
              if (_isDownloading)
                Column(
                  children: [
                    LinearProgressIndicator(value: _progress),
                    const SizedBox(height: 8),
                  ],
                ),
              Text(
                _status,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isDownloading ? null : _downloadFile,
                child:
                    Text(_isDownloading ? 'Downloading...' : 'Download File'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading
                          ? null
                          : () {
                              setState(() {
                                _urlController.text =
                                    'https://jsonplaceholder.typicode.com/posts/1';
                                _fileNameController.text = 'test.json';
                              });
                            },
                      child: const Text('Test JSON'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading
                          ? null
                          : () {
                              setState(() {
                                // Use an image that typically allows CORS
                                _urlController.text =
                                    'https://picsum.photos/seed/a3f9e2b4c1/800/600';
                                _fileNameController.text = 'test.png';
                              });
                            },
                      child: const Text('Test Image'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading
                          ? null
                          : () {
                              setState(() {
                                // Use a PDF that typically allows CORS
                                _urlController.text =
                                    'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
                                _fileNameController.text = 'sample.pdf';
                              });
                            },
                      child: const Text('Test PDF'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading
                          ? null
                          : () {
                              setState(() {
                                _urlController.text =
                                    'https://www.w3.org/TR/PNG/iso_8859-1.txt';
                                _fileNameController.text = 'sample.txt';
                              });
                            },
                      child: const Text('Test Text'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading ? null : _testStreamDownload,
                      child: const Text('Test Stream Download'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading ? null : _testDataDownload,
                      child: const Text('Test Data Download'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading
                          ? null
                          : () {
                              setState(() {
                                // Test URL with self-signed certificate
                                _urlController.text =
                                    'https://self-signed.badssl.com/';
                                _fileNameController.text =
                                    'selfsigned-test.html';
                                _allowSelfSignedCertificate = true;
                              });
                            },
                      child: const Text('Test Self-Signed SSL'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading
                          ? null
                          : () {
                              setState(() {
                                // Test URL with expired certificate
                                _urlController.text =
                                    'https://expired.badssl.com/';
                                _fileNameController.text = 'expired-test.html';
                                _allowSelfSignedCertificate = true;
                              });
                            },
                      child: const Text('Test Expired SSL'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sample URLs to Test (Cross-Platform):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          '• JSON: https://jsonplaceholder.typicode.com/posts/1'),
                      const Text(
                          '• Image: https://picsum.photos/seed/a3f9e2b4c1/800/600'),
                      const Text(
                          '• Text: https://www.w3.org/TR/PNG/iso_8859-1.txt'),
                      const Text(
                          '• Self-Signed SSL: https://self-signed.badssl.com/'),
                      const Text('• Expired SSL: https://expired.badssl.com/'),
                      const SizedBox(height: 8),
                      Text(
                        'Note: All downloads now use stream-based processing for better performance and memory efficiency. The URLs above are tested to work across all platforms. SSL certificate test URLs require enabling "Allow Self-Signed SSL Certificates" option. Web downloads may still fail due to CORS restrictions. Native platforms have better compatibility with SSL issues.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
