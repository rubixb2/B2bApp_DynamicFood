import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/B2bMainPage.dart';
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/services/OrderService.dart';
import 'package:odoosaleapp/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'helpers/FlushBar.dart';
import 'helpers/Strings.dart';
import 'models/order/OrdersResponseModel.dart';
import 'package:intl/intl.dart';

//import 'package:open_file/open_file.dart';

class B2bOrderListScreen extends StatefulWidget {
  const B2bOrderListScreen({Key? key}) : super(key: key);

  @override
  _B2bOrderListScreenState createState() => _B2bOrderListScreenState();
}

class _B2bOrderListScreenState extends State<B2bOrderListScreen> {
  final OrderService _orderService = OrderService();
  late Future<OrderApiResponseModel?> _ordersFuture;
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = _orderService.fetchOrders(
      sessionId: _sessionManager.sessionId ?? "",
    );
  }
  Future<void> _repeatOrder(int id) async {
 /*   setState(() {
      isLoading = true;
    });*/

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('sessionId') ?? '';
      final cartId = prefs.getInt('cartId') ?? 0;
      final customerId = prefs.getInt('customerId') ?? 0;
      String baseurl = await prefs.getString('baseUrl') ?? '';

      // sipariş oluşturma işlemleri
      final orderPayload = {
        "sessionId": sessionId,
        "orderId": id,
        "newCartId": cartId,
      };

      final orderResponse = await http.post(
        Uri.parse(baseurl + "b2bsale/TransferCartItems"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderPayload),
      );

      final orderResult = jsonDecode(orderResponse.body);
      if (orderResult['Control'] == 1) {
        showCustomToast(context, Strings.productsAddedToCart);

        // Navigate to shopping cart (index 1) after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));

     /*   if (mounted) {
          setState(() {
            B2bMainPage(). = 1; // Shopping cart is at index 1
          });
        }*/
      }
    } catch (e) {
      print('Hata: $e');
      showCustomErrorToast(context, '${Strings.generalError}: ${e}');
    } finally {
    /*  setState(() {
        isLoading = false;
      });*/
    }
  }

  Future<void> _openPdf(String pdfUrl) async {
    // Eğer URL geçerli değilse veya boşsa
    if (pdfUrl.isEmpty) {
      showCustomErrorToast(context, Strings.pdfUrlNotAvailable);

      return;
    }
    _viewInApp(pdfUrl);

/*    // Kullanıcıya seçenek sunalım: Tarayıcıda aç veya uygulama içinde göster
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Strings.openPdfTitle),
        content: Text(Strings.howToViewPdf),
        actions: [
         *//* TextButton(
            onPressed: () => Navigator.pop(context, 1),
            child: Text(Strings.openInBrowser),
          ),*//*
          TextButton(
            onPressed: () => Navigator.pop(context, 2),
            child: Text(Strings.viewInApp),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 0),
            child: Text(Strings.cancel),
          ),
        ],
      ),
    );

    if (result == 1) {
      // Tarayıcıda aç
      _launchInBrowser(pdfUrl);
    } else if (result == 2) {
      // Uygulama içinde göster
      _viewInApp(pdfUrl);
    }*/
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      showCustomErrorToast(context, Strings.couldNotLaunchUrl);
    }
  }

  Future<void> _viewInApp(String pdfUrl) async {
    try {
      // PDF'i indir ve yerel dosya olarak kaydet
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/order_${DateTime.now().millisecondsSinceEpoch}.pdf';

      showCustomToast(context, Strings.pdfDownloadStarted);


      await Dio().download(pdfUrl, filePath);

      // PDF'i görüntüle
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(Strings.orderPdf)),

            body: PDFView(
              filePath: filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {
                showCustomErrorToast(context, '${Strings.error}: $error');

              },
              onPageError: (page, error) {
                showCustomErrorToast(context, '${Strings.errorOnPage}: $page - $error');

              },
            ),
          ),
        ),
      );
    } catch (e) {
      showCustomErrorToast(context, '${Strings.error}: $e');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),*/
      body: FutureBuilder<OrderApiResponseModel?>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${Strings.generalError}:  ${snapshot.error}',
                style: AppTextStyles.list2,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.orders.isEmpty) {
            return  Center(child: Text(Strings.noOrdersFound));
          }

          final orders = snapshot.data!.orders;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadOrders();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrdersResponseModel order) {
    final dateFormat = DateFormat('MMMM dd yyyy');
    final formattedDate = dateFormat.format(DateTime.parse(order.dateOrder));
    final status = order.orderCompleteStatus ? Strings.complete : Strings.draft;

    final statusColor =
        order.orderCompleteStatus ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${Strings.orderNumber} #${order.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: (order.orderPdfUrl == null || order.orderPdfUrl == '')
                      ? null  // Buton pasif olur
                      : () {
                    _openPdf(order.orderPdfUrl!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4E6EF2),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text(
                    "Pdf",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${Strings.placedOn} $formattedDate',
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /*  Text(
                  'Items: ${order.cartId}', // Burada gerçek item sayısı olmalı, modelinizi güncelleyebilirsiniz
                  style: const TextStyle(fontSize: 16),
                ),*/
                Text(
                  '\€${order.amountTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _repeatOrder(order.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAE6EF2),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.repeat, color: Colors.white),
                  label: Text(
                    Strings.repeat,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),

                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildStatusStepper(order),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper(OrdersResponseModel order) {
    final steps = [
      _buildStep(Strings.orderPlaced, true),/*
      _buildStep(Strings.orderConfirmed, order.orderCompleteStatus),
      _buildStep(Strings.orderCompleted, order.orderCompleteStatus),*/
      _buildStep(Strings.invoiced, order.orderCompleteStatus),

/*
      _buildStep('Order placed', true),fluu
      _buildStep('Order confirmed'),
      //   _buildStep('Order shipped', order.orderCompleteStatus),
      _buildStep('Order completed', order.orderCompleteStatus),
      _buildStep('Invoiced', order.orderCompleteStatus),*/
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: order.orderCompleteStatus ? 1.0 : 0.2,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            order.orderCompleteStatus ? Colors.green : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String title, bool isCompleted) {
    return Column(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}


