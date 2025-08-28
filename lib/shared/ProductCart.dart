import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../B2bProductDetailPage.dart';
import '../helpers/FlushBar.dart';
import '../helpers/SessionManager.dart';
import '../helpers/Strings.dart';
import '../models/cart/CartReponseModel.dart';
import '../models/product/ProductsResponseModel.dart';
import '../services/CartService.dart';
import 'CartState.dart';

class ProductCard extends StatefulWidget {
  final ProductsResponseModel product;
  final CartService _cartService = CartService();
  final List<CartCountResponseModel> cartCounts; // Yeni: Sepet verileri
  final void Function() onAddToCart; // Yeni callback

  ProductCard({Key? key, required this.product, required this.cartCounts,required this.onAddToCart});

  @override
  _ProductCardState createState() => _ProductCardState();

}

class _ProductCardState extends State<ProductCard> {
  int quantity = 1; // Moved quantity to State class
  double _cartQuantity = 0; // Moved quantity to State class

  @override
  void initState() {
    _updateCartQuantity();
  }
  // Yeni Metot: Sepetteki ürün miktarını bulur
  void _updateCartQuantity() {
    final cartItem = widget.cartCounts.firstWhere(
          (item) => item.productId == widget.product.id,
      orElse: () => CartCountResponseModel(productId: -1, count: 0),
    );
    setState(() {
      _cartQuantity = cartItem.count;
    });
  }

  Future<void> _addToCart(int id, int qty) async {
    try {
    /*  final response = await widget._cartService.addToCart(
        sessionId: SessionManager().sessionId ?? '',
        cartId: SessionManager().cartId ?? 0,
        productId: id,
        pieceQty: 0,
        boxQty: qty,
      );*/

      //if (response)/**/
      if (true)
      {
        Provider.of<CartState>(context, listen: false).addToCart(
          widget.product.id,
          quantity,
        );
        setState(() {
          quantity = 1;
        });
       // widget.onAddToCart();
        showCustomToast(context, Strings.productAddedToCart);
        _updateCartQuantity();


      } else {
        showCustomErrorToast(context, Strings.failedToAddProduct);

      }
    } catch (e) {
      showCustomErrorToast(context, '${Strings.generalError}: ${e.toString()}');

    }
  }

  @override
  Widget build(BuildContext context) {
    // Sepette olup olmadığını kontrol et
    final cartState = Provider.of<CartState>(context);
    final cartCounts = cartState.cartCounts;
    final cartItem = cartCounts.firstWhere(
          (item) => item.productId == widget.product.id,
      orElse: () => CartCountResponseModel(productId: -1, count: 0),
    );
    _cartQuantity = cartItem.count;
    bool isInCart = _cartQuantity > 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => B2bProductDetailPage(product: widget.product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isInCart
              ? const BorderSide(color: Colors.green, width: 2.0)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Row(
                  children: [
                    Spacer(),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                        child: Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Placeholder(),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 3,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${widget.product.taxedPriceText}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Text(
                            'pcs- ${widget.product.unitPriceText}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        onPressed: () => _addToCart(widget.product.id, quantity),
                        child: Text(Strings.addCart),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 34),
                            onPressed: () {
                              setState(() {
                                if (quantity > 1) quantity--;
                              });
                            },
                          ),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_outlined, size: 34),
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isInCart)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$_cartQuantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


}