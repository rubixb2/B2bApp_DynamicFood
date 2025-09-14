import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/services/OrderService.dart';
import 'package:odoosaleapp/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helpers/FlushBar.dart';
import 'helpers/PdfViewerPage.dart';
import 'helpers/Strings.dart';
import 'models/order/OrdersResponseModel.dart';
import 'package:intl/intl.dart';

class B2bOrderListScreen extends StatefulWidget {
  const B2bOrderListScreen({Key? key}) : super(key: key);

  @override
  _B2bOrderListScreenState createState() => _B2bOrderListScreenState();
}

class _B2bOrderListScreenState extends State<B2bOrderListScreen> {
  final OrderService _orderService = OrderService();
  late Future<OrderApiResponseModel?> _ordersFuture;
  final SessionManager _sessionManager = SessionManager();
  bool _isPdfDownloading = false;
  String _currency = '€';

  @override
  void initState() {
    super.initState();
    _currency = _sessionManager.b2bCurrency;
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = _orderService.fetchOrders(
      sessionId: _sessionManager.sessionId ?? "",
    );
  }

  Future<void> _repeatOrder(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('sessionId') ?? '';
      final cartId = prefs.getInt('cartId') ?? 0;
      String baseurl = await prefs.getString('baseUrl') ?? '';

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
      }
    } catch (e) {
      print('Hata: $e');
      showCustomErrorToast(context, '${Strings.generalError}: ${e}');
    }
  }

  Future<void> _previewOrder(int id) async {
    // Yükleme durumu doğrudan _openPdf içinde ayarlandığı için burayı değiştirmedik.
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('sessionId') ?? '';
      String baseurl = await prefs.getString('baseUrl') ?? '';

      final orderPayload = {
        "sessionId": sessionId,
        "orderId": id,
      };

      final orderResponse = await http.post(
        Uri.parse(baseurl + "b2bsale/orderPreview"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderPayload),
      );

      final orderResult = jsonDecode(orderResponse.body);
      if (orderResult['Control'] == 1) {
        final pdfUrl = orderResult['Data']['pdfurl'];
        await _viewInApp(pdfUrl);
      } else {
        showCustomErrorToast(context, '${Strings.generalError}');
      }
    } catch (e) {
      print('Hata: $e');
      showCustomErrorToast(context, '${Strings.generalError}: ${e}');
    } finally {
      // İşlem bittiğinde yükleme durumunu kapat
      if (mounted) {
        setState(() {
          _isPdfDownloading = false;
        });
      }
    }
  }

  Future<void> _openPdf(int id) async {
    // Yükleme zaten devam ediyorsa tekrar başlamayı engelle
    if (_isPdfDownloading) {
      return;
    }

    // Yükleme durumunu başlat ve _previewOrder'ı çağır
    setState(() {
      _isPdfDownloading = true;
    });

    await _previewOrder(id);
  }

  Future<void> _viewInApp(String pdfUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/order_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Dio().download(pdfUrl, filePath);
      showCustomToast(context, Strings.pdfDownloadStarted);

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(filePath: filePath),
          ),
        );
      }
    } catch (e) {
      showCustomErrorToast(context, '${Strings.error}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<OrderApiResponseModel?>(
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
                return Center(child: Text(Strings.noOrdersFound));
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
          if (_isPdfDownloading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrdersResponseModel order) {
    final dateFormat = DateFormat('MMMM dd yyyy');
    final formattedDate = dateFormat.format(DateTime.parse(order.dateOrder));

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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isPdfDownloading
                      ? null // Yükleniyorsa butonu pasif yap
                      : () {
                    _openPdf(order.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E6EF2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text(
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
                Text(
                  '$_currency${order.amountTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // B2bOrderRepeatButton ayarına göre repeat butonunu göster/gizle
                if (SessionManager().b2bOrderRepeatButton == 1)
                  ElevatedButton.icon(
                    onPressed: () {
                      _repeatOrder(order.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE6EF2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.repeat, color: Colors.white),
                    label: Text(
                      Strings.repeat,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
      _buildStep(Strings.orderPlaced, true),
      _buildStep(Strings.invoiced, order.orderCompleteStatus),
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