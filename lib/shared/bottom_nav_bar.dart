// fixed_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/Strings.dart';

import 'CartState.dart'; // Doğru yolu girin

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
   // final AppLocalizations strings = AppLocalizations.of(context)!;
    const unselectedColor = Colors.black;
    const selectedColor = Colors.blue;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: Strings.home,
        ),
        BottomNavigationBarItem(
          icon: Consumer<CartState>(
            builder: (context, cartState, child) {
             // final totalCartItems = cartState.cartCounts.fold<double>(0, (sum, item) => sum + item.count);
              //final _totalCartItems = int.parse(totalCartItems.toString());
              final totalCartItems = cartState.cartCounts.length;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (totalCartItems > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${totalCartItems.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          label: Strings.cart,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_bag),
          label: Strings.myOrders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt),
          label: Strings.myInvoice,
        ),
      ],
    );
  }
}