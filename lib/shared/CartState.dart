// cart_state.dart
import 'package:flutter/material.dart';
import '../helpers/SessionManager.dart';
import '../models/cart/CartReponseModel.dart';
import '../services/CartService.dart';

class CartState extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartCountResponseModel> _cartCounts = [];

  List<CartCountResponseModel> get cartCounts => _cartCounts;

  Future<void> fetchCartCounts() async {
    final sessionId = SessionManager().sessionId ?? '';
    final cartId = SessionManager().cartId ?? 0;

    _cartCounts = await _cartService.fetchCartCount(
      sessionId: sessionId,
      cartId: cartId,
      completedCart: false,
    ) ?? [];

    // Eğer liste boşsa örnek veri ekle (isteğe bağlı)


    notifyListeners(); // Dinleyen widget'ları uyar
  }

  Future<void> addToCart(int productId, int quantity) async {
    // Sepete ekleme API çağrısı
    final success = await _cartService.addToCart(
      productId: productId,
      sessionId: SessionManager().sessionId ?? '',
      cartId: SessionManager().cartId ?? 0,
      pieceQty: 0,
      boxQty: quantity,
    );
    if (success) {
      await fetchCartCounts(); // Başarılı olursa veriyi yenile
    }
  }
}