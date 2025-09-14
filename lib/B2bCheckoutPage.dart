import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/B2bShoppingCartPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'B2bOrderCompletePage.dart';
import 'helpers/FlushBar.dart';
import 'helpers/SessionManager.dart';
import 'helpers/Strings.dart';
import 'models/cart/CartProductModel.dart';
import 'models/cart/PickupModel.dart';

class B2bCheckoutPage extends StatefulWidget {
  final String deliveryType;
  final int? pickupId;

  const B2bCheckoutPage({
    Key? key,
    required this.deliveryType,
    this.pickupId,
  }) : super(key: key);

  @override
  _B2bCheckoutPageState createState() => _B2bCheckoutPageState();
}

class _B2bCheckoutPageState extends State<B2bCheckoutPage> {
  List<CartProductModel> cartItems = [];
  double totalPrice = 0.0;
  int _cartId = 0;
  String _sessionId = "";
  bool isLoading = true;
  List<PickupModel> _pickupList = [];
  String _deliveryAddress = "";
  String _selectedWarehouseName = "";
  String _currency = '€';

  @override
  void initState() {
    super.initState();
    _currency = SessionManager().b2bCurrency;
    _loadDeliveryInfo();
    fetchCart();
  }

  void _loadDeliveryInfo() {
    // Müşteri adresini al
    _deliveryAddress = SessionManager().b2bCustomerAddress;
    
    // Önce SessionManager'dan kayıtlı depo adını al
    _selectedWarehouseName = SessionManager().selectedWarehouseName ?? '';
    
    // Eğer kayıtlı ad yoksa pickup listesinden bul
    if (_selectedWarehouseName.isEmpty) {
      final pickupListJson = SessionManager().pickupListJson;
      if (pickupListJson != null && pickupListJson.isNotEmpty) {
        final List<dynamic> pickupData = jsonDecode(pickupListJson);
        _pickupList = pickupData.map((item) => PickupModel.fromJson(item)).toList();
        
        // Seçili depo adını bul
        if (widget.pickupId != null) {
          final selectedWarehouse = _pickupList.firstWhere(
            (warehouse) => warehouse.id == widget.pickupId,
            orElse: () => PickupModel(id: 0, name: 'Bilinmeyen Depo', address: ''),
          );
          _selectedWarehouseName = selectedWarehouse.name ?? selectedWarehouse.address ?? 'Bilinmeyen Depo';
        }
      }
    }
  }

  Future<void> fetchCart() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Burada sessionId'yi localden çekiyoruz (SharedPreferences'dan)
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('sessionId') ?? '';
      final cartId = prefs.getInt('cartId') ?? 0;
      final customerId = prefs.getInt('customerId') ?? 0;
      _cartId = cartId;
      _sessionId = sessionId;
      String baseurl = await prefs.getString('baseUrl') ?? '';

      if (sessionId.isEmpty) {
        throw Exception('Session ID not found.');
      }
      final url = Uri.parse(baseurl + 'b2bSale/GetCart');
      final body = jsonEncode({"sessionid": sessionId, "cartid": cartId,'customerId':customerId});

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Control'] == 1) {
          final cartData = data['Data'];
          final cartProductsJson =
              cartData['CART_PRODUCTS'] as List<dynamic>? ?? [];

          setState(() {
            cartItems = cartProductsJson
                .map((json) => CartProductModel.fromJson(json))
                .toList();
            totalPrice = cartItems.fold(
              0.0,
              (sum, item) => sum + item.price * item.lastQuantity,
            );
            isLoading = false;
          });
        } else {
          showCustomErrorToast(context, Strings.cartDataError);
        }
      } else {

        showCustomErrorToast(context, '${Strings.serverError}: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
      showCustomErrorToast(context, Strings.cartDataError);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _completeOrder() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('sessionId') ?? '';
      final cartId = prefs.getInt('cartId') ?? 0;
      final customerId = prefs.getInt('customerId') ?? 0;
      final deliveryType = widget.deliveryType;
      final pickupId = widget.pickupId;
      String baseurl = await prefs.getString('baseUrl') ?? '';

      // sipariş oluşturma işlemleri
      final orderPayload = {
        "sessionId": sessionId,
        "customerId": customerId,
        "cartId": cartId,
        "deliveryType": deliveryType == "" || deliveryType == null ? "delivery" : deliveryType,
        "pickupId": pickupId == null ? 0 : pickupId ,

      };

      final orderResponse = await http.post(
        Uri.parse(baseurl + "b2bsale/addOrder"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderPayload),
      );

      final orderResult = jsonDecode(orderResponse.body);
      if (orderResult['Control'] == 1) {
        prefs.setInt("cartId", 0);
        await createNewCart();
        final orderId = orderResult['Data']['OrderId'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2bOrderCompletePage(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      print('Hata: $e');
      showCustomErrorToast(context, '${Strings.generalError}: ${e}');
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );*/
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createNewCart() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('cartId', 0);
    final sessionId = prefs.getString('sessionId') ?? '';
    final customerId = prefs.getInt('customerId') ?? '';
    String baseurl = await prefs.getString('baseUrl') ?? '';
    final url = Uri.parse(baseurl + 'B2bSale/createcart');
    final body = jsonEncode({
      "sessionid": sessionId,
      "customerId": customerId,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    final data = jsonDecode(response.body);

    if (data['Control'] == 1) {
      final prefs = await SharedPreferences.getInstance();
      final newCartId = data['Data']['cartId'];
      int ncid = int.parse(newCartId.toString());
      await prefs.setInt('cartId', ncid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.checkoutTitle, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teslimat Bilgileri Kartı
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              widget.deliveryType == 'pickup'
                                ? Icons.store
                                : Icons.local_shipping,
                              color: Colors.orange,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              widget.deliveryType == 'pickup'
                                ? Strings.pickupFromStore
                                : Strings.deliveryToAddress,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.deliveryType == 'pickup'
                            ? _selectedWarehouseName
                            : _deliveryAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Text(
                    Strings.shoppingSummary,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.productName ?? "",
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                (item.lastQuantity % 1 == 0
                                        ? item.lastQuantity.toInt().toString()
                                        : item.lastQuantity.toString()) +
                                    " * " +
                                    '$_currency${item.price?.toStringAsFixed(2) ?? '0.00'} x ${item.boxQuantity?.toInt() ?? 0}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '$_currency${(item.price * item.lastQuantity).toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Strings.total,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '$_currency${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _completeOrder();
                           /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => B2bOrderCompletePage(
                                        orderId: 'aaaa',
                                      )),
                            );*/
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4E6EF2),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(Icons.add_comment, color: Colors.white),
                          label: Text(
                            Strings.orderComplete,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),

                        ),
                        /*SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CustomerSearch(sessionId: _sessionId, cartId: _cartId)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4E6EF2),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.search, color: Colors.white),
                  label: Text(
                    "Already Has An Account",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),*/
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
