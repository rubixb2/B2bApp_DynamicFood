import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';

import 'HomePage.dart';
import 'LoginPage.dart';
import 'SplashPage.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => const HomePage(),
        }
      /*debugShowCheckedModeBanner: false,
      home: LoginPage(),*/
    );
  }
}