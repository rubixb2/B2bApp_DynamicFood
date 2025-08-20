import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:odoosaleapp/helpers/Strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:printing/printing.dart';

class PdfScreen extends StatefulWidget {
  final String url;

  PdfScreen({required this.url});

  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    downloadAndSavePdf();
  }

  Future<void> downloadAndSavePdf() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      String filePath = '${dir.path}/temp.pdf';

      Dio dio = Dio();
      await dio.download(widget.url, filePath);

      setState(() {
        localFilePath = filePath;
      });
    } catch (e) {
      print("PDF indirilemedi: $e");
    }
  }

  // 📌 Yazdırma Fonksiyonu
  void printPdf() async {
    if (localFilePath != null) {
      final file = File(localFilePath!);
      await Printing.layoutPdf(onLayout: (format) => file.readAsBytes());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.pdfViewer),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: printPdf, // Yazdırma butonu
          ),
        ],
      ),
      body: localFilePath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(filePath: localFilePath!),
    );
  }
}
