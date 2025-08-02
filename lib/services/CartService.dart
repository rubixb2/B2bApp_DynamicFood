import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';

import '../helpers/SessionManager.dart';
import '../models/cart/CustomerDropListModel.dart';
import '../models/home/CarouselResponseModel.dart';
import '../models/order/AddOrderResponseModel.dart';
import '../models/product/CategoryResponseModel.dart';

// CartService Class
class CartService {
  //final String _baseUrl = SessionManager().baseUrl+'cart/get';
  final String _baseUrl = SessionManager().baseUrl+'B2bSale/GetCart';
  final String _cartLimitControl = SessionManager().baseUrl+'B2bSale/CartLimitControl';
  final String _categoryUrl = SessionManager().baseUrl+'B2bSale/categorylist';
  final String _carouselUrl = SessionManager().baseUrl+'B2bSale/GetCarouselData';
  //final String _createCartUrl = SessionManager().baseUrl+'cart/create';
  final String _createCartUrl = SessionManager().baseUrl+'B2bSale/CreateCart';
  final String _addToCartUrl = SessionManager().baseUrl+'B2bSale/AddProduct';
  final String _getCustomerListUrl =
      SessionManager().baseUrl+'customers/droplist';
  final String _updateProductUrl =
      SessionManager().baseUrl+'B2bSale/UpdateProduct';
  final String _discountCartUrl =
      SessionManager().baseUrl+'cart/CartDiscount';
  final String _updateCartUrl =
      SessionManager().baseUrl+'B2bSale/Update';
  final String _deleteProductUrl =
      SessionManager().baseUrl+'B2bSale/DeleteProduct';
  final String _addOrderUrl = SessionManager().baseUrl+'orders/add';


  Future<CartResponseModel?> fetchCart(
      {required String sessionId, required int cartId, required bool completedCart}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'cartId': cartId,'completedCart': completedCart,'customerId': SessionManager().customerId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
          final cartData = CartResponseModel.fromJson(jsonData);
         // int cid = cartData.customerId == '' ? 0 : int.parse(cartData.customerId);
         // SessionManager().setCartId(cartData.id);
          // SessionManager().setCustomerId(cid);
          // SessionManager().setCustomerName(cartData.customerName ?? "");
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

  Future<String> fetchCartLimit(
      {required String sessionId, required int cartId,  required String deliveryType, }) async {
    try {
      final response = await http.post(
        Uri.parse(_cartLimitControl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'cartId': cartId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          return "success";
        } else {
          var msg = data['Message'];
          return msg;
        }
      } else {
        return "Failed limit control";
      }
    } catch (e) {
      return 'Error fetching cart: $e';
    }
  }

  Future<bool> createCart(
      {
        required String sessionId, required int customerId
      }) async {
    try {
      final response = await http.post(
        Uri.parse(_createCartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'customerId': customerId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var cartId = data['Data']['cartId'];
          SessionManager().setCartId(cartId);
        //  SessionManager().setCustomerName("");
         // SessionManager().setCustomerId(0);
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
      required int customerId,
      required int priceListId}) async {
    try {
      final response = await http.post(
        Uri.parse(_updateCartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'cartId': cartId,
          'Process': 'update',
          'customerId': customerId,
          'priceListId': priceListId == 0 ? 1 : priceListId
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


  Future<List<CategoryResponseModel>> fetchCategories({
    required String sessionId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_categoryUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'Page': page,
          'Limit': limit,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          final categoryList = data['Data']['CategoryList'] as List;
          return categoryList.map((json) {
            final category = CategoryResponseModel.fromJson(json);
            // Use placeholder if image URL is empty
            return CategoryResponseModel(
              id: category.id,
              name: category.name,
              imageUrl: category.imageUrl.isEmpty
                  ? 'https://picsum.photos/100?random=${category.id}'
                  : category.imageUrl,
            );
          }).toList();
        } else {
          throw Exception(data['Message'] ?? 'Failed to load categories');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }


  Future<List<CarouselResponseModel>> fetchCarouselItems({
    required String sessionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_carouselUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          final carouselList = data['Data']['CarouselList'] as List;
          return carouselList.map((json) => CarouselResponseModel.fromJson(json)).toList();
        } else {
          throw Exception(data['Message'] ?? 'Failed to load carousel items');
        }
      } else {
        throw Exception('Failed to load carousel: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching carousel items: $e');
      rethrow;
    }
  }

}
