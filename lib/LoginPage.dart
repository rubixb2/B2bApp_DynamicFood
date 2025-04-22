import 'package:flutter/material.dart';
import 'package:odoosaleapp/services/UserService.dart';
import 'package:odoosaleapp/theme.dart';
import 'SignUpPage.dart';
import 'helpers/SessionManager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void handleLogin(BuildContext context, bool guest) async {
    String username = "";
    String password = "";

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

      Navigator.pushReplacementNamed(context, '/home');
    } else
    {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed! Please check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/rb2.png',
              width: 90,
              height: 90,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => handleLogin(context, false),
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Login', style: AppTextStyles.buttonTextWhite),
                style: AppButtonStyles.primaryButton,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      handleLogin(context, true);
                    },
                    child: const Text(
                      'Guest',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,fontSize: 16),
                    ),
                  ),
                 /* const SizedBox(width: 50),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,fontSize: 16),
                    ),
                  ),*/
                  const Spacer()
                ],
              ),
            ),
          ],

        ),
      ),
    );
  }
}
