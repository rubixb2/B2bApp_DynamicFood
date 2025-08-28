import 'package:flutter/material.dart';
import 'package:odoosaleapp/B2bOrderListScreen.dart';
import 'package:odoosaleapp/B2bProductPage.dart';
import 'package:odoosaleapp/B2bShoppingCartPage.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'B2bInvoicesPage.dart';
import 'account_page.dart';
import 'helpers/SessionManager.dart';
import 'shared/bottom_nav_bar.dart';
import 'shared/hamburger_menu.dart';
import 'shared/app_drawer.dart';

class B2bMainPage extends StatefulWidget {
  const B2bMainPage({Key? key}) : super(key: key);

  @override
  _B2bMainPageState createState() => _B2bMainPageState();

}

class _B2bMainPageState extends State<B2bMainPage> {
  int _currentIndex = 0;
  final CartService _cartService = CartService();
  double _totalCartItems = 0; // Sepet sayısını tutacak değişken
  final List<Widget> _pages = [
    const B2bProductPage(),
    const ShoppingCartPage(),
    const B2bOrderListScreen(),
    const B2bInvoicesPage(),
  ];




  @override
  void initState() {
    super.initState();
    // Initialize pages
  /*  _pages.addAll([
      const B2bProductPage(),
      ShoppingCartPage(key: UniqueKey()), // UniqueKey forces rebuild
     // const AccountPage(),
      const B2bOrderListScreen()
    ]);*/
  }

  // Sepet sayısını API'den çeken ve güncelleyen metot
  Future<void> _fetchCartCount() async {
    final sessionId = SessionManager().sessionId ?? '';
    final cartId = SessionManager().cartId ?? 0;
    final result = await _cartService.fetchCartCount(
      sessionId: sessionId,
      cartId: cartId,
      completedCart: false,
    );

    double count = 0;
    if (result != null) {
      count = result.fold<double>(0, (sum, item) => sum + item.count);
    }

    if (mounted) {
      setState(() {
        _totalCartItems = count;
      });
    }
  }
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Yeni: Navigasyon için callback fonksiyonu
  void _navigateToCart() {
    setState(() {
      _currentIndex = 1; // Sepet sayfasına git
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tan-Tan')),
      drawer: AppDrawer(onNavItemSelected: _onItemTapped),
      body: _pages[_currentIndex],
      bottomNavigationBar: FixedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}