import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;

  const PdfViewerPage({super.key, required this.url});

  Future<void> _openPdf() async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      throw Exception('Could not open PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: Center(
        child: ElevatedButton(
          onPressed: _openPdf,
          child: const Text('Open PDF'),
        ),
      ),
    );
  }
}
