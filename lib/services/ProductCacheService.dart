import '../models/home/CarouselResponseModel.dart';
import '../models/product/CategoryResponseModel.dart';
import '../models/product/ProductsResponseModel.dart';

class ProductCacheService {
  static final ProductCacheService _instance = ProductCacheService._internal();

  factory ProductCacheService() {
    return _instance;
  }

  ProductCacheService._internal();

  List<ProductsResponseModel> cachedProducts = [];
  List<CategoryResponseModel> cachedCategories = [];
  List<CarouselResponseModel> cachedCarouselItems = [];

  DateTime? _productsCacheTime;
  DateTime? _categoriesCacheTime;
  DateTime? _carouselCacheTime;

  final Duration cacheDuration = Duration(hours: 3);

  bool get isProductsCacheValid {
    if (_productsCacheTime == null) return false;
    return DateTime.now().difference(_productsCacheTime!) < cacheDuration;
  }

  bool get isCategoriesCacheValid {
    if (_categoriesCacheTime == null) return false;
    return DateTime.now().difference(_categoriesCacheTime!) < cacheDuration;
  }

  bool get isCarouselCacheValid {
    if (_carouselCacheTime == null) return false;
    return DateTime.now().difference(_carouselCacheTime!) < cacheDuration;
  }

  void cacheProducts(List<ProductsResponseModel> products) {
    cachedProducts = products;
    _productsCacheTime = DateTime.now();
  }

  void cacheCategories(List<CategoryResponseModel> categories) {
    cachedCategories = categories;
    _categoriesCacheTime = DateTime.now();
  }

  void cacheCarousel(List<CarouselResponseModel> items) {
    cachedCarouselItems = items;
    _carouselCacheTime = DateTime.now();
  }

  void clearAll() {
    cachedProducts = [];
    cachedCategories = [];
    cachedCarouselItems = [];
    _productsCacheTime = null;
    _categoriesCacheTime = null;
    _carouselCacheTime = null;
  }
}
