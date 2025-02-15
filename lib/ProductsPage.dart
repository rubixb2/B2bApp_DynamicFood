import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'package:odoosaleapp/services/ProductService.dart';
import 'package:odoosaleapp/theme.dart';

import 'helpers/SessionManager.dart';
import 'models/cart/CustomerDropListModel.dart';
import 'models/product/ProductsResponseModel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<ProductsResponseModel>> productsFuture = Future.value([]);
  final TextEditingController searchController = TextEditingController();
  CustomerDropListModel? selectedCustomer;
  late Future<List<CustomerDropListModel>> dropListFuture= Future.value([]);

  final CartService cartService = CartService();
  OverlayEntry? _overlayEntry;
  FocusNode _focusNode = FocusNode();

 /* _fetchCustomers(String filter) {
    dropListFuture = CartService().getCustomerList(sessionId: _getSessionId());
  }*/
  Future<List<CustomerDropListModel>> _fetchCustomers([String? filter]) async {
    // Filtreye göre API çağrısı yaparak müşteri listesini çekin
    // Örneğin:
    final response = await CartService().getCustomerList(sessionId: _getSessionId());
    if (true) {
      return response;
     /* final List<dynamic> data = response;
      return data.map((json) => CustomerDropListModel.fromJson(json)).toList();*/
    } else {
      throw Exception('Failed to load customers');
    }
  }

  void handleSetCustomer() async {

    SessionManager().setCustomerId(selectedCustomer!.id);
    SessionManager().setCustomerName(selectedCustomer!.name);
    SessionManager().setPriceListId(selectedCustomer!.priceListId);
    //CartPreferences.saveCustomerInfo(selectedCustomer!.id, selectedCustomer!.priceListId, selectedCustomer!.name);
    var res = await CartService().setCustomer(
        sessionId: _getSessionId(), cartId: _getCartId(), customerId: selectedCustomer!.id);
    if (res == true) {
      SessionManager().setCustomerId(selectedCustomer!.id);
      SessionManager().setCustomerName(selectedCustomer!.name);
      SessionManager().setPriceListId(selectedCustomer!.priceListId);
     // _initializeProducts();
    }
    else
      {
        SessionManager().setCustomerId(0);
        SessionManager().setCustomerName("");
        SessionManager().setPriceListId(0);
      }
  }

  String _getSessionId() {
    return SessionManager().sessionId ?? "";
  }

  int _getCustomerId() {
    return SessionManager().customerId ?? 0;
  }

  int _getPricelistId() {
    return SessionManager().priceListId ?? 0;
  }

  int _getCartId() {
    return SessionManager().cartId ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeProducts();


  /*  if(_getCustomerId() <=0)
      {
        _fetchCustomers('');
      }*/
  }

  Future<void> _initializeProducts({String searchKey = ''}) async {
    final sessionId = _getSessionId();
    final customerId = _getCustomerId();
    final pricelistId = _getPricelistId();
    setState(() {
      productsFuture = ProductService().fetchProducts(
          sessionId: sessionId,
          searchKey: searchKey,
          limit: 20,
          page: 1,
          categoryId: 0,
          customerId: customerId,
          priceListId: pricelistId);
    });
  }
  final GlobalKey<DropdownSearchState<CustomerDropListModel>> _dropdownKey =
  GlobalKey<DropdownSearchState<CustomerDropListModel>>();


  void _addToCart(BuildContext context, int productId, int piece, int box)
  //void _addToCart(BuildContext context, int productId)
  async {
    try {
      final sessionId = _getSessionId();
      final cartId = _getCartId();
      final res = await cartService.addToCart(
        sessionId: sessionId,
        cartId: cartId,
        productId: productId,
        boxQty: box,
        pieceQty: piece,
      );

      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to cart successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _getCustomerId()<=0 ?
          // Müşteri Seçimi DropdownSearch
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownSearch<CustomerDropListModel>(
              key: _dropdownKey, // GlobalKey eklendi
              selectedItem: selectedCustomer,
              popupProps: PopupProps.dialog(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: "Search Customer",
                    hintText: "Type to search",
                  ),
                ),
              ),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Select Customer",
                  hintText: "Search Customer",
                ),
              ),
              asyncItems: (String filter) async {
                return await _fetchCustomers(filter);
              },
              itemAsString: (CustomerDropListModel customer) => customer.name,
              onChanged: (value) {
                setState(() {
                  selectedCustomer = value;
                  handleSetCustomer();
                });
                // Müşteri seçildikten sonra ürünleri yükle
                _initializeProducts();
              },
            ),
          ): SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                _initializeProducts(searchKey: value);
              },
              decoration: InputDecoration(
                labelText: 'Search Products',
                hintText: 'Enter product name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProductsResponseModel>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  if (snapshot.error == "CHOOSE_CUSTOMER") {

                    // Dropdown'u otomatik açtır
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _dropdownKey.currentState?.openDropDownSearch();
                    });
                    return const Center(child: Text('Please select a customer.'));
                  }
                  return Center(child: Text('${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                final products = snapshot.data!;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => _showAddToCartModal(context, product),
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              height: 120,
                              fit: BoxFit.fitHeight,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                product.name,
                                style: AppTextStyles.bodyTextBold2
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(
                                'Stock: ${product.stockCount}',
                                style: AppTextStyles.subText
                              ),
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
    );
  }


  void _showAddToCartModal(BuildContext context, ProductsResponseModel product) {
    TextEditingController pieceController = TextEditingController(text: '0');
    TextEditingController boxController = TextEditingController(text: '1');

    void updateQuantity(TextEditingController controller, int change) {
      int currentValue = int.tryParse(controller.text) ?? 1;
      currentValue += change;
      if (currentValue < 0) currentValue = 0; // Minimum 0
      controller.text = currentValue.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ürün Bilgileri
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        height: 60,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTextStyles.bodyTextBold2,
                          ),
                          Text(
                            'Stock: ${product.stockCount}',
                            style: AppTextStyles.subText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 📌 Adet (Piece) Seçimi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Piece Quantity', style: AppTextStyles.subText),
                    Row(
                      children: [
                        _buildQuantityButton(() => updateQuantity(pieceController, -1), Icons.remove),
                        _buildEditableQuantityField(pieceController),
                        _buildQuantityButton(() => updateQuantity(pieceController, 1), Icons.add),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 📌 Kutu (Box) Seçimi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Box Quantity', style: AppTextStyles.subText),
                    Row(
                      children: [
                        _buildQuantityButton(() => updateQuantity(boxController, -1), Icons.remove),
                        _buildEditableQuantityField(boxController),
                        _buildQuantityButton(() => updateQuantity(boxController, 1), Icons.add),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    int pieceQuantity = int.tryParse(pieceController.text) ?? 0;
                    int boxQuantity = int.tryParse(boxController.text) ?? 1;

                    _addToCart(context, product.id, pieceQuantity, boxQuantity);
                    Navigator.pop(context); // Modalı kapat
                  },
                  style: AppButtonStyles.primaryButton,
                  child: const Center(
                    child: Text(
                      'Add to Cart',
                      style: AppTextStyles.buttonTextWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // + / - Butonları
  Widget _buildQuantityButton(VoidCallback onPressed, IconData icon) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      color: Colors.blue,
      splashRadius: 20,
    );
  }

  Widget _buildEditableQuantityField(TextEditingController controller) {
    return SizedBox(
      width: 100, // Aradaki alanı genişlettik
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: true,signed: false), // Sayı ve sadece tam sayılar
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Sadece sayı girilebilir
        ],
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10), // Daha iyi hizalama
          suffixIcon: Icon(Icons.done), // 'Done' simgesi, isteğe bağlı
        ),
        onTap: () {
          // Tıklanınca içeriği temizle
          controller.clear();
        },
        onChanged: (value) {
          // Girilen değeri göster ve imleci en sona taşı
          controller.value = TextEditingValue(
            text: value,
            selection: TextSelection.fromPosition(
              TextPosition(offset: value.length),
            ),
          );
        },
        textInputAction: TextInputAction.done, // "Done" butonunu aktif yap
      ),
    );
  }


}
