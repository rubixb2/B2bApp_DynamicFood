import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:odoosaleapp/services/CartService.dart';
import 'package:odoosaleapp/services/ProductCacheService.dart';
import 'package:odoosaleapp/services/ProductService.dart';
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/models/product/ProductsResponseModel.dart';
import 'package:odoosaleapp/shared/ProductCart.dart';

import 'B2bCategoriesPage.dart';
import 'B2bCategoryDetailPage.dart';
import 'B2bProductDetailPage.dart';
import 'B2bShoppingCartPage.dart';
import 'helpers/FlushBar.dart';
import 'helpers/Strings.dart';
import 'models/home/CarouselResponseModel.dart';
import 'models/product/CategoryResponseModel.dart';

// Category Model
class Category {
  final int id;
  final String name;
  final String imageUrl;

  Category({required this.id, required this.name, required this.imageUrl});
}

// Main Product Page
class B2bProductPage extends StatefulWidget {
  const B2bProductPage({Key? key}) : super(key: key);

  @override
  _B2bProductPageState createState() => _B2bProductPageState();
}

class _B2bProductPageState extends State<B2bProductPage> {
  final ProductCacheService _cache = ProductCacheService();
  int _currentCarouselIndex = 0;
  final cs.CarouselSliderController _carouselController = cs.CarouselSliderController();
  late Future<List<ProductsResponseModel>> _productsFuture;
  late Future<List<CategoryResponseModel>> _categoriesFuture;
  late Future<List<CarouselResponseModel>> _carouselFuture;
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();

