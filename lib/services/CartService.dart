import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';

import '../helpers/SessionManager.dart';
import '../models/cart/CustomerDropListModel.dart';
import '../models/order/AddOrderResponseModel.dart';

// CartService Class
class CartService {
  final String _baseUrl = 'https://apiodootest.nametech.be/Api/cart/get';
  final String _createCartUrl = 'https://apiodootest.nametech.be/Api/cart/create';
  final String _addToCartUrl = 'https://apiodootest.nametech.be/Api/cart/add';
  final String _getCustomerListUrl =
      'https://apiodootest.nametech.be/Api/customers/droplist';
  final String _updateProductUrl =
      'https://apiodootest.nametech.be/Api/cart/UpdateProduct';
  final String _discountCartUrl =
      'https://apiodootest.nametech.be/Api/cart/CartDiscount';
  final String _updateCartUrl =
      'https://apiodootest.nametech.be/Api/cart/Update';
  final String _deleteProductUrl =
      'https://apiodootest.nametech.be/Api/cart/DeleteProduct';
  final String _addOrderUrl = 'https://apiodootest.nametech.be/Api/orders/add';


  Future<CartResponseModel?> fetchCart(
      {required String sessionId, required int cartId, required bool completedCart}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'cartId': cartId,'completedCart': completedCart}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
          final cartData = CartResponseModel.fromJson(jsonData);
          SessionManager().setCartId(cartData.id);
          SessionManager().setCustomerName(cartData.customerName ?? "");
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

  Future<bool> createCart(
      {required String sessionId}) async {
    try {
      final response = await http.post(
        Uri.parse(_createCartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var cartId = data['Data']['cartId'];
          SessionManager().setCartId(cartId);
          SessionManager().setCustomerName("");
          SessionManager().setCustomerId(0);
          return true;
        } else {
         return false;
        }
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (e) {
     return false;
    }
  }

  Future<bool> addToCart({
    required String sessionId,
    required int cartId,
    required int productId,
    required int pieceQty,
    required int boxQty,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_addToCartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'cartId': cartId,
          'productId': productId,
          'BoxQuantity': boxQty,
          'PieceQuantity': pieceQty,

        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
         // var jsonData = data['Data']['CartProduct'];
          /* final cartProduct = CartProductModel.fromJson(jsonData);
          return cartProduct;*/
          return true;
        } else {
          var msg = data['Message'];
          throw Exception(msg);
        }
      } else {
        throw Exception('Failed to add product to cart');
      }
    } catch (e) {
      print('Error adding product to cart: $e');
      return false;
    }
  }
  Future<bool> cartDiscount({
    required String sessionId,
    required int orderId,
    required double val,
    required String type
  }) async {
    try {
      double per = type == "percentage" ? val.toDouble() : 0.0 .toDouble();
      double amount = type == "amount" ? val.toDouble() : 0.0 .toDouble();
      final response = await http.post(
        Uri.parse(_discountCartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'orderId': orderId,
          'proccess': type,
          'percentage': per,
          'amount': amount,

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
        throw Exception('Failed to add product to cart');
      }
    } catch (e) {
      print('Error adding product to cart: $e');
      return false;
    }
  }

  Future<bool> updateProduct({
    required String sessionId,
    required int cartId,
    required int cartProductId,
    required double pieceQuantity,
    required double boxQuantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_updateProductUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'cartId': cartId,
          'cartProductId': cartProductId,
          'pieceQuantity': pieceQuantity,
          'boxQuantity': boxQuantity,
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
  }

  Future<AddOrderResponseModel?> placeOrder(
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
          var jsonData = data['Data']['Order'];
          final customerData = AddOrderResponseModel.fromJson(jsonData);
          return customerData;
         // return true;
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print('Error updating product: $e');
    return null;
    }
  }

  Future<bool> deleteCart(
      {required String sessionId, required int cartId}) async {
    try {
      final response = await http.post(
        Uri.parse(_updateCartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'cartId': cartId,
          'Process': 'delete',
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
  }

  Future<bool> deleteProduct(
      {required String sessionId, required int cartId,required int cartProductId}) async {
    try {
      final response = await http.post(
        Uri.parse(_deleteProductUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'cartId': cartId,
          'cartProductId': cartProductId,
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
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<bool> setCustomer(
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
  }

  Future<List<CustomerDropListModel>> getCustomerList(
      {required String sessionId}) async {
    try {
      final response = await http.post(
        Uri.parse(_getCustomerListUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          final dd = data['Data']['CustomerList'] as List;
          return dd
              .map((customer) => CustomerDropListModel.fromJson(customer))
              .toList();
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
}
