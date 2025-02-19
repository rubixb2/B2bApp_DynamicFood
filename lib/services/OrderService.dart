import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';
import 'package:odoosaleapp/models/invoice/InvoiceCreateResponseModel.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/models/order/OrdersResponseModel.dart';

import '../helpers/SessionManager.dart';
import '../models/cart/CustomerDropListModel.dart';

// CartService Class
class OrderService {
  final String _baseUrl = SessionManager().baseUrl+'orders/List';
  final String _completeOrderUrl = SessionManager().baseUrl+'orders/complete';
  final String _createInvoiceUrl = SessionManager().baseUrl+'orders/InvoiceCreate';

  final String _addOrderUrl = SessionManager().baseUrl+'orders/add';
  final String _editOrderUrl = SessionManager().baseUrl+'cart/activate2';


  Future<OrderApiResponseModel?> fetchOrders(
      {required String sessionId}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
          final cartData = OrderApiResponseModel.fromJson(jsonData);
          return cartData;
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

  Future<String?> completeOrder({
    required String sessionId,
    required int orderId
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_completeOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'orderId': orderId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data']['pdfUrl'];
          var pdfUrl = jsonData;
          return pdfUrl.toString();

        } else {
          var msg = data['Message'];
          throw Exception(msg);
        }
      } else {
       return null;
      }
    } catch (e) {
      print('Error adding complete order $e');
      return null;
    }
  }

  Future<InvoiceCreateResponseModel?> createInvoice({
    required String sessionId,
    required int orderId
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_createInvoiceUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'orderId': orderId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final invoiceRes = InvoiceCreateResponseModel.fromJson(data);
        if (invoiceRes.control == 1) {

          return invoiceRes;

        } else {
          var msg = data['Message'];
          throw Exception(msg);
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error adding complete order $e');
      return null;
    }
  }

  Future<bool> placeOrder(
      {required String sessionId, required int cartId}) async {
    try {
      final response = await http.post(
        Uri.parse(_addOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'cartId': cartId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          return true;
        } else {
          throw Exception(data['Message']);
        }
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<bool> orderEdit(
      {
        required String sessionId, required int cartId}) async {
    try {
      final response = await http.post(
        Uri.parse(_editOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'cartId': cartId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          return true;
        } else {
          return false;
        }
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      return false;
    }
  }


}
