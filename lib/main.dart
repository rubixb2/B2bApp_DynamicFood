import 'package:flutter/material.dart';
import 'package:odoosaleapp/shared/CartState.dart';
import 'SplashPage.dart';
import 'helpers/LanguageManager.dart';
import 'helpers/SessionManager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Arka planda mesaj: ${message.messageId}');
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase başlat
  await SessionManager().init(); // Initialize first
  await LanguageManager().loadLanguage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //runApp(const MyApp());
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Food',
      debugShowCheckedModeBanner: false,
      theme: B2BTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}