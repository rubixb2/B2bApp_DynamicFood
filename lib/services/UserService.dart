import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/helpers/SessionManager.dart';

class UserService {
  final String loginUrl = SessionManager().baseUrl+'Users/Login';
  final String logoutUrl = SessionManager().baseUrl+'Users/Logout';
  final String sessionCheckUrl = SessionManager().baseUrl+'Users/GetBySession';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Username': username,
        'Password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Control'] == 1) {
        return data['Data'];
      }
    }
    return null;
  }
  Future<Map<String, dynamic>?> logout(String sessionId) async {
    final response = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sessionId': sessionId
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

  Future<bool> validateSession(String sessionId) async {
    final response = await http.post(
      Uri.parse(sessionCheckUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'SessionId': sessionId,
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
}
