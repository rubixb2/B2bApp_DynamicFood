import 'package:flutter/material.dart';
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';
import 'package:odoosaleapp/models/product/ProductsResponseModel.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:odoosaleapp/services/InvoiceService.dart';
import 'package:odoosaleapp/services/OrderService.dart';

import 'helpers/PdfScreen.dart';
import 'models/cart/CartProductModel.dart';
import 'models/cart/CustomerDropListModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/invoice/PaymentLineTypeResponseModel.dart';
import 'theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<CartResponseModel?> cartFuture = Future.value();
  final CartService cartService = CartService();
  late Future<List<CustomerDropListModel>> dropListFuture = Future.value([]);
  late Future<PaymentLineTypeResponseModel?> paymentListFuture = Future.value();
  int _cartId = 0;
  int _customerId = 0;
  String _customerName = '';
  String _sessionId = '';

  bool _orderCompleted = false;
  bool _incoiceCreated = false;
  String _orderPdfUrl = '';
  String _invoicePdfUrl = '';
  String _amount = '';
  double amount = 0;
  int _invoiceId = 0;
  int paymentMethodId = 0;
  bool _isAddButtonEnabled = true;
  PaymentMethod? selectedMethod; // Seçili müşteri
  final _formKey = GlobalKey<FormState>();


  CustomerDropListModel? selectedCustomer; // Seçili müşteri

  @override
  void initState() {
    super.initState();
    _initializeCart();
    _fetchPaymentMethods();
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
            CartService().fetchCart(sessionId: sessionId, cartId: cartId,completedCart: false);
      });
    } else {
      setState(() {
        cartFuture =
            CartService().fetchCart(sessionId: sessionId, cartId: cartId,completedCart: false);

      });
    }
    _cartId = _getCartId();
    while(_cartId == 0)
    {
      await Future.delayed(const Duration(milliseconds: 10));
      _cartId = _getCartId();
    }
    setState(() {
      _customerName = _getCustomerName();
      _cartId = _getCartId();

    });
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
              cartService.fetchCart(sessionId: sessionId, cartId: cartId,completedCart: false);
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
            '$_cartId-${_customerName.length > 15 ? _customerName.substring(0, 15) : _customerName}'
            ,style: AppTextStyles.bodyTextBold
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
              style: AppTextStyles.bodyTextBold,


              ),
                SizedBox(width: 15),
                Text(
                  'T.Total: \€${cartAmountTaxed.toStringAsFixed(2)}', // Ondalık basamak ekleyerek düzgün görünmesini sağlıyoruz
                  style: AppTextStyles.bodyTextBold,
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else
                  if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final cart = snapshot.data;
                if (cart == null || cart.cartProducts.isEmpty) {
                 // return const Center(child: CircularProgressIndicator());
                  return const Center(child: Text('Cart is Empty',style: AppTextStyles.list2,));
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
                                    style: AppTextStyles.bodyTextBold,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total Price: ${product.productTotalPrice.toStringAsFixed(2)}',
                                    style: AppTextStyles.subText,
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
            onPressed: _confirmAddOrder, // Sipariş oluşturma fonksiyonu
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

      if (success)
      {
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
        cartFuture = cartService.fetchCart(sessionId: sessionId, cartId: cartId,completedCart: false);
        _cartId = _getCartId();
        while(_cartId == 0)
          {
            await Future.delayed(const Duration(milliseconds: 10));
            _cartId = _getCartId();
          }
        //await Future.delayed(const Duration(seconds: 1));
        setState(() {
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
              cartService.fetchCart(sessionId: sessionId, cartId: cartId,completedCart: false);
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
    _orderPdfUrl = "";
    _invoicePdfUrl = "";
    try {
      final sessionId = _getSessionId();
      final cartId = _getCartId();

      // Order işlemi için servisi çağır
      final res = await cartService.placeOrder(
        sessionId: sessionId,
        cartId: cartId,
      );

      if (res != null && res.id >0) {
        dropListFuture = CartService().getCustomerList(sessionId: sessionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        await resetCart();
        _showOrderModal(res.id);
      /*  SessionManager().setCartId(0);
        SessionManager().setCustomerName('');
        SessionManager().setCustomerId(0);
        SessionManager().setPriceListId(0);
        _cartId = _getCartId();
        _customerName = _getCustomerName();
        _customerId = _getCustomerId();
        _showOrderModal(res.id);
        setState(() {
          cartFuture = cartService.fetchCart(sessionId: sessionId, cartId: 0);
        });*/

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  Future<void> resetCart()  async {
    SessionManager().setCartId(0);
    SessionManager().setCustomerName('');
    SessionManager().setCustomerId(0);
    SessionManager().setPriceListId(0);
    _cartId = _getCartId();
    _customerName = _getCustomerName();
    _customerId = _getCustomerId();
    cartService.createCart(sessionId: _getSessionId());
    while(_cartId == 0)
    {
      await Future.delayed(const Duration(milliseconds: 10));
      _cartId = _getCartId();
    }
    cartFuture = cartService.fetchCart(sessionId: _getSessionId(), cartId: _cartId,completedCart: false);
    setState(() {
      _cartId = _getCartId();
      _customerName = _getCustomerName();
      _customerId = _getCustomerId();
    });
    while(_cartId == 0)
    {
      await Future.delayed(const Duration(milliseconds: 10));
      _cartId = _getCartId();
    }
    setState(() {
      _cartId = _getCartId();
      _customerName = _getCustomerName();
      _customerId = _getCustomerId();

    });
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
          content: const Text('Are you sure you want to delete the cart? This action cannot be undone.',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // İptal butonu
              child: const Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                _deleteCart(); // Sepeti sil
              },
              child: const Text('Delete', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.dangerButton,

            ),
          ],
        );
      },
    );
  }

  void _confirmAddOrder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Order'),
          content: const Text('Order will be added, Do you confirm?',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // İptal butonu
              child: const Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                _placeOrder(); // Sepeti sil
              },
              child: const Text('Confirm', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,

            ),
          ],
        );
      },
    );
  }

  void _showOrderModal(int orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Order ID: $orderId',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    'Invoice ID: $_invoiceId',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // Order ID Gösterimi

              // İki Kolonlu Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 1. Kolon
                  Column(
                    children: [
                      SizedBox(
                        width: 180 ,
                          child:
                      ElevatedButton(

                        onPressed: () { _orderCompleted == false ?
                          showDiscountModal(orderId,context) : null;
                        },
                        child: Text('Apply Discount', style: AppTextStyles.buttonTextWhite),
                        style: _orderCompleted == false ? AppButtonStyles.primaryButton  : AppButtonStyles.notrButton,
                      ))
                      ,
                      SizedBox(height: 10),
                      SizedBox(
                        width: 180 ,
                        child:
                      ElevatedButton(
                        onPressed: () { _orderCompleted == false ?
                          _confirmCompleteOrder(orderId) : null;
                        },
                        child: Text('Complete Order', style: AppTextStyles.buttonTextWhite),
                        style:  _orderCompleted == false ? AppButtonStyles.primaryButton  : AppButtonStyles.notrButton,
                      )
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 180 ,
                        child:
                      ElevatedButton(
                        onPressed: () {
                          _orderCompleted && _orderPdfUrl.isNotEmpty  ? _openPdf(_orderPdfUrl): null;
                        },
                        child: Text('Order PDF', style: AppTextStyles.buttonTextWhite),
                        style:  _orderCompleted && _orderPdfUrl.isNotEmpty  ?  AppButtonStyles.confimButton : AppButtonStyles.notrButton,
                      )
                      ),
                    ],
                  ),
                  Spacer(),

                  // 2. Kolon
                  Column(
                    children: [
                      SizedBox(
                        width: 180 ,
                        child:
                      ElevatedButton(
                        onPressed: () { _orderCompleted && orderId>0 && _invoiceId == 0 && _incoiceCreated == false ?
                          _confirmInvoiceCreate(orderId) : null;
                        },
                        child: Text('Create Invoice', style: AppTextStyles.buttonTextWhite),
                        style: _orderCompleted && orderId >0  && _invoiceId == 0 && _incoiceCreated == false
                            ?  AppButtonStyles.primaryButton: AppButtonStyles.notrButton,
                      )
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                          width: 180 ,
                          child:
                          ElevatedButton(
                            onPressed: () { _incoiceCreated && _invoiceId>0 ?
                              _openAddPaymentModal(_invoiceId): null;
                            },
                            child: Text('Add Payment', style: AppTextStyles.buttonTextWhite),
                            style:_incoiceCreated && _invoiceId > 0 ? AppButtonStyles.primaryButton: AppButtonStyles.notrButton,
                          )
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 180 ,
                        child:
                      ElevatedButton(
                        onPressed: () {
                          _invoicePdfUrl.isNotEmpty  ? _openPdf(_invoicePdfUrl): null;
                        },
                        child: Text('Invoice PDF', style: AppTextStyles.buttonTextWhite),
                        style:  _invoicePdfUrl.isNotEmpty  ?  AppButtonStyles.confimButton : AppButtonStyles.notrButton,
                      )
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child:
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close',style: AppTextStyles.buttonTextWhite),
                style: AppButtonStyles.secondaryButton,
              )
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPdf(String url) {
    print('Opening PDF: $url');
    openPdf(context, url);
  }

  void openPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(url: url),
      ),
    );
  }

  void _confirmCompleteOrder(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Order'),
          content: const Text('Order will be completed, Do you confirm?',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // İptal butonu
              child: const Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                completeOrder(id); // Sepeti sil
              },
              child: const Text('Confirm', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,

            ),
          ],
        );
      },
    );
  }

  void completeOrder(int id) async {
    _orderPdfUrl = "";
    try {
      final sessionId = _getSessionId();

      // Cart silme işlemi için servisi çağır
      final pdfUrl = await OrderService().completeOrder(
        sessionId: sessionId,
        orderId: id,
      );

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        setState(() {
          Navigator.of(context).pop();
          _orderPdfUrl = pdfUrl;
          _orderCompleted = true;
          _showOrderModal(id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order completed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      else
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed complete order: $e')),
      );
    }
  }

  void _confirmInvoiceCreate(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invoice Create '),
          content: const Text('Invoice will be created, Do you confirm?',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // İptal butonu
              child: const Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                invoiceCreate(id); // Sepeti sil
              },
              child: const Text('Confirm', style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,

            ),
          ],
        );
      },
    );
  }

  void invoiceCreate(int id) async {
    _invoicePdfUrl = "";
    try {
      final sessionId = _getSessionId();

      // Cart silme işlemi için servisi çağır
      final invoice = await OrderService().createInvoice(
        sessionId: sessionId,
        orderId: id,
      );

      if (invoice != null && invoice.data.pdfUrl.isNotEmpty)
      {
        setState(() {
          Navigator.of(context).pop();
          _invoiceId = invoice.data.invoiceId;
          _invoicePdfUrl = invoice.data.pdfUrl;
          _incoiceCreated = true;
          _showOrderModal(id);
          //_openAddPaymentModal(_invoiceId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('invoice created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      else
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed complete order: $e')),
      );
    }
  }

  void showDiscountModal(int id,BuildContext ctx) {
    TextEditingController percentageController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    String selectedType = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Apply Discount"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: percentageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Discount Percentage"),
                enabled: selectedType != "amount",
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      selectedType = "percentage";
                      amountController.clear();
                    });
                  }
                },
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Discount Amount"),
                enabled: selectedType != "percentage",
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      selectedType = "amount";
                      percentageController.clear();
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.notrButton,
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedType.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İnvalid value'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }

                double discountValue = selectedType == "percentage"
                    ? double.parse(percentageController.text)
                    : double.parse(amountController.text);

                // _confirmDiscount(id, discountValue, selectedType);
                _applyDiscount(id, discountValue, selectedType,ctx);
                Navigator.of(context).pop();
              },
              child: Text("Apply", style: AppTextStyles.buttonTextWhite),
              style: AppButtonStyles.confimButton,
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyDiscount(int id, double value, String type,BuildContext ctx) async {
    try {
      final sessionId = _getSessionId();

      final res = await CartService().cartDiscount(
          sessionId: sessionId,
          orderId: id,
          val: value,
          type: type
      );

      if (res) {

        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Discount apply successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      else
      {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('An error occured!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Failed to discount apply: $e')),
      );
    }

  }

  void _openAddPaymentModal(int id) {
    _invoiceId = id;
    // _isAddButtonEnabled=false;
    // _selectedMethod = null;
    selectedMethod=null;
    _amount = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Payment'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<PaymentLineTypeResponseModel?>(
                  future: paymentListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final dropList = snapshot.data!.PaymentTypeList;
                    if (dropList == null || dropList.isEmpty) {
                      return const Center(
                          child: Text('No customers available.'));
                    }

                    return DropdownSearch<PaymentMethod>(
                      selectedItem: selectedMethod,
                      popupProps: PopupProps.dialog(
                        showSearchBox: false, // Arama kutusunu gösterir
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: "Search method",
                            hintText: "Type to search",
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select Payment Method",
                          hintText: "Search Method",
                        ),
                      ),
                      asyncItems: (String filter) async {
                        // Filtreyi kullanarak veriyi dinamik olarak çek
                        final filteredList = await _fetchPaymentMethods();
                        return filteredList!.PaymentTypeList;
                      },
                      itemAsString: (PaymentMethod customer) => customer.name,
                      onChanged: (value) {
                        setState(() {
                          paymentMethodId = value != null ? value!.id : 0;
                          selectedMethod = value;
                        });
                      },
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _amount = value;
                      amount = double.tryParse(_amount.replaceAll(",", ".")) ?? 0;
                      // _validateForm();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.confimButton,
              onPressed: _isAddButtonEnabled
                  ? () {

                _confirmPayment();
              }
                  : null,
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePayment() async {
    var res = await InvoiceService().addPayment(sessionId: _getSessionId(),amount: amount,invoiceId: _invoiceId,paymentType: paymentMethodId);
    if (res)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text( amount.toString() + 'Payment added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
     //   _invoiceId = 0;
    //    paymentMethodId = 0;
     //   amount = 0;
     //   _amount = "";
      });
     // await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occured.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmPayment() {

    amount>0 && paymentMethodId>0 ?
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Payment'),
          content: Text(
              'A payment of €$amount will be recorded. Do you confirm?',style: AppTextStyles.buttonTextBlack),
          actions: [
            TextButton(
              child: Text('Cancel',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.notrButton,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm',style: AppTextStyles.buttonTextWhite,),
              style: AppButtonStyles.confimButton,
              onPressed: () {
                Navigator.of(context).pop();
                _makePayment();
              },
            ),
          ],
        );
      },
    ): null;
  }

  Future<PaymentLineTypeResponseModel?> _fetchPaymentMethods() async {
    try {
      paymentListFuture = InvoiceService().fetchPaymentMethods(sessionId: _getSessionId());
      return paymentListFuture ?? null ;
    } catch (e) {
      print("Error fetching payment methods: $e");
    }

  }

}
