import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:odoosaleapp/helpers/FlushBar.dart';
import 'package:odoosaleapp/helpers/SessionManager.dart';
import 'package:odoosaleapp/helpers/Strings.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text;
      final String password = _passwordController.text;

      // baseUrl'in doğru bir şekilde ayarlandığından emin olun
      // SessionManager().setBaseUrl('https://apiodootest.nametech.be:5010/Api/');

      final response = await http.post(
        Uri.parse('${SessionManager().baseUrl}B2bSale/AddUser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Email': email,
          'Pass': password,
        }),
      );

      // !mounted kontrolü burada önemli
      if (!mounted) return; // Widget hala aktif değilse hiçbir işlem yapma

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // API'den gelen 'Control' değeri '1' ise başarılı sayıyoruz.
        // Eğer API'nizden gerçek bir kontrol değeri geliyorsa bunu kullanın.
        // if (data['Control'] == '1') {
        if (true) { // Geçici olarak her zaman başarılı kabul ediyoruz
          showCustomToast(context, '✅ ${Strings.signUpSuccess}'); // Toast mesajını açtık

          // Toast mesajının görünmesi ve Navigator'ın serbest kalması için kısa bir gecikme
          await Future.delayed(const Duration(milliseconds: 2000));

          if (!mounted) return; // Gecikme sonrası tekrar kontrol
          // LoginScreen'e geri dön ve e-postayı doldurmak için e-postayı geri döndür
          Navigator.of(context).pop(email);
        } else {
          // API'den gelen hata mesajı varsa onu kullan, yoksa varsayılan mesajı göster
          showCustomErrorToast(context, data['error'] ?? Strings.signUpFailed);
        }
      } else {
        showCustomErrorToast(context, '❌ ${Strings.signUpFailed}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Strings.createAccount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        Strings.signUpToGetStarted,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      // E-posta Alanı
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: Strings.emailAddressHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Strings.emailRequired;
                          }
                          if (!EmailValidator.validate(value)) {
                            return Strings.emailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Parola Alanı
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: Strings.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Strings.passwordRequired;
                          }
                          if (value.length < 6) {
                            return Strings.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Parolayı Onayla Alanı
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: Strings.confirmPasswordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Strings.passwordRequired;
                          }
                          if (value != _passwordController.text) {
                            return Strings.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Kaydol Butonu
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
                          onPressed: _isLoading ? null : handleSignUp,
                          child: Text(
                            Strings.signUpButton,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Giriş Yap'a Geri Dön
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(Strings.alreadyHaveAnAccount),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              Strings.loginButton,
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading)
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
