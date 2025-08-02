import 'package:flutter/material.dart';
import 'package:odoosaleapp/B2bOrderListScreen.dart';
import 'package:odoosaleapp/B2bProductPage.dart';
import 'package:odoosaleapp/B2bShoppingCartPage.dart';
import 'B2bInvoicesPage.dart';
import 'account_page.dart';
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
    _pages.addAll([
      const B2bProductPage(),
      ShoppingCartPage(key: UniqueKey()), // UniqueKey forces rebuild
     // const AccountPage(),
      const B2bOrderListScreen()
    ]);
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
      appBar: AppBar(title: const Text('RubixB2b')),
      drawer: AppDrawer(onNavItemSelected: _onItemTapped),
      body: _pages[_currentIndex],
      bottomNavigationBar: FixedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}