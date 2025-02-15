import 'package:flutter/material.dart';
import 'package:odoosaleapp/models/customer/CustomerApiResponse.dart';
import 'package:odoosaleapp/services/CustomerService.dart';
import 'package:odoosaleapp/theme.dart';

import 'CustomerDetail.dart';
import 'helpers/SessionManager.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late Future<CustomerApiResponse?> invoicesFuture = Future.value();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCustomers();
    //ordersFuture = fetchOrders();
  }

  Future<void> _initializeCustomers({String searchKey = ''}) async {
    final sessionId = _getSessionId();

    setState(() {
      invoicesFuture = CustomerService().fetchCustomers(sessionId: sessionId,searchKey: searchKey);
    });
  }
  String _getSessionId() {
    return SessionManager().sessionId ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /*appBar: AppBar(title: Text('Customers')),*/
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                _initializeCustomers(searchKey: value);
              },
              decoration: InputDecoration(
                labelText: 'Search Customer',
                hintText: 'Enter customer name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child:   FutureBuilder<CustomerApiResponse?>(
            future: invoicesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No customer found.'));
              }

              final invoices = snapshot.data!.customerList;

              return ListView.builder(
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return
                    GestureDetector(
                      onTap: () {
                        openDetail(context, invoice.id);
                    // Modal açma veya yeni sayfaya yönlendirme
             /*       showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return CustomerDetail(customerId: invoice.id);
                      },
                    );*/
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(invoice.name.length>50 ? invoice.name.substring(0,50): invoice.name,
                              style: AppTextStyles.bodyTextBold),
                          Row(
                            children: [
                              Text(
                                invoice.city ?? '' ,
                                style: AppTextStyles.bodyTextBold
                              ),
                              SizedBox(width: 15),
                              Text(invoice.street ?? '',
                                  style: AppTextStyles.bodyTextBold
                              ),

                            ],
                          ),

                        ],
                      ),

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


  void openDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetail(customerId: id),
        //builder: (context) => PdfViewerScreen(pdfUrl: url),
      ),
    );
  }

}