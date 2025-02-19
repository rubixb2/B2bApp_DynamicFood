import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Singleton Instance
  static final SessionManager _instance = SessionManager._internal();

  // Private Constructor
  SessionManager._internal();

  // Factory Constructor to return the same instance
  factory SessionManager() {
    return _instance;
  }

  // SharedPreferences instance
  late SharedPreferences _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Setters
  Future<void> setSessionId(String sessionId) async {
    await _prefs.setString('sessionId', sessionId);
  }
  Future<void> setUserName(String uname) async {
    await _prefs.setString('userName', uname);
  }
  Future<void> setUserId(int userId) async {
    await _prefs.setInt('userId', userId);
  }

  Future<void> setCartId(int cartId) async {
    await _prefs.setInt('cartId', cartId);
  }

  Future<void> setCustomerId(int customerId) async {
    await _prefs.setInt('customerId', customerId);
  }
  Future<void> setPriceListId(int priceListId) async {
    await _prefs.setInt('priceListId', priceListId);
  }

  Future<void> setCustomerName(String customerName) async {
    await _prefs.setString('customerName', customerName);
  }

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString('baseUrl', url);
  }

  // Getters
  String? get sessionId => _prefs.getString('sessionId');
  String? get userName => _prefs.getString('userName');
  String get baseUrl => _prefs.getString('baseUrl') ?? "";
  int? get userId => _prefs.getInt('userId');
  int? get cartId => _prefs.getInt('cartId');
  int? get customerId => _prefs.getInt('customerId');
  int? get priceListId => _prefs.getInt('priceListId');
  String? get customerName => _prefs.getString('customerName');

  // Clear all session data
  Future<void> clearSession() async {
    await _prefs.clear();
  }
}
