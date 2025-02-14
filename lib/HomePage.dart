import 'package:flutter/material.dart';
import 'package:odoosaleapp/CustomersPage.dart';
import 'package:odoosaleapp/services/UserService.dart';

import 'CartPage.dart';
import 'InvoicesPage.dart';
import 'OrdersPage.dart';
import 'ProductsPage.dart';
import 'helpers/SessionManager.dart';

// ANA SAYFA (BOTTOM NAVIGATION + HAMBURGER MENU)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _userId = SessionManager().userId != null ? SessionManager().userId!.toString() : "0";
  String _userName = SessionManager().userName != null ? SessionManager().userName!.toString() : "-";
  final List<Widget> _pages = [
    const ProductPage(),
    const CartPage(),
    const OrdersPage(),
    const InvoicesPage(),
    const CustomersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rubixb2'),
        backgroundColor: Colors.lightBlue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ÜST KISIM PROFİL BÖLÜMÜ
            UserAccountsDrawerHeader(
              accountName:  Text(_userId),
              accountEmail:  Text(_userName),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              decoration: const BoxDecoration(
                color: Colors.lightBlue,
              ),
            ),
            // MENÜ ÖĞELERİ
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Route'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                // Profil sayfasına yönlendirme yapılabilir
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                // Ayarlar sayfasına yönlendirme yapılabilir
                Navigator.pop(context);
              },
            ),
            const Divider(), // Çizgi ayırıcı
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () {
                handleLogout(context);
               // Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_open),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Customers',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  void handleLogout(BuildContext context) async {
    var sessionId = SessionManager().sessionId ?? '';
    final apiService = UserService();
    final data = await apiService.logout(sessionId);

    if (data != null) {
      SessionManager().setSessionId('');
      SessionManager().setUserName('');
      SessionManager().setUserId(0);

      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed! Please check your credentials.')),
      );
    }
  }
}
