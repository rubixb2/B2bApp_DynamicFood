import 'package:flutter/material.dart';

class HamburgerMenu extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HamburgerMenu({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => scaffoldKey.currentState?.openDrawer(),
    );
  }
}