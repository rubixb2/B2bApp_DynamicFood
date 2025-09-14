import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/services/CustomerService.dart';
import 'package:odoosaleapp/services/InvoiceService.dart';
import 'package:odoosaleapp/services/OrderService.dart';
import 'package:odoosaleapp/theme.dart';

import 'helpers/PdfScreen.dart';
import 'helpers/SessionManager.dart';
import 'models/customer/CustomersDetailResponseModel.dart';
import 'models/invoice/PaymentLineTypeResponseModel.dart';


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
  String _amount = '';
  double amount = 0;
  int selectedId = 0;
  int selectedMethodId = 0;
  bool _isAddButtonEnabled = true;
  PaymentMethod? selectedMethod; // Seçili müşteri
  late Future<PaymentLineTypeResponseModel?> dropListFuture = Future.value();
  final _formKey = GlobalKey<FormState>();
  String _currency = '€';

  @override
  void initState() {
    super.initState();
    _currency = SessionManager().b2bCurrency;
    fetchCustomerDetail();
    _fetchPaymentMethods();
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
                Text("$_currency${customerDetail!.credit}", style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 20),
                Text("Overdue: ", style: TextStyle(color: Colors.red, fontSize: 18,fontWeight: FontWeight.bold)),
                Text("$_currency${customerDetail!.overdueDept}", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
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
                                            ? () => _confirmCompleteOrder(order.id)
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
                                            ? () => _openAddPaymentModal(invoice.id)
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
          title: Text('Confirm Refund'),
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
        SnackBar(
          content: Text('Refund successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      /*  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refund success..')),
      );*/
      Navigator.pop(context);
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occured.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
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

      if (pdfUrl != null && pdfUrl.isNotEmpty)  {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order completed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        fetchCustomerDetail();

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

  void _openPdf(String url) {
    // Burada PDF açma işlemi yapılabilir (Örneğin: launch(url) kullanarak)
    print('Opening PDF: $url');
    // url = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
    openPdf(context, url);
  }

  void _openAddPaymentModal(int id) {
    selectedId = id;
    // _isAddButtonEnabled=false;
    // _selectedMethod = null;
    selectedMethod=null;
    _amount = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Payment'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<PaymentLineTypeResponseModel?>(
                  future: dropListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final dropList = snapshot.data!.PaymentTypeList;
                    if (dropList == null || dropList.isEmpty) {
                      return const Center(
                          child: Text('No customers available.'));
                    }

                    return DropdownSearch<PaymentMethod>(
                      selectedItem: selectedMethod,
                      popupProps: PopupProps.dialog(
                        showSearchBox: false, // Arama kutusunu gösterir
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: "Search Customer",
                            hintText: "Type to search",
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select Payment Method",
                          hintText: "Search Method",
                        ),
                      ),
                      asyncItems: (String filter) async {
                        // Filtreyi kullanarak veriyi dinamik olarak çek
                        final filteredList = await _fetchPaymentMethods();
                        return filteredList!.PaymentTypeList;
                      },
                      itemAsString: (PaymentMethod customer) => customer.name,
                      onChanged: (value) {
                        setState(() {
                          selectedMethodId = value != null ? value!.id : 0;
                          selectedMethod = value;
                        });
                      },
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _amount = value;
                      amount = double.tryParse(_amount.replaceAll(",", ".")) ?? 0;
                      // _validateForm();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.confimButton,
              onPressed: _isAddButtonEnabled
                  ? () {

                _confirmPayment();
              }
                  : null,
            ),
          ],
        );
      },
    );
  }
  void _confirmPayment() {

    amount>0 && selectedMethodId>0 ?
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Payment'),
          content: Text(
              'A payment of €$amount will be recorded. Do you confirm?',style: AppTextStyles.buttonTextBlack),
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
                _makePayment();
              },
            ),
          ],
        );
      },
    ): null;
  }
  Future<void> _makePayment() async {
    var res = await InvoiceService().addPayment(sessionId: _getSessionId(),amount: amount,invoiceId: selectedId,paymentType: selectedMethodId);
    if (res)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text( amount.toString() + 'Payment added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        selectedId = 0;
        selectedMethodId = 0;
        amount = 0;
        _amount = "";
      });
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occured.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  Future<PaymentLineTypeResponseModel?> _fetchPaymentMethods() async {
    try {
      dropListFuture = InvoiceService().fetchPaymentMethods(sessionId: _getSessionId());
      return dropListFuture ?? null ;
    } catch (e) {
      print("Error fetching payment methods: $e");
    }

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
