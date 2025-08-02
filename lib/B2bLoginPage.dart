import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/helpers/FlushBar.dart';
import 'package:odoosaleapp/services/UserService.dart';

import 'helpers/SessionManager.dart';
import 'B2bMainPage.dart';
import 'helpers/Strings.dart';

/*
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
*/

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _rememberMe = false;
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  void handleLogin(BuildContext context, bool guest) async {
    String username = "";
    String password = "";
    SessionManager().setBaseUrl('https://apiodootest.nametech.be:5010/Api/');

    if (!guest) {
      username = emailController.text;
      password = passwordController.text;
    } else {
      username = "halil@test.be";
      password = "123";
    }
    setState(() {
      isLoading = true;
    });

    final apiService = UserService();
    final data = await apiService.login(username, password);

    setState(() {
      isLoading = false;
    });

    if (data != null) {
      SessionManager().setSessionId(data['SessionId']);
      SessionManager().setCustomerId(data['PartnerId']);
      SessionManager().setCustomerName(data['PartnerName']);
      SessionManager().setPriceListId(data['PriceListId']);
      SessionManager().setUserName(username);
      SessionManager().setUserId(data['UserId']);
      SessionManager().setRememberme(_rememberMe);

      await registerDeviceTokenToBackend();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const B2bMainPage()),
      );
      //Navigator.pushReplacementNamed(context, '/home');
      //Navigator.pushReplacementNamed(context, '/homeb2b');
    } else
    {
      setState(() {
        isLoading = false;
      });
      showCustomErrorToast(context, Strings.loginFailed);

    }
  }

  Future<void> registerDeviceTokenToBackend() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🔐 Firebase token al
    String? token = await messaging.getToken();
    print("📲 Login sonrası FCM Token: $token");

    if (token != null) {
      // Backend'e gönder (örnek)
      await sendTokenToBackend(token);
    }
  }

  Future<void> sendTokenToBackend(String token) async {
    // Kullanıcı ID, auth token vs. burada kullanılabilir
    final response = await http.post(
      Uri.parse(SessionManager().baseUrl+'B2bSale/SetFcmToken'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'sessionId': SessionManager().sessionId, // opsiyonel
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Token backend\'e başarıyla gönderildi.');
    } else {
      print('❌ Token gönderilemedi: ${response.body}');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/shopping_cart.jpg'), // Resmi "assets" klasörüne koyun
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Curved white container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Strings.welcomeBack, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                  Strings.signInToYourAccount,
                  style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 32),

                  // Email Field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: Strings.emailAddressHint,
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: Strings.passwordHint,
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Switch(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value;
                              });
                            },
                          ),
                          Text(Strings.rememberMe)

                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          Strings.forgotPassword,
                          style: TextStyle(color: Colors.blue),
                        ),),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : () => handleLogin(context, false),
                      child: Text(
                        Strings.loginButton,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
