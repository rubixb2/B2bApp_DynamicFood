import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  SharedPreferences? _prefs; // Remove 'late' and make it nullable

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  // Setters
  Future<void> setSessionId(String sessionId) async {
    await _prefs?.setString('sessionId', sessionId);
  }
  Future<void> setUserName(String uname) async {
    await _prefs?.setString('userName', uname);
  }
  Future<void> setUserId(int userId) async {
    await _prefs?.setInt('userId', userId);
  }

  Future<void> setCartId(int cartId) async {
    await _prefs?.setInt('cartId', cartId);
  }
  Future<void> setRememberme(bool remember) async {
    await _prefs?.setBool('rememberme', remember);
  }

  Future<void> setCustomerId(int customerId) async {
    await _prefs?.setInt('customerId', customerId);
  }
  Future<void> setPriceListId(int priceListId) async {
    await _prefs?.setInt('priceListId', priceListId);
  }

  Future<void> setCustomerName(String customerName) async {
    await _prefs?.setString('customerName', customerName);
  }

  Future<void> setBaseUrl(String url) async {
    await _prefs?.setString('baseUrl', url);
  }
  Future<void> setdeleteAccountBtn(bool val) async {
    await _prefs?.setBool('deleteAccountBtn', val);
  }

  // Login settings verilerini temizle
  Future<void> clearLoginSettings() async {
    await _prefs?.remove('deleteAccountBtn');
    await _prefs?.remove('b2bChooseDeliveryType');
    await _prefs?.remove('b2bChooseDeliveryTypeCheckOut');
    await _prefs?.remove('b2bDeleteCartVal');
    await _prefs?.remove('b2bDeliveryLimit');
    await _prefs?.remove('b2bPickupLimit');
    await _prefs?.remove('b2bCurrency');
    await _prefs?.remove('b2bCustomerAddress');
    await _prefs?.remove('pickupList');
  }

  // Teslimat türü ve depo bilgileri için yeni metodlar
  Future<void> setB2bChooseDeliveryType(int value) async {
    await _prefs?.setInt('b2bChooseDeliveryType', value);
  }

  Future<void> setB2bChooseDeliveryTypeCheckOut(int value) async {
    await _prefs?.setInt('b2bChooseDeliveryTypeCheckOut', value);
  }

  Future<void> setB2bDeleteCartVal(int value) async {
    await _prefs?.setInt('b2bDeleteCartVal', value);
  }

  Future<void> setSelectedDeliveryType(String? deliveryType) async {
    if (deliveryType != null) {
      await _prefs?.setString('selectedDeliveryType', deliveryType);
    } else {
      await _prefs?.remove('selectedDeliveryType');
    }
  }

  Future<void> setSelectedWarehouseId(int? warehouseId) async {
    if (warehouseId != null) {
      await _prefs?.setInt('selectedWarehouseId', warehouseId);
    } else {
      await _prefs?.remove('selectedWarehouseId');
    }
  }

  Future<void> setPickupList(String pickupListJson) async {
    await _prefs?.setString('pickupList', pickupListJson);
  }

  Future<void> setB2bDeliveryLimit(double limit) async {
    await _prefs?.setDouble('b2bDeliveryLimit', limit);
  }

  Future<void> setB2bPickupLimit(double limit) async {
    await _prefs?.setDouble('b2bPickupLimit', limit);
  }

  Future<void> setB2bCurrency(String currency) async {
    await _prefs?.setString('b2bCurrency', currency);
  }

  Future<void> setB2bOrderRepeatButton(int value) async {
    await _prefs?.setInt('b2bOrderRepeatButton', value);
  }

  // Getters
  String? get sessionId => _prefs?.getString('sessionId');
  bool get rememberMe => _prefs?.getBool('rememberme') ?? false;
  String? get userName => _prefs?.getString('userName');
  String get baseUrl => _prefs?.getString('baseUrl') ?? "";
  int? get userId => _prefs?.getInt('userId');
  int? get cartId => _prefs?.getInt('cartId');
  int? get customerId => _prefs?.getInt('customerId');
  int? get priceListId => _prefs?.getInt('priceListId');
  bool? get deleteAccountBtn => _prefs?.getBool('deleteAccountBtn');
  String? get customerName => _prefs?.getString('customerName');
  
  // Teslimat türü ve depo bilgileri için getter'lar
  int get b2bChooseDeliveryType => _prefs?.getInt('b2bChooseDeliveryType') ?? 0;
  int get b2bChooseDeliveryTypeCheckOut => _prefs?.getInt('b2bChooseDeliveryTypeCheckOut') ?? 0;
  int get b2bDeleteCartVal => _prefs?.getInt('b2bDeleteCartVal') ?? 1;
  String? get selectedDeliveryType => _prefs?.getString('selectedDeliveryType');
  int? get selectedWarehouseId => _prefs?.getInt('selectedWarehouseId');
  String? get selectedWarehouseName => _prefs?.getString('selectedWarehouseName');
  String? get pickupListJson => _prefs?.getString('pickupList');
  double get b2bDeliveryLimit => _prefs?.getDouble('b2bDeliveryLimit') ?? 0.0;
  double get b2bPickupLimit => _prefs?.getDouble('b2bPickupLimit') ?? 0.0;
  String get b2bCurrency => _prefs?.getString('b2bCurrency') ?? '€';
  String get b2bCustomerAddress => _prefs?.getString('b2bCustomerAddress') ?? 'Müşteri Adresi Belirtilmemiş';
  int get b2bOrderRepeatButton => _prefs?.getInt('b2bOrderRepeatButton') ?? 1;

  // Setter'lar
  Future<void> setB2bCustomerAddress(String address) async {
    await _prefs?.setString('b2bCustomerAddress', address);
  }

  Future<void> setSelectedWarehouseName(String? name) async {
    if (name != null) {
      await _prefs?.setString('selectedWarehouseName', name);
    } else {
      await _prefs?.remove('selectedWarehouseName');
    }
  }

  // Clear all session data
  Future<void> clearSession() async {
    await _prefs?.clear();
  }
}
