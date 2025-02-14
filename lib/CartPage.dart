import 'package:flutter/material.dart';
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';
import 'package:odoosaleapp/models/product/ProductsResponseModel.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'models/cart/CartProductModel.dart';
import 'models/cart/CustomerDropListModel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<CartResponseModel?> cartFuture = Future.value();
  final CartService cartService = CartService();
  late Future<List<CustomerDropListModel>> dropListFuture = Future.value([]);
  int _cartId = 0;
  int _customerId = 0;
  String _customerName = '';
  String _sessionId = '';
  CustomerDropListModel? selectedCustomer; // Seçili müşteri

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final sessionId = _getSessionId();
    final cartId = _getCartId();
    final customerId = _getCustomerId();
    final customerName = _getCustomerName();
    _cartId = cartId;
    _customerId = customerId;
    _customerName = customerName;
    _sessionId = sessionId;

    if (_customerId == 0) {
      setState(() {
        dropListFuture = CartService().getCustomerList(sessionId: sessionId);
        cartFuture =
            CartService().fetchCart(sessionId: sessionId, cartId: cartId);
      });
    } else {
      setState(() {
        cartFuture =
            CartService().fetchCart(sessionId: sessionId, cartId: cartId);

      });
    }
  }

  String _getSessionId() {
    return SessionManager().sessionId ?? '';
  }

  int _getCustomerId() {
    return SessionManager().customerId ?? 0;
  }

  String _getCustomerName() {
    return SessionManager().customerName ?? '';
  }

  int _getCartId() {
    return SessionManager().cartId ?? 0;
  }

  void _updateProductQuantity({
    required CartProductModel product,
    required double newPieceQuantity,
    required double newBoxQuantity,
  }) async {
    try {
      final sessionId = _getSessionId();
      final cartId = _getCartId();

      var updateRes = await cartService.updateProduct(
        sessionId: sessionId,
        cartId: cartId,
        cartProductId: product.id,
        // cartProductId: product.productId,
        pieceQuantity: newPieceQuantity < 0 ? 0 : newPieceQuantity,
        boxQuantity: newBoxQuantity < 0 ? 0 : newBoxQuantity,
      );

      // Güncellenmiş veriyi yeniden al
      // if(updateRes == false)
      if (true) {
        setState(() {
          cartFuture =
              cartService.fetchCart(sessionId: sessionId, cartId: cartId);
        });
      } else {
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Row(children: [
          Text(
            '$_cartId-${_customerName.length > 10 ? _customerName.substring(0, 10) : _customerName}'
            ,style: TextStyle(fontSize: 14)
        ),
          Spacer(),
          FutureBuilder<CartResponseModel?>(
            future: cartFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Total: Loading...', style: TextStyle(fontSize: 14));
              } else if (snapshot.hasError) {
                return const Text('Total: Error', style: TextStyle(fontSize: 14, color: Colors.red));
              } else if (!snapshot.hasData) {
                return const Text('Total: 0', style: TextStyle(fontSize: 14));
              }
              //final cartAmount = snapshot.data!.cartProducts.;
              final cartAmountTaxed  = snapshot.data!.cartProducts
                  .map((product) => product.taxedTotalPrice)
                  .fold(0.0, (sum, taxedTotal) => sum + taxedTotal);
              final cartAmount  = snapshot.data!.cartProducts
                  .map((product) => product.productTotalPrice)
                  .fold(0.0, (sum, productTotalPrice) => sum + productTotalPrice);
              return Row(children: [
              Text(
              'Total: \€${cartAmount.toStringAsFixed(2)}', // Ondalık basamak ekleyerek düzgün görünmesini sağlıyoruz
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),


              ),
                SizedBox(width: 15),
                Text(
                  'T.Total: \€${cartAmountTaxed.toStringAsFixed(2)}', // Ondalık basamak ekleyerek düzgün görünmesini sağlıyoruz
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],);
            },
          ),
        ]
    )
      ),
      body: Column(
        children: [
          _customerId > 0
              ? Container()
              :
          // Dropdown Search with Future update
          FutureBuilder<List<CustomerDropListModel>>(
            future: dropListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final dropList = snapshot.data;
              if (dropList == null || dropList.isEmpty) {
                return const Center(
                    child: Text('No customers available.'));
              }

              return DropdownSearch<CustomerDropListModel>(
                selectedItem: selectedCustomer,
                popupProps: PopupProps.dialog(
                  showSearchBox: true, // Arama kutusunu gösterir
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
                  // Filtreyi kullanarak veriyi dinamik olarak çek
                  final filteredList = await _fetchCustomers(filter);
                  return filteredList;
                },
                itemAsString: (CustomerDropListModel customer) => customer.name,
                onChanged: (value) {
                  _cartId = _getCartId();
                  setState(() {
                    selectedCustomer = value;
                    handleSetCustomer();
                  });
                },
              );
            },
          ),

          Expanded(child: FutureBuilder<CartResponseModel?>(
              future: cartFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final cart = snapshot.data;
                if (cart == null || cart.cartProducts.isEmpty) {
                  return const Center(child: Text('Cart is empty.'));
                }

                return ListView.builder(
                  itemCount: cart.cartProducts.length,
                  itemBuilder: (context, index) {
                    final product = cart.cartProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product.imageUrl != null
                                      ? Image.network(
                                    product.imageUrl!,
                                    height: 50,
                                    fit: BoxFit.fitHeight,
                                  )
                                      : Container(
                                    width: 30,
                                    height: 30,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeItem(product),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),

                              ],
                            ),
                            // Product Image
                            const SizedBox(width:10 ),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Name and Total Price
                                  Text(
                                    product.productName ?? 'Product Name',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total Price: ${product.productTotalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 3),

                                  // Piece Quantity and Box Quantity Controls
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Piece Quantity Control
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: product.pieceQuantity > 0
                                                ? () {
                                                    _updateProductQuantity(
                                                      product: product,
                                                      newPieceQuantity: product
                                                              .pieceQuantity -
                                                          1,
                                                      newBoxQuantity:
                                                          product.boxQuantity,
                                                    );
                                                  }
                                                : null,
                                            icon: const Icon(Icons.remove),
                                          ),

                                          SizedBox(
                                            width: 30,
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              controller: TextEditingController(
                                                text: product.pieceQuantity.toInt()
                                                    .toString(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              readOnly: true,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _updateProductQuantity(
                                                product: product,
                                                newPieceQuantity:
                                                    product.pieceQuantity + 1,
                                                newBoxQuantity:
                                                    product.boxQuantity,
                                              );
                                            },
                                            icon: const Icon(Icons.add),
                                          ),
                                        ],
                                      ),

                                      // Box Quantity Control
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: product.boxQuantity > 0
                                                ? () {
                                                    _updateProductQuantity(
                                                      product: product,
                                                      newPieceQuantity:
                                                          product.pieceQuantity,
                                                      newBoxQuantity:
                                                          product.boxQuantity -
                                                              1,
                                                    );
                                                  }
                                                : null,
                                            icon: const Icon(Icons.remove),
                                          ),
                                          SizedBox(
                                            width: 30,
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              controller: TextEditingController(
                                                text: product.boxQuantity.toInt()
                                                    .toString(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              readOnly: true,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _updateProductQuantity(
                                                product: product,
                                                newPieceQuantity:
                                                    product.pieceQuantity,
                                                newBoxQuantity:
                                                    product.boxQuantity + 1,
                                              );
                                            },
                                            icon: const Icon(Icons.add),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _placeOrder, // Sipariş oluşturma fonksiyonu
            heroTag: 'orderBtn',
            tooltip: 'Place Order',
            child: const Icon(Icons.shop),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _confirmDeleteCart,
            // Sepeti silme fonksiyonu
            heroTag: 'deleteCartBtn',
            tooltip: 'Delete Cart',
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
  Future<List<CustomerDropListModel>> _fetchCustomers(String query) async {
    // Burada arama metnine göre filtreleyip veriyi getirebilirsiniz
    final allCustomers = await dropListFuture;
    if (query.isEmpty) {
      return allCustomers ?? [];
    } else {
      return allCustomers
          ?.where((customer) =>
          customer.name.toLowerCase().contains(query.toLowerCase()))
          .toList() ??
          [];
    }
  }
  void _deleteCart() async {
    try {
      final sessionId = _getSessionId();
      final cartId = _getCartId();

      // Cart silme işlemi için servisi çağır
      final success = await cartService.deleteCart(
        sessionId: sessionId,
        cartId: cartId,
      );

      if (success) {
        dropListFuture = CartService().getCustomerList(sessionId: sessionId);
        SessionManager().setCartId(0);
        SessionManager().setCustomerName('');
        SessionManager().setCustomerId(0);
        SessionManager().setPriceListId(0);
        _cartId = _getCartId();
        _customerId = _getCustomerId();
        _customerName = _getCustomerName();

     /*   ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart deleted successfully!')),
        );*/
        setState(() {
          cartFuture =
              cartService.fetchCart(sessionId: sessionId, cartId: cartId);
          _cartId = _getCartId();
          _customerId = _getCustomerId();
          _customerName = _getCustomerName();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete cart: $e')),
      );
    }
  }

  void _removeItem(CartProductModel product) async {
    try {
      final sessionId = _getSessionId();
      final cartId = _getCartId();

      // Cart silme işlemi için servisi çağır
      final success = await cartService.deleteProduct(
        sessionId: sessionId,
        cartId: cartId,
        cartProductId: product.id,
      );

      if (success) {

       /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );*/
        setState(() {
          cartFuture =
              cartService.fetchCart(sessionId: sessionId, cartId: cartId);
          _cartId = _getCartId();
          _customerId = _getCustomerId();
          _customerName = _getCustomerName();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  void _placeOrder() async {
    try {
      final sessionId = _getSessionId();
      final cartId = _getCartId();

      // Order işlemi için servisi çağır
      final success = await cartService.placeOrder(
        sessionId: sessionId,
        cartId: cartId,
      );

      if (success) {
        dropListFuture = CartService().getCustomerList(sessionId: sessionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        SessionManager().setCartId(0);
        SessionManager().setCustomerName('');
        SessionManager().setCustomerId(0);
        SessionManager().setPriceListId(0);
        _cartId = _getCartId();
        _customerName = _getCustomerName();
        _customerId = _getCustomerId();
        setState(() {
          cartFuture = cartService.fetchCart(sessionId: sessionId, cartId: 0);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  void handleSetCustomer() async {
    _cartId = _getCartId();
    _customerId = selectedCustomer!.id;
    _customerName = selectedCustomer!.name.replaceAll('\n', ' ');
    //CartPreferences.saveCustomerInfo(selectedCustomer!.id, selectedCustomer!.priceListId, selectedCustomer!.name);
    var res = await CartService().setCustomer(
        sessionId: _sessionId, cartId: _cartId, customerId: _customerId);
    if (res == true) {
      SessionManager().setCustomerId(_customerId);
      SessionManager().setCustomerName(_customerName);
      SessionManager().setPriceListId(selectedCustomer!.priceListId);
    }
  }

  void _confirmDeleteCart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Cart'),
          content: const Text('Are you sure you want to delete the cart? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // İptal butonu
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                _deleteCart(); // Sepeti sil
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

}
