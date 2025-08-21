import 'package:flutter/material.dart';
import 'package:odoosaleapp/helpers/PdfScreen.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'package:odoosaleapp/services/OrderService.dart';
import 'package:odoosaleapp/theme.dart';

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
  int _getCartId() {
    return SessionManager().cartId ?? 0;
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
                        Row(
                          children: [
                            Text((order.partnerName.length>50 ? order.partnerName.substring(0,50): order.partnerName),
                                style:AppTextStyles.bodyTextBold),
                            Spacer(),
                            Text('Id: ' + order.id.toString(),
                                style: AppTextStyles.bodyTextBold),
                          ],
                        ),
                        /*Text((order.partnerName.length>50 ? order.partnerName.substring(0,50): order.partnerName)+"-"+order.cartId.toString() +"-"+order.id.toString(),
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),*/

                        SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              order.orderCompleteStatus ? 'Completed' : 'Pending',
                              style: TextStyle(
                                fontSize: 14,
                                color: order.orderCompleteStatus ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Total: \€${order.amountTotal.toStringAsFixed(2)}',
                                style: AppTextStyles.bodyTextBold),
                            SizedBox(width: 10),
                            Text(order.invoicestatus,
                              style: TextStyle(
                                fontSize: 14,
                                color: order.invoicestatus == "invoiced"  ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold
                                )
                            ),
                            Spacer(),
                            Text(
                              order.dateOrder.length>10 ? order.dateOrder.substring(0,10) : order.dateOrder,
                              style: AppTextStyles.bodyTextBold,
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                        /*    order.orderCompleteStatus == true && order.invoicestatus != null && order.invoicestatus.toLowerCase() != "invoiced" ?
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: (order.orderPdfUrl ?? '').isNotEmpty
                                      ? () => _confirmInvoiceCreate(order.id)
                                      : null,
                                  child: Text('Create Invoice',style: AppTextStyles.buttonTextWhite),
                                  style: AppButtonStyles.secondaryButton,
                                )
                              ],
                            ):
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  ElevatedButton(
                                  onPressed: order.orderCompleteStatus == false
                                  ? () => _confirmCompleteOrder(order.id)
                                      : null,
                                  child: Text('Complete',style: AppTextStyles.buttonTextWhite),
                                  style: AppButtonStyles.secondaryButton,
                                  ) ,
                                  SizedBox(width: 5),
                                  ElevatedButton(
                                  onPressed: order.orderCompleteStatus == false
                                  ? () => discount(order.id)
                                      : null,
                                  child: Text('Discount',style: AppTextStyles.buttonTextWhite),
                                  style: AppButtonStyles.secondaryButton,

                                  ) ,
                                    SizedBox(width: 5),
                                  ElevatedButton(
                                  onPressed: order.orderCompleteStatus == false
                                  ? () => editOrder(order.cartId,order.partnerName ?? "-",order.partnerid)
                                      : null,
                                  child: Text('Edit',style: AppTextStyles.buttonTextWhite),
                                  style: AppButtonStyles.secondaryButton,
                                  )
                                  ]
                                ),*/


                            ElevatedButton(
                              onPressed: (order.orderPdfUrl ?? '').isNotEmpty
                                  ? () => _openPdf(order.orderPdfUrl ?? '')
                                  : null,
                              child: Text('PDF',style: AppTextStyles.buttonTextWhite),
                              style: AppButtonStyles.secondaryButton,
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

  void openPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(url: url),
      ),
    );
  }

  void _confirmCompleteOrder(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Order'),
          content: const Text('Order will be completed, Do you confirm?',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // İptal butonu
              child: const Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                completeOrder(id); // Sepeti sil
              },
              child: const Text('Confirm', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,

            ),
          ],
        );
      },
    );
  }

  void completeOrder(int id) async {
    try {
      final sessionId = _getSessionId();

      // Cart silme işlemi için servisi çağır
      final pdfUrl = await OrderService().completeOrder(
        sessionId: sessionId,
        orderId: id,
      );

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order completed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        _initializeOrders();

      }
      else
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
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
              child: Text("Cancel", style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.notrButton,
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedType.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İnvalid value'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }

                double discountValue = selectedType == "percentage"
                    ? double.parse(percentageController.text)
                    : double.parse(amountController.text);

               // _confirmDiscount(id, discountValue, selectedType);
                _applyDiscount(id, discountValue, selectedType);
                Navigator.of(context).pop();
              },
              child: Text("Apply", style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyDiscount(int id, double value, String type) async {
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
          SnackBar(
            content: Text('Discount apply successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
       _initializeOrders();
      }
      else
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occured!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
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
          title: Text('Confirm Edit'),
          content: Text(
              'Products transfer to your cart. Do you confirm? ',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              child: Text('Cancel', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.notrButton,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,
              onPressed: () {
                _makeOrderEdit(cartId,customerName,customerId);
                Navigator.of(context).pop();

              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDiscount(int id, double value, String type) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Discount'),
          content: Text(
              'Discount will be applied. Do you confirm? ',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              child: Text('Cancel', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.notrButton,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,
              onPressed: () {
                Navigator.of(context).pop();
                _applyDiscount(id,value,type);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _makeOrderEdit(int cartId,String customerName,int customerId) async {
    var res = await OrderService().orderEdit(sessionId: _getSessionId(),oldCartId: cartId,currentCartId: _getCartId());
    if (res)
    {
    //  SessionManager().setCustomerName(customerName);
   //   SessionManager().setCustomerId(customerId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your cart is updated, please check your cart'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    //  Navigator.pop(context);
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occured!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmInvoiceCreate(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invoice Create '),
          content: const Text('Invoice will be created, Do you confirm?',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // İptal butonu
              child: const Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                invoiceCreate(id); // Sepeti sil
              },
              child: const Text('Confirm', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,

            ),
          ],
        );
      },
    );
  }

  void invoiceCreate(int id) async {
    try {
      final sessionId = _getSessionId();

      // Cart silme işlemi için servisi çağır
      final invoice = await OrderService().createInvoice(
        sessionId: sessionId,
        orderId: id,
      );

      if (invoice != null && invoice.data.pdfUrl.isNotEmpty)
      {
        _initializeOrders();
        setState(() {
        //  Navigator.of(context).pop();

        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('invoice created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      else
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed complete order: $e')),
      );
    }
  }


}