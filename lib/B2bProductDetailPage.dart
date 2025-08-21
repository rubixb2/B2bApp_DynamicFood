import 'package:flutter/material.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'package:odoosaleapp/models/product/ProductsResponseModel.dart';

import 'helpers/FlushBar.dart';
import 'helpers/SessionManager.dart';
import 'helpers/Strings.dart';

class B2bProductDetailPage extends StatefulWidget {
  final ProductsResponseModel product;

  const B2bProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<B2bProductDetailPage> {
  int _quantity = 1;
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80), // Buton yüksekliği kadar alt boşluk
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ürün resmi
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      widget.product.imageUrl.isNotEmpty
                          ? widget.product.imageUrl
                          : 'https://via.placeholder.com/300',
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                  ),
                ),

                // Ürün bilgileri
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fiyat ve başlık
                      Text(
                        widget.product.taxedPriceText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Stok bilgisi
                      Text(
                        '${Strings.stock}: ${widget.product.stockCount} lbs',
                        style: TextStyle(
                          color: widget.product.stockCount > 0 ? Colors.grey : Colors.red,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Açıklama
                      Text( widget.product.description
                       ,
                        style: TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 10),

                      // Miktar seçici
                      Row(
                        children: [
                          Text(
                            Strings.quantity,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _quantity.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                          ),
                        ],
                      ),

                      // Ekstra boşluk (butonla çakışmayı önlemek için)
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sabit Add to Cart butonu
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await _addToCart();
                },
                child: Text(
                  Strings.addToCart,
                  style: TextStyle(fontSize: 18),
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart() async {
    try {
      final response = await _cartService.addToCart(
        sessionId: SessionManager().sessionId ?? '',
        cartId: SessionManager().cartId ?? 0,
        productId: widget.product.id,
        pieceQty: 0,
        boxQty: _quantity,
      );

      if (response) {

        showCustomToast(context, Strings.productAdded);

      } else {
        showCustomErrorToast(context, Strings.productAddingFailed);

      }
    } catch (e) {
      showCustomErrorToast(context, '${Strings.genericError}: $e');

    }
  }
}