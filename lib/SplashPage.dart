import 'dart:convert';

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

  bool guestLogin = false;
  bool forgetPass = false;
  bool deleteAccountt = false;
  String guestUser = "";
  String guestPass = "";
  bool signUp = false;
  int b2bChooseDeliveryType = 0;
  int b2bChooseDeliveryTypeCartPage = 0;
  @override
  void initState() {
    super.initState();
    setupFirebaseMessaging();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await loginSettings();
      await _checkSessionAndNavigate();
    } catch (e) {
      print('❌ Initialization error: $e');
      // Hata durumunda login sayfasına yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }



  Future<void> _checkSessionAndNavigate() async {
    try {
      print('🔄 Session kontrolü başlatılıyor...');
      
      // Initialize session manager
      await SessionManager().init();
      print('✅ SessionManager başlatıldı');

      // Set your base URL (consider moving this to SessionManager.init())
      SessionManager().setBaseUrl('https://apiodootest.nametech.be:5010/Api/');

      final sessionId = SessionManager().sessionId;
      final rememberMe = SessionManager().rememberMe;
      final customerId = SessionManager().customerId ?? 0;

      print('📋 Session bilgileri: sessionId=$sessionId, rememberMe=$rememberMe, customerId=$customerId');

      if (sessionId != null && rememberMe) {
        print('🔄 Session validation başlatılıyor...');
        final userService = UserService();
        final isValidSession = await userService.validateSession(sessionId, customerId);

        if (isValidSession && mounted) {
          print('✅ Valid session - MainPage\'e yönlendiriliyor');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const B2bMainPage()),
          );
        } else if (mounted) {
          print('❌ Invalid session - Login\'e yönlendiriliyor');
          await SessionManager().clearSession();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } else if (mounted) {
        print('ℹ️ Session yok veya rememberMe false - Login\'e yönlendiriliyor');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      print('❌ Session kontrolü hatası: $e');
      throw e;
    }
  }

  Future<void> loginSettings() async {
    try {
      print('🔄 Login settings başlatılıyor...');
      final apiService = UserService();
      final data = await apiService.getLoginSettins();

      await SessionManager().setSelectedWarehouseId(0);
      await SessionManager().setSelectedDeliveryType(null);
      await SessionManager().setSelectedWarehouseName("");
      await SessionManager().setB2bChooseDeliveryType(0);
      await SessionManager().setB2bChooseDeliveryTypeCheckOut(0);
      
      if (data != null) {
        print('✅ Login settings başarıyla alındı');
        
        // Önce mevcut login settings verilerini temizle
        await SessionManager().clearLoginSettings();
        
        guestLogin = data['B2bGuestLoginBtn'] ?? true;
        forgetPass = data['B2bForgetPassBtn'] ?? true;
        signUp = data['B2bSignupBtn'] ?? true;
        deleteAccountt = data['B2bDeleteAccountBtn'] ?? true;
        guestUser = data['B2bGuestUser'] ?? "";
        guestPass = data['B2bGuestPass'] ?? "";
        b2bChooseDeliveryType = data['B2bChooseDeliveryType'] ?? 0;
        b2bChooseDeliveryTypeCartPage = data['B2bChooseDeliveryTypeCheckOut'] ?? 0;
        int b2bDeleteCartVal = data['B2bDeleteCartVal'] ?? 0;
        
        await SessionManager().setdeleteAccountBtn(deleteAccountt);
        await SessionManager().setB2bChooseDeliveryType(b2bChooseDeliveryType);
        await SessionManager().setB2bChooseDeliveryTypeCheckOut(b2bChooseDeliveryTypeCartPage);
        await SessionManager().setB2bDeleteCartVal(b2bDeleteCartVal);



        // Yeni parametreleri kaydet
        double deliveryLimit = (data['B2bDeliveryLimit'] ?? 0.0).toDouble();
        double pickupLimit = (data['B2bPickupLimit'] ?? 0.0).toDouble();
        String currency = data['B2bCurrency'] ?? '€';
        String customerAddress = data['B2bCustomerAddress'] ?? 'Müşteri Adresi Belirtilmemiş';

        await SessionManager().setB2bDeliveryLimit(deliveryLimit);
        await SessionManager().setB2bPickupLimit(pickupLimit);
        await SessionManager().setB2bCurrency(currency);
        await SessionManager().setB2bCustomerAddress(customerAddress);

        // Pickup listesini de kaydet
        if (data['PickupList'] != null) {
          await SessionManager().setPickupList(jsonEncode(data['PickupList']));
        }
        
        print('✅ Tüm ayarlar kaydedildi');
      } else {
        print('❌ Login settings null döndü');
        throw Exception('Login settings alınamadı');
      }
    } catch (e) {
      print('❌ Login settings hatası: $e');
      throw e;
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