import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:odoosaleapp/helpers/PdfScreen.dart';
import 'package:odoosaleapp/models/invoice/InvoiceApiResoponseModel.dart';
import 'package:odoosaleapp/models/invoice/PaymentLineTypeResponseModel.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/services/InvoiceService.dart';
import 'package:odoosaleapp/theme.dart';

import 'helpers/PdfViewerScreen.dart';
import 'helpers/SessionManager.dart';
import 'helpers/Strings.dart';
import 'models/order/OrdersResponseModel.dart';

class B2bInvoicesPage extends StatefulWidget {
  const B2bInvoicesPage({Key? key}) : super(key: key);
  @override
  _B2bInvoicesPageState createState() => _B2bInvoicesPageState();
}

class _B2bInvoicesPageState extends State<B2bInvoicesPage> {
  late Future<InvoiceApiResponseModel?> invoicesFuture = Future.value();
  late Future<PaymentLineTypeResponseModel?> dropListFuture = Future.value();
  final TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPdfLoading = false; // Yeni durum değişkeni eklendi
  //String? _selectedMethod;
  String _amount = '';
  double amount = 0;
  int selectedId = 0;
  int selectedMethodId = 0;
  bool _isAddButtonEnabled = true;
  PaymentMethod? selectedMethod; // Seçili müşteri

  //String? _selectedPaymentMethod; // Seçilen ödeme yöntemi

  Map<String, String> _paymentMethods = {
    "0": '0',
    "1": '1',
    "2": '2',
  };
  Map<int, String> _paymentMethods2 = {
    0: 'Credit Card',
    1: 'PayPal',
    2: 'Bank Transfer',
  };

  @override
  void initState() {
    super.initState();
    _initializeInvoices();
   // _fetchPaymentMethods();
    //ordersFuture = fetchOrders();
  }

  Future<void> _initializeInvoices({String searchKey = ''}) async {
    final sessionId = _getSessionId();
    final customerId = SessionManager().customerId ?? 0;

    setState(() {
      invoicesFuture = InvoiceService().fetchCustomerInvoices(sessionId: sessionId,SearchKey: searchKey,customerId: customerId);
    });
  }
  String _getSessionId() {
    return SessionManager().sessionId ?? "";
  }

  Future<PaymentLineTypeResponseModel?> _fetchPaymentMethods() async {
    try {
      dropListFuture = InvoiceService().fetchPaymentMethods(sessionId: _getSessionId());
        return dropListFuture ?? null ;
    } catch (e) {
      print("Error fetching payment methods: $e");
    }

  }
  // _B2bInvoicesPageState sınıfı içinde
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    _initializeInvoices(searchKey: value);
                  },
                  decoration: InputDecoration(
                    labelText: Strings.searchInvoiceLabel,
                    hintText: Strings.searchInvoiceHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<InvoiceApiResponseModel?>(
                  future: invoicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${Strings.generalError}:  ${snapshot.error}',
                          style: AppTextStyles.list2,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.bills.isEmpty) {
                      return Center(
                        child: Text(
                          Strings.noInvoiceFound,
                          style: AppTextStyles.list2,
                        ),
                      );
                    }
                    final invoices = snapshot.data!.bills;
                    return ListView.builder(
                      itemCount: invoices.length,
                      itemBuilder: (context, index) {
                        final invoice = invoices[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(invoice.name.toString(),
                                        style: AppTextStyles.bodyTextBold),
                                    const Spacer(),
                                    Text(
                                      '${Strings.totalLabel}: €${invoice.amountTotal.toStringAsFixed(2)}',
                                      style: AppTextStyles.bodyTextBold,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      invoice.invoiceDate.length > 10
                                          ? invoice.invoiceDate.substring(0, 10)
                                          : invoice.invoiceDate,
                                      style: AppTextStyles.bodyTextBold,
                                    ),
                                    const Spacer(),
                                    Text(
                                      invoice.paymentState,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: invoice.paymentState.toLowerCase() == "paid"
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(invoice.overdueDay,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () => _prewiew(invoice.id),
                                      child: Text('PDF',
                                          style: AppTextStyles.buttonTextWhite),
                                      style: AppButtonStyles.secondaryButton,
                                    ),
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
              ),
            ],
          ),
          if (_isPdfLoading)
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

  Future<void> _prewiew(int id) async {
    if (_isPdfLoading) return;

    setState(() {
      _isPdfLoading = true; // Start loading
    });

    try {
      var url = await InvoiceService().preview(
        sessionId: _getSessionId(),
        invoiceId: id,
      );

      if (url != null) {
        // Navigate to the PDF viewer and wait for it to be popped (closed)
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfScreen(url: url),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      // This block runs after the 'try' or 'catch' block, regardless of outcome.
      // It's the perfect place to stop the loading indicator.
      if (mounted) {
        setState(() {
          _isPdfLoading = false;
        });
      }
    }
  }

  void openPdf(BuildContext context, String url) {
    // We'll remove the setState call here because _prewiew handles the state.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(url: url),
      ),
    );
  }

  void completeOrder(int id) {
    // Burada PDF açma işlemi yapılabilir (Örneğin: launch(url) kullanarak)
    print('Opening PDF: $id');
  }

  void refund(int invoiceId) {
    _confirmRefund(invoiceId);
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
}