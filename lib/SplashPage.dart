import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:odoosaleapp/services/UserService.dart';
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/B2bMainPage.dart';
import 'package:odoosaleapp/B2bLoginPage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();



}

void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // iOS için izin iste
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ Bildirim izni verildi');
  } else {
    print('❌ Bildirim izni verilmedi');
  }
  // Token al
  String? token = await messaging.getToken();
  print("📱 Firebase Token: $token");

  // Foreground bildirim alma
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📬 Gelen mesaj: ${message.notification?.title}');
  });

  // Arka planda mesaj açıldığında
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📨 Bildirim tıklanarak açıldı: ${message.data}');
  });
}



class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    setupFirebaseMessaging();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Initialize session manager
    await SessionManager().init();

    // Set your base URL (consider moving this to SessionManager.init())
    SessionManager().setBaseUrl('https://apiodootest.nametech.be:5010/Api/');

    final sessionId = SessionManager().sessionId;
    final rememberMe = SessionManager().rememberMe;
    final customerId = SessionManager().customerId ?? 0;

    if (sessionId != null && rememberMe) {
      final userService = UserService();
      final isValidSession = await userService.validateSession(sessionId, customerId);

      if (isValidSession && mounted) {
        // Valid session - go to MainPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const B2bMainPage()),
        );
      } else if (mounted) {
        // Invalid session - clear and go to login
        await SessionManager().clearSession();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else if (mounted) {
      // No session or rememberMe false - go to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔽 LOGO BURADA
            Image(
              image: AssetImage("assets/splash/splashlogo.png"),
              width: 120,
              height: 120,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}