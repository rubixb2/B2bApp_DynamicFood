/*
import 'package:shared_preferences/shared_preferences.dart';

class CartPreferences {

*/
/*  static Future<void> saveCartInfo(
     int cartId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cartId', cartId);
  }*//*

  static Future<int> getCartInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');
    if (cartId != null)
      {
        return cartId;
      }
    else
      {
        return 0;
      }

  }

  static Future<void> clearCartInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cartId', 0);
  }

  static Future<void> saveCustomerInfo(
      int? customerId,int? priceListId, String? customerName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customerId', customerId ?? 0);
    await prefs.setInt('priceListId', priceListId ?? 0);
    await prefs.setString('customerName', customerName ?? '');
  }

  static Future<int> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customerId');
    if (customerId != null)
    {
      return customerId;
    }
    else
    {
      return 0;
    }
  }
  static Future<int> getPriceListId() async {
    final prefs = await SharedPreferences.getInstance();
    final priceListId = prefs.getInt('priceListId');
    if (priceListId != null)
    {
      return priceListId;
    }
    else
    {
      return 0;
    }
  }

  static Future<String> getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    final customerName = prefs.getString('customerName');
    if (customerName != null)
    {
      return customerName;
    }
    else
    {
      return '';
    }

  }

  static Future<void> clearCustomerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customerId', 0);
    await prefs.setInt('priceListId', 0);
    await prefs.setString('customerName', '');
  }

}
*/
