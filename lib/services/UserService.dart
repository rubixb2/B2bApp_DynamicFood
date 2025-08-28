import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/helpers/SessionManager.dart';

class UserService {


  final String loginUrl = SessionManager().baseUrl+'B2bSale/Login';
  final int merchantId = 1001;
  final String logoutUrl = SessionManager().baseUrl+'B2bSale/Logout';
  final String deleteUserUrl = SessionManager().baseUrl+'B2bSale/deleteUser';
  final String sessionCheckUrl = SessionManager().baseUrl+'B2bSale/GetBySession';
  final String loginsettingsUrl = SessionManager().baseUrl+'B2bSale/GetLoginSettings';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Username': username,
        'Password': password,
        'MerchantId': merchantId
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Control'] == 1) {

        int cartId = 0;
        var jsonData = data['Data']['CartList'];
        if (jsonData is List && jsonData.isNotEmpty) {
          final firstElement = jsonData[0];
          cartId = firstElement;
        } else {
          print('CartList is empty or not a list');
        }
        SessionManager().setCartId(cartId);

        return data['Data'];
      }
    }
    return null;
  }
  Future<Map<String, dynamic>?> logout(String sessionId,int customerId) async {
    final response = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sessionId': sessionId,
        'customerId' : customerId
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Control'] == 1) {
        return data;
      }
    }
    return null;
  }
  Future<Map<String, dynamic>?> deleteUser(String sessionId,int customerId) async {
    final response = await http.post(
      Uri.parse(deleteUserUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sessionId': sessionId,
        'customerId' : customerId
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Control'] == 1) {
        return data;
      }
    }
    return null;
  }
  Future<bool> validateSession(String sessionId,int customerId) async {
    final response = await http.post(
      Uri.parse(sessionCheckUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'SessionId': sessionId,
        'CustomerId': customerId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Control'] == 1) {
        int cartId = 0;
        var jsonData = data['Data']['CartList'];
        if (jsonData is List && jsonData.isNotEmpty) {
          final firstElement = jsonData[0];
          cartId = firstElement;
        } else {
          print('CartList is empty or not a list');
        }
        // var userId = data['Data']['UserId'];
        SessionManager().setCartId(cartId);

        // await CartPreferences.saveCartInfo(cartId);
        return true;
      }
    }
    return false;
  }
  Future<Map<String, dynamic>?> getLoginSettins() async {
    final response = await http.post(
      Uri.parse(loginsettingsUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'MerchantId': merchantId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Control'] == 1) {
        int cartId = 0;
        var jsonData = data['Data'];

        return jsonData;
      }
    }
    return null;
  }
}
