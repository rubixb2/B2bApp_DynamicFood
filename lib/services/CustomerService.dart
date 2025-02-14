import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/models/customer/CustomerApiResponse.dart';

import '../helpers/SessionManager.dart';
import '../models/cart/CustomerDropListModel.dart';
import '../models/customer/CustomersDetailResponseModel.dart';

// CartService Class
class CustomerService {

  final String _baseUrl =
      'https://apiodootest.nametech.be/Api/customers/list';
  final String _detailUrl =
      'https://apiodootest.nametech.be/Api/customers/detail';

  Future<CustomerApiResponse?> fetchCustomers(
      {required String sessionId,required String searchKey}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,'searchKey':searchKey}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
          final customerData = CustomerApiResponse.fromJson(jsonData);
          return customerData;
        } else {
          var msg = data['Message'];
          throw Exception(msg);
        }
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      return null;
    }
  }

  Future<CustomersDetailResponseModel?> fetchCustomerDetail(
      {required String sessionId,required int customerId}) async {
    try {
      final response = await http.post(
        Uri.parse(_detailUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,'Id':customerId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data']['CustomerDetail'];
          final customerData = CustomersDetailResponseModel.fromJson(jsonData);
          return customerData;
        } else {
          var msg = data['Message'];
          throw Exception(msg);
        }
      } else {
        throw Exception('Failed to load customer data');
      }
    } catch (e) {
      print('Error fetching customer: $e');
      return null;
    }
  }
}
