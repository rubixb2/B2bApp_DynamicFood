import 'dart:convert';
import 'package:http/http.dart' as http;

import '../helpers/SessionManager.dart';
import '../models/product/ProductsResponseModel.dart';

class ProductService {
  final String apiUrl = SessionManager().baseUrl+'Products/List';

  Future<List<ProductsResponseModel>> fetchProducts({
    required String sessionId,
    required String searchKey,
    required int limit,
    required int page,
    required int categoryId,
    required int customerId,
    required int priceListId,
  }) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sessionId': sessionId,
        'SearchKey': searchKey,
        'Limit': limit,
        'Page': page,
        'CategoryId': categoryId,
        'CustomerId': customerId,
        'PriceListId': priceListId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Control'] == 1) {
        final List productsJson = data['Data']['ProductList'];
        return productsJson
            .map((json) => ProductsResponseModel.fromJson(json))
            .toList();
      } else {
        var msg = data['Message'];
        throw msg;
      }
    } else {
      throw 'Failed to load products';
    }
  }
}
