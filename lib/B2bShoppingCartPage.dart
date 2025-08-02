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


  @override
  void initState() {
    super.initState();
    _loadCart();
  }

/*  Future<void> _checkCartLimitAndContinue() async {
    setState(() => _isLoading = true);

    try {
      final sessionId = SessionManager().sessionId ?? '';
      final result = await CartService().fetchCartLimit(
          sessionId: sessionId,
          cartId:  SessionManager().cartId ?? 0,
          deliveryType: _selectedDeliveryType,);

      if (result == "success") {
        _checkout(); // Başarılı ise devam et
      } else {
        showCustomErrorToast(context, result); // Gelen mesajı göster
      }
    } catch (e) {
      showCustomErrorToast(context, '${Strings.generalError}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }*/


  void _loadCart() {
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
    return Card(
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
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl ?? 'https://via.placeholder.com/80'),
                  fit: BoxFit.cover,
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
                  Text(
                    '€${product.price?.toStringAsFixed(2) ?? "0.00"} x ${product.boxQuantity ?? 0}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '€${((product.price ?? 0) * (product.boxQuantity ?? 0)).toStringAsFixed(2)}',
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
                '€${itemsTotal.toStringAsFixed(2)}',
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
                  '-€${discount.toStringAsFixed(2)}',
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
                '€${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            //  onPressed: _isLoading ? null : _checkout,
              onPressed: _isLoading ? null : _showDeliveryTypeModal,
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
                          Text('  Min: €${_pickupLimit.toStringAsFixed(2)}',
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
                          Text('  Min: €${_deliveryLimit.toStringAsFixed(2)}',
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




}