  List<ProductsResponseModel> _cachedProducts = []; // Önbellek eklendi

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
    _loadCarousel();
    _startCarouselTimer();
    /*_carouselFuture = _fetchCarouselItems();
    _loadProducts();
    _categoriesFuture = _fetchCategories();
    _startCarouselTimer();*/
  }

 /* Future<void> _loadProducts() async {
    _productsFuture = _fetchProducts();
    _productsFuture.then((products) {
      if (mounted) {
        setState(() {
          _cachedProducts = products;

        });
      }
    });
  }*/


  Future<List<ProductsResponseModel>> _fetchProducts({int categoryId = 0}) async {
    try {
      final sessionId = SessionManager().sessionId ?? "";
      final customerId = SessionManager().customerId ?? 0;
      var result = await _productService.fetchProducts(
        sessionId: sessionId,
        searchKey: '',
        limit: 10,
        page: 1,
        catId: categoryId,
        customerId: customerId,
        priceListId: 1,
      );
      _cache.cacheProducts(result);
      return result;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      showCustomErrorToast(context, '${Strings.errorFetchingProducts}: $e');
      return [];
    }
  }

  Future<List<CategoryResponseModel>> _fetchCategories() async {
    try {
      var result = await _cartService.fetchCategories(
        sessionId: SessionManager().sessionId ?? '',
      );
      _cache.cacheCategories(result);
      return result;
    } catch (e) {
      debugPrint('Error: $e');
      showCustomErrorToast(context, '${Strings.genericError}: $e');
      return [];
    }
  }

  Future<List<CarouselResponseModel>> _fetchCarouselItems() async {
    try {
      var result = await _cartService.fetchCarouselItems(
        sessionId: SessionManager().sessionId ?? '',
      );
      _cache.cacheCarousel(result);
      return  result;
    } catch (e) {
      debugPrint('Error fetching carousel items: $e');
      showCustomErrorToast(context, '${Strings.errorFetchingCarousel}: $e');
      // Fallback olarak default veri dönebilirsiniz
      return [];
    }
  }

  void _startCarouselTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return; // Widget hala mounted mı kontrolü

      _carouselFuture.then((carouselItems) {
        if (carouselItems.isNotEmpty) {
          final nextPage = (_currentCarouselIndex + 1) % carouselItems.length;
          _carouselController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        _startCarouselTimer(); // Timer'ı yeniden başlat
      });
    });
  }

  void _loadCarousel() {
    if (_cache.isCarouselCacheValid && _cache.cachedCarouselItems.isNotEmpty) {
      _carouselFuture = Future.value(_cache.cachedCarouselItems);
    } else {
      _carouselFuture = _fetchCarouselItems();
    }
  }

  void _loadProducts() {
    if (_cache.isProductsCacheValid && _cache.cachedProducts.isNotEmpty) {
      _productsFuture = Future.value(_cache.cachedProducts);

    } else {
      _productsFuture = _fetchProducts();
      _productsFuture.then((products) {
        if (mounted) {
          setState(() {
            _cache.cacheProducts(products);
          });
        }
      });
    }
  }


  void _loadCategories() {
    if (_cache.isCategoriesCacheValid && _cache.cachedCategories.isNotEmpty) {
      _categoriesFuture = Future.value(_cache.cachedCategories);
    } else {
      _categoriesFuture = _fetchCategories();
      _categoriesFuture.then((categories) {
        if (mounted) {
          setState(() {
            _cache.cacheCategories(categories);
          });
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: [
              // Carousel Section
              SliverToBoxAdapter(
                child: _buildCarousel(),
              ),

              // Categories Section
              SliverToBoxAdapter(
                child: _buildCategoriesSection(),
              ),
              SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Strings.productsTitle,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),

                      ],
                    ),
                  )
              ),

              // Products Section
              SliverPadding(
                padding: const EdgeInsets.only(bottom:0),
                sliver: FutureBuilder<List<ProductsResponseModel>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text('${Strings.genericError}: ${snapshot.error}'),
                        ),

                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(Strings.noProductsAvailable),
                        ),

                      );
                    }

                    final products = snapshot.data!;
                    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return ProductCard(product: products[index]);
                        },
                        childCount: products.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarousel() {
    return FutureBuilder<List<CarouselResponseModel>>(
      future: _carouselFuture,
      builder: (context, snapshot) {
        // Yükleniyor durumu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 230,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          );
        }

        // Hata durumu
        if (snapshot.hasError) {
          return SizedBox(
            height: 230,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 10),
                  Text(
                    Strings.carouselFailed,
                    style: TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _carouselFuture = _fetchCarouselItems();
                      });
                    },
                    child: Text(Strings.tryAgain),

                  ),
                ],
              ),
            ),
          );
        }

        // Veri yok durumu
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 230,
            child: Center(
                child: Text(
                  Strings.noCarouselContent,
                  style: TextStyle(color: Colors.grey),
                ),

            ),
          );
        }

        final carouselItems = snapshot.data!;

        return SizedBox(
          height: 230,
          child: Column(
            children: [
              Expanded(
                child: cs.CarouselSlider.builder(
                  itemCount: carouselItems.length,
                  carouselController: _carouselController,
                  itemBuilder: (context, index, realIndex) {
                    final item = carouselItems[index];
                    return GestureDetector(
                      onTap: () async {
                        if (item.is_product== true) {
                          // Ürün detayına git
                          final products = await _cache.cachedProducts;

                          final product = products.firstWhere(
                                (p) => p.id == item.id,
                            //orElse: () => null,
                          );

                          if (product != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => B2bProductDetailPage(
                                  product: product,
                                ),
                              ),
                            );
                          }
                        } else {
                          // Kategori detayına git
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(
                                categoryId: item.id,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildImageWidget(item.image),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      color: item.titleColor ?? Colors.white,
                                      fontSize: (item.titleSize ?? 24).toDouble(),
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Colors.black.withOpacity(0.5),
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(
                                      color: item.subtitleColor ?? Colors.white,
                                      fontSize: (item.subtitleSize?? 16).toDouble(),
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Colors.black.withOpacity(0.5),
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: cs.CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    aspectRatio: 16/9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(carouselItems.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentCarouselIndex == index
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.4),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<List<CategoryResponseModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox(height: 80, child: Center(child: Text('Error loading categories')));
        }

        final categories = snapshot.data!;

        return SizedBox(
          height: 140,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Strings.categoriesTitle,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoriesPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryDetailPage(categoryId: category.id),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(category.imageUrl),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(String imageSource) {
    // Base64 kontrolü (basit bir regex ile
    imageSource = imageSource == null || imageSource == "" ? 'https://fastly.picsum.photos/id/799/400/200.jpg' : imageSource;
    final isBase64 = imageSource.startsWith('data:image') ||
        (imageSource.length > 100 && !imageSource.contains('http'));

    if (isBase64) {
      try {
        return Image.memory(
          base64Decode(imageSource.split(',').last),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.grey[200]),
        );
      } catch (e) {
        debugPrint('Base64 decode error: $e');
        showCustomErrorToast(context, '${Strings.base64DecodeError}: $e');
        return Container(color: Colors.grey[200]);
      }
    } else {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
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
            Container(color: Colors.grey[200]),
      );
    }
  }



}