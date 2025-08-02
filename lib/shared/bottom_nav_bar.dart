import 'package:flutter/material.dart';

class FixedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FixedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home,color: Colors.black),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart,color: Colors.black),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shop_two,color: Colors.black),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt,color: Colors.black),
          label: 'Invoices',
        ),
      ],
    );
  }
}