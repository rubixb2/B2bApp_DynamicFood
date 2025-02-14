import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/models/order/OrdersResponseModel.dart';

import '../helpers/SessionManager.dart';
import '../models/cart/CustomerDropListModel.dart';

// CartService Class
class OrderService {
  final String _baseUrl = 'https://apiodootest.nametech.be/Api/orders/List';
  final String _completeOrderUrl = 'https://apiodootest.nametech.be/Api/orders/complete';
  final String _getCustomerListUrl =
      'https://apiodootest.nametech.be/Api/customers/droplist';
  final String _updateProductUrl =
      'https://apiodootest.nametech.be/Api/cart/UpdateProduct';
  final String _updateCartUrl =
      'https://apiodootest.nametech.be/Api/cart/Update';
  final String _deleteProductUrl =
      'https://apiodootest.nametech.be/Api/cart/DeleteProduct';
  final String _addOrderUrl = 'https://apiodootest.nametech.be/Api/orders/add';
  final String _editOrderUrl = 'https://apiodootest.nametech.be/Api/cart/activate';


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

  Future<bool> completeOrder({
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

          return true;
        } else {
          var msg = data['Message'];
          throw Exception(msg);
        }
      } else {
        throw Exception('Failed complete order');
      }
    } catch (e) {
      print('Error adding complete order $e');
      return false;
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
      {required String sessionId, required int cartId}) async {
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

/*  Future<bool> setCustomer(
      {required String sessionId,
      required int cartId,
      required int customerId}) async {
    try {
      final response = await http.post(
        Uri.parse(_updateCartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'cartId': cartId,
          'Process': 'update',
          'customerId': customerId
        }),
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
  }*/


}
