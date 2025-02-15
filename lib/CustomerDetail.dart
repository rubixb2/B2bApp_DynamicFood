import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/services/CustomerService.dart';
import 'package:odoosaleapp/services/InvoiceService.dart';
import 'package:odoosaleapp/services/OrderService.dart';
import 'package:odoosaleapp/theme.dart';

import 'helpers/PdfScreen.dart';
import 'helpers/SessionManager.dart';
import 'models/customer/CustomersDetailResponseModel.dart';


class CustomerDetail extends StatefulWidget {
  final int customerId;
 // final String sessionId;

  const CustomerDetail({required this.customerId, Key? key}) : super(key: key);

  @override
  _CustomerDetailModalState createState() => _CustomerDetailModalState();
}

class _CustomerDetailModalState extends State<CustomerDetail> {
  CustomersDetailResponseModel? customerDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomerDetail();
  }

  void fetchCustomerDetail() async {
    final sessionId = _getSessionId();

    try {
      final customerData = await CustomerService().fetchCustomerDetail(
        sessionId: sessionId,
        customerId: widget.customerId,
      );

      if (customerData != null) {
        setState(() {
          isLoading = false;
          customerDetail = customerData;
        });
      } else {
        print('Customer detail is null');
      }
    } catch (e) {
      print('Error fetching customer detail: $e');
    }
  }
  String _getSessionId() {
    return SessionManager().sessionId ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Details')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Spacer(),
                Text(
                  customerDetail!.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer()
              ],
            ),

            Row(
              children: [
                Spacer(),
                Text("Credit: ", style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${customerDetail!.credit}", style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                Text("Overdue: ", style: TextStyle(color: Colors.red, fontSize: 18,fontWeight: FontWeight.bold)),
                Text("${customerDetail!.overdueDept}", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer()
              ],
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(child: Text('Orders',style: AppTextStyles.list2)),
                        Tab(child: Text('Invoices',style: AppTextStyles.list2)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                      ListView.builder(
                      itemCount:customerDetail!.orderSaleList.length,
                        itemBuilder: (context, index) {
                          final order = customerDetail!.orderSaleList[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(order.name.length>12 ? order.name.substring(0,12): order.name,
                                          style: AppTextStyles.bodyTextBold),
                                      SizedBox(width: 15),
                                      Text('Total: \€${order.amountTotal.toStringAsFixed(2)}',
                                          style: AppTextStyles.bodyTextBold),
                                      Spacer(),
                                      Text(
                                        order.createDate.length>10 ? order.createDate.substring(0,10) : order.createDate,
                                        style: AppTextStyles.bodyTextBold,
                                      ),



                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    order.invoiceStatus ,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: order.invoiceStatus == 'invoiced'  ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      ElevatedButton(
                                        onPressed: order.invoiceStatus != 'invoiced'
                                            ? () => completeOrder(order.id)
                                            : null,
                                        child: Text('Complete',style: AppTextStyles.buttonTextWhite),
                                        style: AppButtonStyles.secondaryButton,
                                      ) ,
                                     /* ElevatedButton(
                                        onPressed: order.invoiceStatus != 'invoiced'
                                            ? () => discount(order.id)
                                            : null,
                                        child: Text('Discount'),
                                      ) ,
                                      ElevatedButton(
                                        onPressed: order.invoiceStatus != 'invoiced'
                                            ? () => editOrder(order.id)
                                            : null,
                                        child: Text('Edit'),
                                      ) ,*/
                                      ElevatedButton(
                                        onPressed: order.pdfUrl.isNotEmpty
                                            ? () => _openPdf(order.pdfUrl)
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
                      ),
                      ListView.builder(
                        itemCount: customerDetail!.orderInvoiceList.length,
                        itemBuilder: (context, index) {
                          final invoice = customerDetail!.orderInvoiceList[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(invoice.name.length>50 ? invoice.name.substring(0,50): invoice.name,
                                      style: AppTextStyles.bodyTextBold
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        invoice.paymentState ?? "",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: (invoice.paymentState ?? "").toLowerCase() == "paid" ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Text('Total: \€${invoice.amountTotalSigned.toStringAsFixed(2)}',
                                          style: AppTextStyles.bodyTextBold
                                      ),

                                      Spacer(),
                                      Text(
                                        invoice.invoiceDate!.length>10 ? invoice.invoiceDate!.substring(0,10) : invoice.invoiceDate!,
                                        style:AppTextStyles.bodyTextBold,
                                      ),
                                      SizedBox(width: 10),
                                      Text(invoice.overdueDay ?? "",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:  Colors.red,)),

                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      ElevatedButton(
                                        onPressed: (invoice.paymentState ?? "").toLowerCase() != "paid"
                                            ? () => _addPayment(invoice.id)
                                            : null,
                                        child: Text('Add Payment',style: AppTextStyles.buttonTextWhite),
                                        style: AppButtonStyles.secondaryButton,
                                      ) ,
                                      ElevatedButton(
                                        onPressed:
                                            () => refund(invoice.id),
                                        child: Text('Refund',style: AppTextStyles.buttonTextWhite),
                                        style: AppButtonStyles.secondaryButton,
                                      ) ,

                                      ElevatedButton(
                                        onPressed: (invoice.pdfUrl ?? "").isNotEmpty
                                            ? () => _openPdf(invoice.pdfUrl ?? "")
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
                      )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void refund(int invoiceId) {
    _confirmRefund(invoiceId);
  }
  void _confirmRefund(int invoiceId) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Payment'),
          content: Text(
            'Order will be refund. Do you confirm?',style: AppTextStyles.buttonTextBlack,),
          actions: [
            TextButton(
              child: Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.confimButton,
              onPressed: () {
                Navigator.of(context).pop();
                _makeORefund(invoiceId);
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _makeORefund(int invoiceId) async {
    var res = await InvoiceService().refund(sessionId: _getSessionId(),invoiceId: invoiceId);
    if (res)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refund success..')),
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
       //   _initializeOrders();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed complete order: $e')),
      );
    }
  }
  void _openPdf(String url) {
    // Burada PDF açma işlemi yapılabilir (Örneğin: launch(url) kullanarak)
    print('Opening PDF: $url');
    // url = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
    openPdf(context, url);
  }
  void _addPayment(int id) {


  }
  void openPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(url: url),
        //builder: (context) => PdfViewerScreen(pdfUrl: url),
      ),
    );
  }
}
