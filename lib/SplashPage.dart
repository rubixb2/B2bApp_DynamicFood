import 'package:flutter/material.dart';
import 'package:odoosaleapp/services/UserService.dart';

import 'helpers/SessionManager.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void checkSession(BuildContext context) async {
    //final userInfo = await UserPreferences.getUserInfo();
    await SessionManager().init();
    final userInfo = SessionManager().sessionId;
    SessionManager().setBaseUrl('https://apiodootest.nametech.be/Api/');

    if (userInfo != null) {
      final userService = UserService();
      final isValidSession = await userService.validateSession(userInfo);

      if (isValidSession) {
        SessionManager().setSessionId(userInfo);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        SessionManager().clearSession();
        // await UserPreferences.clearUserInfo();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    checkSession(context);

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
