import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/helpers/FlushBar.dart';
import 'package:odoosaleapp/services/UserService.dart';

import 'B2bSignUpPage.dart';
import 'helpers/SessionManager.dart';
import 'B2bMainPage.dart';
import 'helpers/Strings.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}





class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _rememberMe = false;
  bool isLoading = false;
  bool guestLogin = false;
  bool forgetPass = false;
  bool deleteAccountt = false;
  String guestUser = "";
  String guestPass = "";
  bool signUp = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loginSettings();
  }



  void handleLogin(BuildContext context, bool guest) async {
    String username = "";
    String password = "";
    // Ensure baseUrl is set before any API calls
    SessionManager().setBaseUrl('https://apiodootest.nametech.be:5010/Api/');

    if (!guest) {
      username = emailController.text;
      password = passwordController.text;
    } else {
      username = guestUser;
      password = guestPass;
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
      if (guest) {
        SessionManager().setRememberme(false);
      }


      await registerDeviceTokenToBackend();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const B2bMainPage()),
      );
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

  Future<void> loginSettings() async {
    setState(() {
      isLoading = true;
    });
    final apiService = UserService();
    final data = await apiService.getLoginSettins();
    if (data != null) {

      guestLogin = data['B2bGuestLoginBtn'] ?? true; // Default to false if null
      forgetPass = data['B2bForgetPassBtn'] ?? true; // Default to false if null
      signUp = data['B2bSignupBtn'] ?? true; // Default to false if null
      deleteAccountt = data['B2bDeleteAccountBtn'] ?? true;
      guestUser = data['B2bGuestUser'] ?? "";
      guestPass = data['B2bGuestPass'] ?? "";
      SessionManager().setdeleteAccountBtn(deleteAccountt);

      setState(() {
        isLoading = false;
      });

    } else
    {
      setState(() {
        isLoading = false;
      });
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/shopping_cart.png'), // Resmi "assets" klasörüne koyun
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Curved white container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Strings.welcomeBack, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    Strings.signInToYourAccount,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: Strings.emailAddressHint,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: Strings.passwordHint,
                      prefixIcon: const Icon(Icons.lock_outline),
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
                  const SizedBox(height: 12),

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
                      // Conditional Forgot Password Button
                      if (forgetPass) // Only show if forgetPass is true
                        TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password logic
                            print('Forgot Password clicked!');
                          },
                          child: Text(
                            Strings.forgotPassword,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

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
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Added color for visibility
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Space before other buttons

                  // Conditional Guest Login Button
                  if (guestLogin)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red), // Red border for guest login
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : () => handleLogin(context, true),
                        child: Text(
                          Strings.guestLoginButton,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
                    ),
                  if (guestLogin) const SizedBox(height: 16), // Space after guest login if shown

                  // Conditional Sign Up Button
                  if (signUp)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Strings.dontHaveAnAccount),
                        TextButton(
                          onPressed: () {
                            // Navigate to the new SignUpScreen
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            ).then((email) {
                              if (email != null && email is String) {
                                emailController.text = email;
                              }
                            });
                          },
                          child: Text(
                            Strings.signUpButton,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // Loading Indicator
          if (isLoading)
            const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}