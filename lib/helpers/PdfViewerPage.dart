import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerPage extends StatefulWidget {
  final String filePath;

  const PdfViewerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isPdfLoading = true;

  // 📌 Yazdırma Fonksiyonu
  void _printPdf() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        await Printing.layoutPdf(onLayout: (format) => file.readAsBytes());
      } else {
        _showErrorSnackBar('PDF dosyası bulunamadı');
      }
    } catch (e) {
      _showErrorSnackBar('Yazdırma hatası: $e');
    }
  }

  // 📌 Paylaş Fonksiyonu
  void _sharePdf() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(widget.filePath)],
          text: 'PDF Dosyası',
        );
      } else {
        _showErrorSnackBar('PDF dosyası bulunamadı');
      }
    } catch (e) {
      _showErrorSnackBar('Paylaşım hatası: $e');
    }
  }

  // Hata mesajı gösterme
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Görüntüleyici"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printPdf,
            tooltip: 'Yazdır',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
            tooltip: 'Paylaş',
          ),
        ],
      ),
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