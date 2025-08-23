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
                _buildCategoryImageWidget(category.image,context),

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

  Widget _buildCategoryImageWidget(String? imageSource, BuildContext context) {
    // imageSource null veya boşsa varsayılan resim kullanılır
    final effectiveImageSource = (imageSource == null || imageSource.isEmpty)
        ? 'https://fastly.picsum.photos/id/799/400/200.jpg'
        : imageSource;

    // Base64 kontrolü
    final isBase64 = effectiveImageSource.startsWith('data:image') ||
        (effectiveImageSource.length > 100 && !effectiveImageSource.contains('http'));

    if (isBase64) {
      try {
        // Base64 verisinin başındaki meta verileri (örneğin "data:image/jpeg;base64,") temizlemek gerekebilir.
        final cleanBase64 = effectiveImageSource.split(',').last;
        return CircleAvatar(
          radius: 30,
          backgroundImage: MemoryImage(
            base64Decode(cleanBase64),
          ),
        );
      } catch (e) {
        debugPrint('Base64 decode error: $e');
        // showCustomErrorToast(context, '${Strings.base64DecodeError}: $e');
        return CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.error, color: Colors.red),
        );
      }
    } else {
      // else bloğu: Network resmini bir CircleAvatar içinde gösterir
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            effectiveImageSource,
            fit: BoxFit.cover,
            width: 60,  // CircleAvatar'ın yarıçapının iki katı
            height: 60, // CircleAvatar'ın yarıçapının iki katı
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
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }
  }

}