import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerPage extends StatefulWidget {
  final String filePath;

  const PdfViewerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isPdfLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Görüntüleyici")),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
            onRender: (pages) {
              setState(() {
                _isPdfLoading = false;
              });
            },
            onError: (error) {
              setState(() {
                _isPdfLoading = false;
              });
              // Hata durumunda kullanıcıya bilgi verin
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF yüklenirken bir hata oluştu: $error')),
              );
            },
          ),
          if (_isPdfLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}