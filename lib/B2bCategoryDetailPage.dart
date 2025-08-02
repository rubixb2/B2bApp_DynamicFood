import 'package:flutter/material.dart';
import 'package:odoosaleapp/services/ProductService.dart';
import 'package:odoosaleapp/shared/ProductCart.dart';

import 'helpers/FlushBar.dart';
import 'helpers/SessionManager.dart';
import 'helpers/Strings.dart';
import 'models/product/ProductsResponseModel.dart';

class CategoryDetailPage extends StatefulWidget {
  final int categoryId;

  const CategoryDetailPage({Key? key, required this.categoryId}) : super(key: key);

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late Future<List<ProductsResponseModel>> _productsFuture;
  final ProductService _productService = ProductService();
  List<ProductsResponseModel> _allProducts = [];
  List<ProductsResponseModel> _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts(categoryId: widget.categoryId);
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ProductsResponseModel>> _fetchProducts({int categoryId = 0}) async {
    try {
      final sessionId = SessionManager().sessionId ?? "";
      final customerId = SessionManager().customerId ?? 0;
      final products = await _productService.fetchProducts(
        sessionId: sessionId,
        searchKey: '',
        limit: 10,
        page: 1,
        catId: categoryId,
        customerId: customerId,
        priceListId: 1,
      );
      _allProducts = products;
      _filteredProducts = products;
      return products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      showCustomErrorToast(context, '${Strings.generalError}: ${e}');
      return [];
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.name?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.categoryProductsTitle),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: Strings.searchProductsHint,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProductsResponseModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('${Strings.generalError}: ${snapshot.error}'),
                  );

                }

                if (!snapshot.hasData || _filteredProducts.isEmpty) {
                  return Center(
                    child: Text(Strings.noProductsFound),
                  );

                }

                final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(product: product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}