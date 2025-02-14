/*
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUserInfo(
      String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_SessionId', sessionId);
   */
/* await prefs.setInt('MerchantId', merchantId);
    await prefs.setInt('UserId', userId);*//*

  }

  static Future<String> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('_SessionId');

    if (sessionId != null) {
      return sessionId;
  }
    return '';
  }

*/
/*  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('SessionId');
    if (sessionId != null)
    {
      return sessionId;
    }
    else
    {
      return '';
    }

  }*//*


  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
*/
