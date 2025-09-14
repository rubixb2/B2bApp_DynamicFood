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
import 'models/cart/PickupModel.dart';
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
  
  // Teslimat türü seçimi için değişkenler
  String? _selectedDeliveryType;
  int? _selectedWarehouseId;
  List<PickupModel> _pickupList = [];
  double _deliveryLimit = 0;
  double _pickupLimit = 0;
  bool _isDeliveryChoiceEnabled = false;
  bool _deleteProductCache = false;

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
    
    // Teslimat türü seçimi ayarlarını kontrol et
    _checkDeliveryChoiceSettings();
    
    _dataFuture = _loadInitialData(); // Tüm verileri tek bir Future'da yükle
    _searchController.addListener(_filterProducts);
    Provider.of<CartState>(context, listen: false).fetchCartCounts();
  }

  // Teslimat türü seçimi ayarlarını kontrol et
  void _checkDeliveryChoiceSettings() {
    _isDeliveryChoiceEnabled = SessionManager().b2bChooseDeliveryType == 1;
    print('🔍 B2bChooseDeliveryType: ${SessionManager().b2bChooseDeliveryType}');
    print('🔍 _isDeliveryChoiceEnabled: $_isDeliveryChoiceEnabled');
    
    if (_isDeliveryChoiceEnabled) {
      // Daha önce seçilmiş teslimat türü ve depo bilgilerini al (null olabilir)
      _selectedDeliveryType = SessionManager().selectedDeliveryType;
      _selectedWarehouseId = SessionManager().selectedWarehouseId;
      
      // Pickup listesini al
      _loadPickupList();
      
      // Debug: Mevcut değerleri kontrol et
      debugPrint('🔍 _selectedDeliveryType: $_selectedDeliveryType');
      debugPrint('🔍 _selectedWarehouseId: $_selectedWarehouseId');
      
      // Teslimat türü seçimi zorla - her uygulama açılışında
      /*_selectedDeliveryType = null;
      _selectedWarehouseId = null;*/
      
      // İlk kullanımda teslimat türü seçimi modalını göster
      if (_selectedDeliveryType == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDeliveryTypeModal();
        });
      }
    }
  }

  // Pickup listesini yükle
  void _loadPickupList() {
    try {
      final pickupListJson = SessionManager().pickupListJson;
      if (pickupListJson != null && pickupListJson.isNotEmpty) {
        final List<dynamic> pickupData = jsonDecode(pickupListJson);
        _pickupList = pickupData.map((item) => PickupModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Pickup list yüklenirken hata: $e');
      _pickupList = [];
    }
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
    // Teslimat türü seçimi aktifse ve seçim yapılmamışsa ürünleri yükleme
    if (_isDeliveryChoiceEnabled && _selectedDeliveryType == null) {
      _allProducts = [];
      _filteredProducts = [];
      return;
    }

    if ((_cache.isProductsCacheValid && _cache.cachedProducts.isNotEmpty ) && !_deleteProductCache) {
      _allProducts = _cache.cachedProducts;
    } else {
      try {

        final sessionId = SessionManager().sessionId ?? "";
        final customerId = SessionManager().customerId ?? 0;
        
        // Teslimat türüne göre warehouseId belirle
        int warehouseId = 0;
        if (_isDeliveryChoiceEnabled) {
          if (_selectedDeliveryType == 'pickup' && _selectedWarehouseId != null) {
            warehouseId = _selectedWarehouseId!;
          } else if (_selectedDeliveryType == 'delivery') {
            warehouseId = 0;
          }
        }
        
        _allProducts = await _productService.fetchProducts(
          sessionId: sessionId,
          searchKey: '',
          limit: 10,
          page: 1,
          catId: 0,
          customerId: customerId,
          priceListId: 1,
          warehouseId: warehouseId, // Warehouse ID'yi ekle
        );
        _deleteProductCache = false;
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
      appBar: _isDeliveryChoiceEnabled ? _buildAppBar() : null,
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

          // Teslimat türü seçimi aktifse ve seçim yapılmamışsa uyarı göster
          if (_isDeliveryChoiceEnabled && _selectedDeliveryType == null) {
            return _buildDeliverySelectionRequired();
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

  // AppBar oluştur
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(Strings.productsTitle),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      actions: [
        IconButton(
          icon: Icon(
            _selectedDeliveryType == 'delivery' 
                ? Icons.local_shipping 
                : _selectedDeliveryType == 'pickup' 
                    ? Icons.store 
                    : Icons.settings,
            color: _selectedDeliveryType != null ? Colors.orange : Colors.grey,
          ),
          onPressed: () => _showDeliveryTypeModal(),
          tooltip: _selectedDeliveryType == null 
              ? Strings.selectDeliveryTypeTooltip 
              : _selectedDeliveryType == 'delivery' 
                  ? Strings.deliveryToAddressTooltip 
                  : Strings.pickupFromStoreTooltip,
        ),
      ],
    );
  }

  // Teslimat seçimi gerekli uyarısı
  Widget _buildDeliverySelectionRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              Strings.deliveryTypeSelectionRequired,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              Strings.selectDeliveryTypeFirst,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _showDeliveryTypeModal(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                Strings.selectDeliveryType,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Teslimat türü seçimi modalı
  Future<void> _showDeliveryTypeModal() async {
    String? tempSelectedDeliveryType = _selectedDeliveryType; // Mevcut seçimi göster
    int? tempSelectedWarehouseId = _selectedWarehouseId; // Mevcut depo seçimini göster
    
    // Debug: Modal açılırken değerleri kontrol et
    debugPrint('🔍 Modal açılıyor - tempSelectedDeliveryType: $tempSelectedDeliveryType');
    debugPrint('🔍 Modal açılıyor - tempSelectedWarehouseId: $tempSelectedWarehouseId');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool canPickup = _pickupLimit == 0 || true; // Şimdilik limit kontrolü yapmıyoruz
            bool canDelivery = _deliveryLimit == 0 || true;

            bool isConfirmEnabled = tempSelectedDeliveryType != null;

            if (tempSelectedDeliveryType == 'pickup' && _pickupList.isNotEmpty) {
              isConfirmEnabled = tempSelectedWarehouseId != null;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(Strings.chooseDeliveryTypeTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Strings.deliveryToAddress),
                        if (SessionManager().b2bDeliveryLimit > 0)
                          Text(
                            '${Strings.minimumOrderWarning}: ${SessionManager().b2bDeliveryLimit.toStringAsFixed(2)} ${SessionManager().b2bCurrency}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    value: 'delivery',
                    groupValue: tempSelectedDeliveryType,
                    onChanged: canDelivery
                        ? (value) {
                            setState(() {
                              tempSelectedDeliveryType = value!;
                              // Adrese teslim seçilince depo seçimini sıfırla
                              tempSelectedWarehouseId = null;
                            });
                          }
                        : null,
                  ),
                  RadioListTile<String>(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Strings.pickupFromStore),
                        if (SessionManager().b2bPickupLimit > 0)
                          Text(
                            '${Strings.minimumOrderWarning}: ${SessionManager().b2bPickupLimit.toStringAsFixed(2)} ${SessionManager().b2bCurrency}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    value: 'pickup',
                    groupValue: tempSelectedDeliveryType,
                    onChanged: canPickup
                        ? (value) async {
                            setState(() {
                              tempSelectedDeliveryType = value!;
                            });

                            if (_pickupList.isNotEmpty) {
                              await _showPickupAddressModal(setState, (selectedWarehouseId) {
                                tempSelectedWarehouseId = selectedWarehouseId;
                              });
                            }
                          }
                        : null,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: Text(Strings.cancel),
                ),
                ElevatedButton(
                  onPressed: isConfirmEnabled
                      ? () async {
                          // Modalı kapat
                          if (mounted) Navigator.of(context).pop();

                          _deleteProductCache = true;
                          // Sepet silme koşullarını kontrol et
                          bool shouldClearCart = false;
                          
                          // B2bDeleteCartVal ayarını kontrol et (1 ise sepet silme aktif, 0 ise pasif)
                          if (SessionManager().b2bDeleteCartVal == 1) {
                            if (_selectedDeliveryType != null && _selectedDeliveryType != tempSelectedDeliveryType) {
                              // 1. Adrese teslimden gel al'a geçiş - sepet silinir
                              if (_selectedDeliveryType == 'delivery' && tempSelectedDeliveryType == 'pickup') {
                                shouldClearCart = true;
                              }
                            }
                            
                            // 2. Mevcut depo değişikliği - sepet silinir
                            if (_selectedDeliveryType == 'pickup' && tempSelectedDeliveryType == 'pickup' &&
                                _selectedWarehouseId != null && _selectedWarehouseId != tempSelectedWarehouseId) {
                              shouldClearCart = true;
                            }
                          }

                          // Sepeti temizle (gerekirse)
                          if (shouldClearCart) {
                            await _clearCart();
                            await _loadCart(); // Sepet durumunu güncelle
                          }

                          // Seçimleri kaydet - sadece seçim yapıldıysa
                          if (tempSelectedDeliveryType != null) {
                            _selectedDeliveryType = tempSelectedDeliveryType;
                            // Adrese teslim seçilirse depo seçimini sıfırla
                            if (tempSelectedDeliveryType == 'delivery') {
                              _selectedWarehouseId = null;
                            } else {
                              _selectedWarehouseId = tempSelectedWarehouseId;
                            }
                          }

                          // Session'a kaydet
                          await SessionManager().setSelectedDeliveryType(_selectedDeliveryType);
                          await SessionManager().setSelectedWarehouseId(_selectedWarehouseId);
                          
                          // Seçili depo adını da kaydet
                          if (_selectedDeliveryType == 'pickup' && _selectedWarehouseId != null) {
                            final selectedWarehouse = _pickupList.firstWhere(
                              (warehouse) => warehouse.id == _selectedWarehouseId,
                              orElse: () => PickupModel(id: 0, name: null, address: ''),
                            );
                            await SessionManager().setSelectedWarehouseName(selectedWarehouse.name ?? selectedWarehouse.address);
                          } else {
                            await SessionManager().setSelectedWarehouseName(null);
                          }
                          
                          // Ürünleri yeniden yükle
                          if (mounted) {
                            _reloadProducts();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(Strings.confirm, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Depo seçimi modalı
  Future<void> _showPickupAddressModal(
      void Function(void Function()) updateParent,
      Function(int?) onWarehouseSelected) async {
    int? tempWarehouseId = _selectedWarehouseId; // Mevcut seçimi başlangıç değeri olarak al
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(Strings.selectStore),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _pickupList.map((pickup) {
                  return RadioListTile<int>(
                    title: Text('${pickup.name ?? pickup.address}'),
                    value: pickup.id,
                    groupValue: tempWarehouseId, // Temp değeri kullan
                    onChanged: (value) {
                      setState(() => tempWarehouseId = value);
                      onWarehouseSelected(value);
                      updateParent(() {}); // parent modal'ı güncelle
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(Strings.cancel),
                ),
                ElevatedButton(
                  onPressed: tempWarehouseId == null
                      ? null
                      : () {
                    Navigator.of(context).pop(); // sadece adres modalı kapanır
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(Strings.confirm, style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Sepet temizleme uyarısı
  Future<bool> _showCartClearWarning() async {
    if (!mounted) return false;
    
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(Strings.warning),
          content: Text(Strings.cartWillBeCleared),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (mounted) Navigator.of(context).pop(false);
                    },
                    child: Text(Strings.cancel),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Sepeti temizle
                      await _clearCart();
                      if (mounted) Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(Strings.clearCartAndContinue, style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // Sepeti temizle
  Future<void> _clearCart() async {
    try {
      final sessionId = SessionManager().sessionId ?? '';
      final cartId = SessionManager().cartId ?? 0;
      
      await _cartService.deleteCart(
        sessionId: sessionId,
        cartId: cartId,
      );
      
      // Cart state'i güncelle
      await Provider.of<CartState>(context, listen: false).fetchCartCounts();
      
      if (mounted) {
        showCustomToast(context, Strings.cartCleared);
      }
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      if (mounted) {
        showCustomErrorToast(context, '${Strings.generalError}: $e');
      }
    }

  }

  // Sepet durumunu yükle
  Future<void> _loadCart() async {
    try {
      await _cartService.createCart(sessionId: SessionManager().sessionId ?? "", customerId: SessionManager().customerId ?? 0);
      await Provider.of<CartState>(context, listen: false).fetchCartCounts();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // Ürünleri yeniden yükle
  void _reloadProducts() {
    setState(() {
      _dataFuture = _loadInitialData();
    });
  }
}