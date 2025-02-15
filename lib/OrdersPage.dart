import 'package:flutter/material.dart';
import 'package:odoosaleapp/helpers/PdfScreen.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'package:odoosaleapp/services/OrderService.dart';

import 'helpers/PdfViewerScreen.dart';
import 'helpers/SessionManager.dart';
import 'models/order/OrdersResponseModel.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<OrderApiResponseModel?> ordersFuture = Future.value();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeOrders();
    //ordersFuture = fetchOrders();
  }

  Future<void> _initializeOrders({String searchKey = ''}) async {
    final sessionId = _getSessionId();

    setState(() {
      ordersFuture = OrderService().fetchOrders(sessionId: sessionId);
    });
  }
  String _getSessionId() {
    return SessionManager().sessionId ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     /* appBar: AppBar(title: Text('Orders')),*/
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              _initializeOrders(searchKey: value);
            },
            decoration: InputDecoration(
              labelText: 'Search Order',
              hintText: 'Enter Customer Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(child:   FutureBuilder<OrderApiResponseModel?>(
          future: ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No orders found.'));
            }

            final orders = snapshot.data!.orders;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*Text((order.partnerName.length>50 ? order.partnerName.substring(0,50): order.partnerName)+"-"+order.cartId.toString() +"-"+order.id.toString(),
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),*/
                        Text((order.partnerName.length>50 ? order.partnerName.substring(0,50): order.partnerName),
                            style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              order.orderCompleteStatus ? 'Completed' : 'Pending',
                              style: TextStyle(
                                fontSize: 12,
                                color: order.orderCompleteStatus ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Total: \€${order.amountTotal.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text(
                              order.dateOrder.length>10 ? order.dateOrder.substring(0,10) : order.dateOrder,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),



                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            ElevatedButton(
                              onPressed: order.orderCompleteStatus == false
                                  ? () => completeOrder(order.id)
                                  : null,
                              child: Text('Complete',style: TextStyle(fontSize: 12)),
                            ) ,
                            ElevatedButton(
                              onPressed: order.orderCompleteStatus == false
                                  ? () => discount(order.id)
                                  : null,
                              child: Text('Discount',style: TextStyle(fontSize: 12)),
                            ) ,
                            ElevatedButton(
                              onPressed: order.orderCompleteStatus == false
                                  ? () => editOrder(order.cartId,order.partnerName ?? "-",order.partnerid)
                                  : null,
                              child: Text('Edit',style: TextStyle(fontSize: 12)),
                            ) ,
                            ElevatedButton(
                              onPressed: order.orderPdfUrl.isNotEmpty
                                  ? () => _openPdf(order.orderPdfUrl)
                                  : null,
                              child: Text('PDF',style: TextStyle(fontSize: 12)),
                            ),
                            /*ElevatedButton(
                            onPressed: order.invoicePdfUrl.isNotEmpty
                                ? () => openPdf(order.invoicePdfUrl)
                                : null,
                            child: Text('Invoice PDF'),
                          ),*/
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        )
      ],
      )







    );
  }

  void _openPdf(String url) {
    print('Opening PDF: $url');
    openPdf(context, url);
  }
  void completeOrder(int id) async {
    try {
      final sessionId = _getSessionId();

      // Cart silme işlemi için servisi çağır
      final success = await OrderService().completeOrder(
        sessionId: sessionId,
        orderId: id,
      );

      if (success) {

        setState(() {
          _initializeOrders();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed complete order: $e')),
      );
    }
  }

  void discount(int id) {
    showDiscountModal(id);
  }
  void editOrder(int cartId,String custonerName,int customerId) {
    _confirmEdit(cartId,custonerName,customerId);
  }

  void openPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(url: url),
      ),
    );
  }

  void showDiscountModal(int id) {
    TextEditingController percentageController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    String selectedType = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Apply Discount"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: percentageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Discount Percentage"),
                enabled: selectedType != "amount",
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      selectedType = "percentage";
                      amountController.clear();
                    });
                  }
                },
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Discount Amount"),
                enabled: selectedType != "percentage",
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      selectedType = "amount";
                      percentageController.clear();
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedType.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a discount value")),
                  );
                  return;
                }

                double discountValue = selectedType == "percentage"
                    ? double.parse(percentageController.text)
                    : double.parse(amountController.text);

                applyDiscount(id, discountValue, selectedType);
                Navigator.of(context).pop();
              },
              child: Text("Apply"),
            ),
          ],
        );
      },
    );
  }
  Future<void> applyDiscount(int id, double value, String type) async {
    print('params: $id  $value    $type');

    try {
      final sessionId = _getSessionId();

      final res = await CartService().cartDiscount(
        sessionId: sessionId,
        orderId: id,
        val: value,
        type: type
      );

      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discount apply successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to discount apply: $e')),
      );
    }

  }

  void _confirmEdit(int cartId,String customerName,customerId) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Payment'),
          content: Text(
              'Products transfer to your cart. Do you confirm? '),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _makeOrderEdit(cartId,customerName,customerId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _makeOrderEdit(int cartId,String customerName,int customerId) async {
    var res = await OrderService().orderEdit(sessionId: _getSessionId(),cartId: cartId);
    if (res)
    {
      SessionManager().setCustomerName(customerName);
      SessionManager().setCustomerId(customerId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit Success, Please check cart')),

      );
      Navigator.pop(context);
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occured..')),
      );
    }
  }


}