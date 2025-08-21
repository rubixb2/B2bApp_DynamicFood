import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:odoosaleapp/services/CartService.dart';
import 'package:odoosaleapp/services/UserService.dart';

import 'B2bCategoryDetailPage.dart';
import 'B2bProductPage.dart';
import 'B2bShoppingCartPage.dart';
import 'helpers/FlushBar.dart';
import 'helpers/SessionManager.dart';
import 'helpers/Strings.dart';
import 'models/product/CategoryResponseModel.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CartService _cartService = CartService();
  late Future<List<CategoryResponseModel>> _categoriesFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<CategoryResponseModel>> _fetchCategories() async {
    try {
      return await _cartService.fetchCategories(
        sessionId: SessionManager().sessionId ?? '',
      );
    } catch (e) {
      debugPrint('Error: $e');
      showCustomErrorToast(context, '${Strings.generalError}: ${e}');
      // Return empty list or rethrow based on your needs
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.categoriesTitle),
      ),

      body: FutureBuilder<List<CategoryResponseModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${Strings.generalError}: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(Strings.noCategoriesFound),
            );

          }

          final categories = snapshot.data!;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading:
                /*CircleAvatar(
                  backgroundImage: NetworkImage(category.imageUrl),
                ),*/
                CircleAvatar(
                  radius: 30,
                  backgroundImage: MemoryImage(
                    base64Decode(category.image), // base64 string'in sadece veri kısmı olmalı
                  ),
                ),
                title: Text(category.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailPage(categoryId: category.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    //  bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

 /* Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
      onTap: (index) {
        setState(() => _currentIndex = index);
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
          );
        }
      },
    );
  }*/
}