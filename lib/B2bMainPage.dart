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
    // 🔑 Global Key'i burada atıyoruz
    B2bProductPage(key: productPageKey),
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

  List<Widget> _buildAppBarActions() {
    final List<Widget> actions = [];

    // Sadece Ürün Sayfası aktifken (index 0) barkod butonunu ekle
    if (_currentIndex == 0) {
      actions.add(
        IconButton(
          icon: const Icon(
            Icons.qr_code_scanner,
            color: Colors.black, // AppBar rengine göre ayarlayın
          ),
          onPressed: _onBarcodeButtonPressed, // Bu metot zaten _B2bMainPageState'de tanımlı
          tooltip: 'Barkod Tara',
        ),
      );
    }

    // Buraya diğer sabit butonları da (varsa) ekleyebilirsiniz.
    // actions.add(const SomeOtherFixedButton());

    return actions;
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

  // Yeni: AppBar'daki butona tıklandığında çalışacak metot
  void _onBarcodeButtonPressed() {
    // Sadece Ürün Sayfasındayken (index 0) tarama yapmasını kontrol edebiliriz,
    // ama butonu her sayfada gösterdiğimiz için butona tıklanınca her zaman tarama yapmalıyız.

    // 1. Ürün sayfasının (State'inin) hazır olup olmadığını kontrol et.
    final productPageState = productPageKey.currentState;

    if (productPageState != null) {
      // 2. B2bProductPage'in içindeki tarama fonksiyonunu çağır.
      productPageState.startBarcodeScanFromOutside();
    } else {
      // Eğer ProductPage (index 0) şu an ekranda değilse ve State henüz oluşturulmadıysa
      // (ki bu genelde ilk açılışta veya sayfa yeniden oluşturulduğunda olur)
      // Kullanıcıyı uyarmak en iyisidir.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ürün listesi yüklenirken lütfen bekleyin veya Ürünler sekmesine geçin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Food'),

        // 🎯 ACTIONS LİSTESİNİ KOŞULLU METOTLA OLUŞTURUYORUZ
        actions: _buildAppBarActions(),
      ),
      drawer: AppDrawer(onNavItemSelected: _onItemTapped),
      body: _pages[_currentIndex],
      bottomNavigationBar: FixedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}