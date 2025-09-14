import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/B2bCheckoutPage.dart';
import 'package:odoosaleapp/helpers/FlushBar.dart';
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';
import 'package:odoosaleapp/models/cart/PickupModel.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/models/cart/CartProductModel.dart';
import 'package:odoosaleapp/shared/CartState.dart';
import 'package:odoosaleapp/shared/ProductDetailModal.dart';
import 'package:provider/provider.dart';

import 'helpers/Strings.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({Key? key}) : super(key: key);

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final CartService _cartService = CartService();
  late Future<CartResponseModel?> _cartFuture;
  bool _isLoading = false;
  int _cartId = 0;
  double _cartTotal = 0;
  double _deliveryLimit = 0;
  double _pickupLimit = 0;
  List<PickupModel> _pickupList = [];
  String? _selectedDeliveryType; // null by default
  int? _selectedPickupId;
  bool _isDeliveryChoiceEnabled = false;
  bool _isDeliveryChoiceEnabledCheckOut = false;
  String _currency = '€'; // SessionManager'dan yüklenecek


  @override
  void initState() {
    super.initState();
    _checkDeliveryChoiceSettings();
    _loadCart();
  }

  // Teslimat türü seçimi ayarlarını kontrol et
  void _checkDeliveryChoiceSettings() {
    _isDeliveryChoiceEnabled = SessionManager().b2bChooseDeliveryType == 1;
    _isDeliveryChoiceEnabledCheckOut = SessionManager().b2bChooseDeliveryTypeCheckOut == 1;
    _currency = SessionManager().b2bCurrency;
    
    if (_isDeliveryChoiceEnabled) {
      _selectedDeliveryType = SessionManager().selectedDeliveryType;
      _selectedPickupId = SessionManager().selectedWarehouseId;
      _deliveryLimit = SessionManager().b2bDeliveryLimit;
      _pickupLimit = SessionManager().b2bPickupLimit;
    }
  }

  // Minimum limit kontrolü
  bool _isMinimumLimitMet() {
    if (!_isDeliveryChoiceEnabled) return true;
    
    double requiredLimit = 0;
    if (_selectedDeliveryType == 'delivery' && _deliveryLimit > 0) {
      requiredLimit = _deliveryLimit;
    } else if (_selectedDeliveryType == 'pickup' && _pickupLimit > 0) {
      requiredLimit = _pickupLimit;
    }
    
    return _cartTotal >= requiredLimit;
  }

  // Minimum limit kontrolü
  bool _isMinimumLimitMetCheckOut() {
    if (!_isDeliveryChoiceEnabledCheckOut)
      return true;

    double requiredLimit = 0;
    if (_selectedDeliveryType == 'delivery' && _deliveryLimit > 0) {
      requiredLimit = _deliveryLimit;
    } else if (_selectedDeliveryType == 'pickup' && _pickupLimit > 0) {
      requiredLimit = _pickupLimit;
    }

    return _cartTotal >= requiredLimit;
  }

  // Minimum limit mesajı
  String _getMinimumLimitMessage() {
    if (!_isDeliveryChoiceEnabled) return '';
    
    double requiredLimit = 0;
    String deliveryTypeText = '';
    
    if (_selectedDeliveryType == 'delivery' && _deliveryLimit > 0) {
      requiredLimit = _deliveryLimit;
      deliveryTypeText = Strings.deliveryToAddress;
    } else if (_selectedDeliveryType == 'pickup' && _pickupLimit > 0) {
      requiredLimit = _pickupLimit;
      deliveryTypeText = Strings.pickupFromStore;
    }
    
    if (requiredLimit > 0 && _cartTotal < requiredLimit) {
      double remaining = requiredLimit - _cartTotal;
      return '${Strings.minimumOrderWarning} $deliveryTypeText: ${requiredLimit.toStringAsFixed(2)} $_currency (${Strings.remaining}: ${remaining.toStringAsFixed(2)} $_currency)';
    }
    
    return '';
  }

  void _loadCart() {
    debugPrint('🛒 _loadCart çağrıldı');
    debugPrint('🛒 SessionId: ${SessionManager().sessionId}');
    debugPrint('🛒 CartId: ${SessionManager().cartId}');
    debugPrint('🛒 SelectedDeliveryType: ${SessionManager().selectedDeliveryType}');
    debugPrint('🛒 SelectedWarehouseId: ${SessionManager().selectedWarehouseId}');
    
    setState(() {
      _cartFuture = _cartService.fetchCart(
        sessionId: SessionManager().sessionId ?? '',
        cartId: SessionManager().cartId ?? 0,
        completedCart: false,
      );
      _cartId = SessionManager().cartId ?? 0;
    });
  }

  double _calculateItemsTotal(List<CartProductModel> cartProducts) {
    return cartProducts.fold(0.0, (sum, item) {
      final price = item.price ?? 0.0;
      final quantity = item.boxQuantity ?? item.pieceQuantity ?? 0.0;
      return sum + (price * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CartResponseModel?>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cart = snapshot.data;

          if (cart == null || cart.cartProducts.isEmpty) {
            return _buildEmptyCart();
          }

          return _buildCartWithItems(cart);
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            Strings.cartEmpty,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          Text(
            '(' +_cartId.toString()+')',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
         /* const SizedBox(height: 10),
          const Text(
            'You will get a response within a few minutes.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),*/
        ],
      ),
    );
  }

  Widget _buildCartWithItems(CartResponseModel cart) {
    final itemsTotal = _calculateItemsTotal(cart.cartProducts);
    final discount = cart.discountAmount ?? 0.0;
    final total = itemsTotal - discount;
    _deliveryLimit = cart.deliveryLimit;
    _pickupLimit = cart.pickupLimit;
    _cartTotal = total;
    _pickupList = cart.pickupList;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.cartProducts.length,
            itemBuilder: (context, index) {
              final product = cart.cartProducts[index];
              return _buildCartItem(product);
            },
          ),
        ),
        _buildOrderSummary(itemsTotal, discount, total),
      ],
    );
  }

  Widget _buildCartItem(CartProductModel product) {
    return GestureDetector(
      onTap: () {
        // Ürün detay modalını açmak için bir fonksiyon çağrılacak.
        // Bu fonksiyon, bu widget'ın bulunduğu sınıf içinde tanımlanmalıdır.
        _showProductDetailModal(product);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${product.boxQuantity.toInt() ?? 0} * ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_currency${product.price?.toStringAsFixed(2) ?? "0.00"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                   /* Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 30.0,
                          onPressed: () {
                            if ((product.boxQuantity ?? 0) > 1) {
                              _updateItemQuantity(product.id!, (product.boxQuantity ?? 0) - 1);
                            }
                          },
                        ),
                        Text(
                          '${product.boxQuantity ?? 0}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 30.0,
                          onPressed: () {
                            _updateItemQuantity(product.id!, (product.boxQuantity ?? 0) + 1);
                          },
                        ),
                      ],
                    ),*/
                    Text(
                      '${Strings.totalLabel}: $_currency${((product.price ?? 0) * (product.boxQuantity ?? 0)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeItem(product.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double itemsTotal, double discount, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.subtotal,
                style: TextStyle(fontSize: 16),
              ),

              Text(
                '$_currency${itemsTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.discount,
                  style: TextStyle(fontSize: 16),
                ),

                Text(
                  '-$_currency${discount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.total,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              Text(
                '$_currency${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Minimum limit uyarısı göster
          if (!_isMinimumLimitMet() && _getMinimumLimitMessage().isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMinimumLimitMessage(),
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _isMinimumLimitMet() ? Colors.orange : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            //  onPressed: _isLoading ? null : _checkout,
              onPressed: (_isLoading || !_isMinimumLimitMet()) ? null : (_isDeliveryChoiceEnabledCheckOut ? _showDeliveryTypeModal : _checkout),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                //'${Strings.checkout} ($_cartId)',
                '${Strings.checkout}',
                style: TextStyle(fontSize: 18),
              ),

            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout() async {
    setState(() => _isLoading = true);
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => B2bCheckoutPage(
            deliveryType: _selectedDeliveryType ?? '',
            pickupId: _selectedPickupId, // null olabilir, delivery için
          ),
        ),
      );
    } catch (e) {
      showCustomErrorToast(context, '${Strings.generalError}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeItem(int productId) async {
    setState(() => _isLoading = true);
    try {
      final success = await _cartService.deleteProduct(
        sessionId: SessionManager().sessionId ?? '',
        cartId: SessionManager().cartId ?? 0,
        cartProductId: productId,
      );

      if (success) {
        await Provider.of<CartState>(context, listen: false).fetchCartCounts();
        showCustomToast(context, Strings.productRemovedFromCart);

        _loadCart();
      }
    } catch (e) {
      showCustomErrorToast(context, '${Strings.generalError}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDeliveryTypeModal() async {
    _selectedDeliveryType = null;
    _selectedPickupId = null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool canPickup = _pickupLimit == 0 || _cartTotal >= _pickupLimit;
            bool canDelivery = _deliveryLimit == 0 || _cartTotal >= _deliveryLimit;

            bool isConfirmEnabled = false;

            if (_selectedDeliveryType == 'delivery') {
              isConfirmEnabled = true;
            } else if (_selectedDeliveryType == 'pickup') {
              if (_pickupList.isEmpty) {
                isConfirmEnabled = true;
              } else if (_selectedPickupId != null) {
                isConfirmEnabled = true;
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(Strings.chooseDeliveryType),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Expanded(child: Text(Strings.pickup)),
                        if (!canPickup)
                          Text('  Min: $_currency${_pickupLimit.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                    value: 'pickup',
                    groupValue: _selectedDeliveryType,
                    onChanged: canPickup
                        ? (value) async {
                      setState(() {
                        _selectedDeliveryType = value!;
                      });

                      if (_pickupList.isNotEmpty) {
                        await _showPickupAddressModal(setState);
                      }
                    }
                        : null,
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Expanded(child: Text(Strings.delivery)),
                        if (!canDelivery)
                          Text('  Min: $_currency${_deliveryLimit.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                    value: 'delivery',
                    groupValue: _selectedDeliveryType,
                    onChanged: canDelivery
                        ? (value) {
                      setState(() {
                        _selectedDeliveryType = value!;
                        _selectedPickupId = null;
                      });
                    }
                        : null,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(Strings.cancel),
                ),
                ElevatedButton(
                  onPressed: isConfirmEnabled
                      ? () {
                    Navigator.of(context).pop();
                    _checkout();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(Strings.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPickupAddressModal(void Function(void Function()) updateParent) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(Strings.choosePickupAddress),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _pickupList.map((pickup) {
                  return RadioListTile<int>(
                   // title: Text('${Strings.address}: ${pickup.address}'),
                    title: Text('${pickup.address}'),
                    value: pickup.id,
                    groupValue: _selectedPickupId,
                    onChanged: (value) {
                      setState(() => _selectedPickupId = value);
                      updateParent(() {}); // parent modal'ı güncelle (buton aktifliği)
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(Strings.cancel),
                ),
                ElevatedButton(
                  onPressed: _selectedPickupId == null
                      ? null
                      : () {
                    Navigator.of(context).pop(); // sadece adres modalı kapanır
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(Strings.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateItemQuantity(int productId, double newQuantity) async {
    setState(() => _isLoading = true);
    try {
      final response = await _cartService.updateProduct(
        sessionId: SessionManager().sessionId ?? '',
        cartId: SessionManager().cartId ?? 0,
        cartProductId: productId,
        boxQuantity: double.parse(newQuantity.toString()),
        pieceQuantity: 0
      );

      if (response) {
        _loadCart();
      } else {
        showCustomErrorToast(context, Strings.generalError);
      }
    } catch (e) {
      showCustomErrorToast(context, '${Strings.generalError}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProductDetailModal(CartProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ProductDetailModal(
          product: product,
          onUpdate: (productId, newQuantity) {
            // Modal'daki "Güncelle" butonuna basıldığında tetiklenir.
            _updateItemQuantity(productId, newQuantity.toDouble());
            Navigator.of(context).pop(); // Modalı kapat
          },
        );
      },
    );
  }

}