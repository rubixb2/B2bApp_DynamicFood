import 'package:flutter/material.dart';

import '../B2bProductDetailPage.dart';
import '../helpers/FlushBar.dart';
import '../helpers/SessionManager.dart';
import '../helpers/Strings.dart';
import '../models/product/ProductsResponseModel.dart';
import '../services/CartService.dart';

class ProductCard extends StatefulWidget {
  final ProductsResponseModel product;
  final CartService _cartService = CartService();

  ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 1; // Moved quantity to State class

  Future<void> _addToCart(int id, int qty) async {
    try {
      final response = await widget._cartService.addToCart(
        sessionId: SessionManager().sessionId ?? '',
        cartId: SessionManager().cartId ?? 0,
        productId: id,
        pieceQty: 0,
        boxQty: qty,
      );

      if (response) {
        showCustomToast(context, Strings.productAddedToCart);

      } else {
        showCustomErrorToast(context, Strings.failedToAddProduct);

      }
    } catch (e) {
      showCustomErrorToast(context, '${Strings.generalError}: ${e.toString()}');

    }
  }

  @override
  Widget build(BuildContext context) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Row(
                children: [
                  Spacer(),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Placeholder(),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.product.taxedPriceText,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(), // <-- Bu sayede butonlar alta sabitlenir
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
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
                          icon: Icon(Icons.remove, size: 20, color: Colors.orange),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) quantity--;
                            });
                          },
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            quantity.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 20),
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
        )

    );
  }
}