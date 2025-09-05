import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:odoosaleapp/services/CartService.dart';
import 'package:odoosaleapp/services/ProductCacheService.dart';
import 'package:odoosaleapp/services/ProductService.dart';
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/models/product/ProductsResponseModel.dart';
import 'package:odoosaleapp/shared/CartState.dart';
import 'package:odoosaleapp/shared/ProductCart.dart';
import 'package:provider/provider.dart';

import 'B2bCategoriesPage.dart';
import 'B2bCategoryDetailPage.dart';
import 'B2bProductDetailPage.dart';
import 'B2bShoppingCartPage.dart';
import 'helpers/FlushBar.dart';
import 'helpers/Strings.dart';
import 'models/cart/CartReponseModel.dart';
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
  late Future<void> _dataFuture; // FutureBuilder için tek bir Future
  late Future<List<ProductsResponseModel>> _productsFuture;
  late Future<List<CategoryResponseModel>> _categoriesFuture;
  late Future<List<CarouselResponseModel>> _carouselFuture;
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  TextEditingController _searchController = TextEditingController();
  List<ProductsResponseModel> _allProducts = [];
  List<ProductsResponseModel> _filteredProducts = [];
  List<CartCountResponseModel> _cartCounts = [];

  final _scrollController = ScrollController();
  final _searchFocusNode = FocusNode();
  final _textFieldKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        // 🔼 Klavye açıldığında TextField görünür olsun
        Future.delayed(const Duration(milliseconds: 300), () {
          final ctx = _textFieldKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      } else {
        // 🔽 Klavye kapandığında sayfa başa dönsün
        _scrollController.animateTo(
          0, // en üst
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    _dataFuture = _loadInitialData(); // Tüm verileri tek bir Future'da yükle
    _searchController.addListener(_filterProducts);
    Provider.of<CartState>(context, listen: false).fetchCartCounts();
  }

  // Yeni Metot: Tüm başlangıç verilerini bir kerede yükler
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadProducts(),
      _loadCategories(),
      _loadCarousel(),
      _loadCartCounts(),
    ]);
    _startCarouselTimer();
  }

  Future<void> _loadCartCounts() async {
    try {
      final sessionId = SessionManager().sessionId ?? '';
      final cartId = SessionManager().cartId ?? 0;

      final result = await _cartService.fetchCartCount(
        sessionId: sessionId,
        cartId: cartId,
        completedCart: false,
      );

      if (mounted && result != null) {
        setState(() {
          _cartCounts = result;
        });
      }
    } catch (e) {
      debugPrint('Error loading cart counts: $e');
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.name?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  Future<void> _loadProducts() async {
    if (_cache.isProductsCacheValid && _cache.cachedProducts.isNotEmpty) {
      _allProducts = _cache.cachedProducts;
    } else {
      try {
        final sessionId = SessionManager().sessionId ?? "";
        final customerId = SessionManager().customerId ?? 0;
        _allProducts = await _productService.fetchProducts(
          sessionId: sessionId,
          searchKey: '',
          limit: 10,
          page: 1,
          catId: 0,
          customerId: customerId,
          priceListId: 1,
        );
        _cache.cacheProducts(_allProducts);
      } catch (e) {
        debugPrint('Error fetching products: $e');
        if (mounted) {
          showCustomErrorToast(context, '${Strings.errorFetchingProducts}: $e');
        }
        _allProducts = [];
      }
    }
    // İlk yüklemede tüm ürünleri filtreli listeye at
    _filteredProducts = List.from(_allProducts);
  }

  Future<void> _loadCategories() async {
    if (_cache.isCategoriesCacheValid && _cache.cachedCategories.isNotEmpty) {
      _categoriesFuture = Future.value(_cache.cachedCategories);
    } else {
      try {
        var result = await _cartService.fetchCategories(
          sessionId: SessionManager().sessionId ?? '',
        );
        _cache.cacheCategories(result);
        _categoriesFuture = Future.value(result);
      } catch (e) {
        debugPrint('Error fetching categories: $e');
        if (mounted) {
          showCustomErrorToast(context, '${Strings.genericError}: $e');
        }
        _categoriesFuture = Future.value([]);
      }
    }
  }

  Future<void> _loadCarousel() async {
    if (_cache.isCarouselCacheValid && _cache.cachedCarouselItems.isNotEmpty) {
      _carouselFuture = Future.value(_cache.cachedCarouselItems);
    } else {
      try {
        var result = await _cartService.fetchCarouselItems(
          sessionId: SessionManager().sessionId ?? '',
        );
        _cache.cacheCarousel(result);
        _carouselFuture = Future.value(result);
      } catch (e) {
        debugPrint('Error fetching carousel items: $e');
        _carouselFuture = Future.value([]);
      }
    }
  }

  void _startCarouselTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      _carouselFuture.then((carouselItems) {
        if (carouselItems.isNotEmpty) {
          final nextPage = (_currentCarouselIndex + 1) % carouselItems.length;
          _carouselController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        _startCarouselTimer();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 👈 önemli
      body: FutureBuilder<void>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('${Strings.genericError}: ${snapshot.error}'),
            );
          }

          return MediaQuery.removeViewInsets( // 👈 kilit çözüm
            removeBottom: true,
            context: context,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Carousel Section
                SliverToBoxAdapter(
                  child: _buildCarousel(),
                ),

                // Categories Section
                SliverToBoxAdapter(
                  child: _buildCategoriesSection(),
                ),

                // Search Box Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      key: _textFieldKey,
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: Strings.searchProductsHint,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),

                // Products Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      Strings.productsTitle,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Products Section
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  sliver: _filteredProducts.isEmpty
                      ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(Strings.noProductsAvailable),
                    ),
                  )
                      : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return ProductCard(
                          product: _filteredProducts[index],
                          cartCounts: _cartCounts,
                          onAddToCart: () {
                            _loadCartCounts();
                          },
                        );
                      },
                      childCount: _filteredProducts.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildCarousel() {
    return FutureBuilder<List<CarouselResponseModel>>(
      future: _carouselFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(height: 230, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink(); // Hata veya veri yoksa boş bir kutu döndür
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
                        if (item.is_product == true) {
                          final product = _allProducts.firstWhere(
                                (p) => p.id == item.id, // orElse ile hata almayı engeller
                          );
                          if (product.id != null) {
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
                                      fontSize: (item.subtitleSize ?? 16).toDouble(),
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
                    aspectRatio: 16 / 9,
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
                      color: _currentCarouselIndex == index ? Colors.blue : Colors.grey.withOpacity(0.4),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink(); // Hata veya veri yoksa boş bir kutu döndür
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
                            _buildCategoryImageWidget(category.image, context),
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

  // Resim oluşturma widget'ları
  Widget _buildImageWidget(String imageSource) {
    imageSource = (imageSource == null || imageSource.isEmpty) ? 'https://fastly.picsum.photos/id/799/400/200.jpg' : imageSource;
    final isBase64 = imageSource.startsWith('data:image') || (imageSource.length > 100 && !imageSource.contains('http'));

    if (isBase64) {
      try {
        return Image.memory(
          base64Decode(imageSource.split(',').last),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
        );
      } catch (e) {
        debugPrint('Base64 decode error: $e');
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
              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
      );
    }
  }

  Widget _buildCategoryImageWidget(String? imageSource, BuildContext context) {
    final effectiveImageSource = (imageSource == null || imageSource.isEmpty) ? 'https://fastly.picsum.photos/id/799/400/200.jpg' : imageSource;
    final isBase64 = effectiveImageSource.startsWith('data:image') || (effectiveImageSource.length > 100 && !effectiveImageSource.contains('http'));

    if (isBase64) {
      try {
        final cleanBase64 = effectiveImageSource.split(',').last;
        return CircleAvatar(
          radius: 30,
          backgroundImage: MemoryImage(
            base64Decode(cleanBase64),
          ),
        );
      } catch (e) {
        debugPrint('Base64 decode error: $e');
        return CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.error, color: Colors.red),
        );
      }
    } else {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            effectiveImageSource,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }
  }

}