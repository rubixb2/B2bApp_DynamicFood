import 'dart:convert';
import 'package:http/http.dart' as http;

import '../helpers/SessionManager.dart';
import '../models/product/ProductsResponseModel.dart';

class ProductService {
  final String apiUrl = SessionManager().baseUrl+'B2bSale/productList';

  Future<List<ProductsResponseModel>> fetchProducts({
    required String sessionId,
    required String searchKey,
    required int limit,
    required int page,
    required int catId,
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
        'catId': catId,
        'CustomerId': customerId,
        'PriceListId': priceListId == 0 ? 1: priceListId
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
