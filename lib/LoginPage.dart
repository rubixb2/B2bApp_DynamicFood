

import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:odoosaleapp/services/UserService.dart';

import 'helpers/SessionManager.dart';


class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});


  void handleLogin(BuildContext context) async {
    final username = emailController.text;
    final password = passwordController.text;

    final apiService = UserService();
    final data = await apiService.login(username, password);

    if (data != null) {
      SessionManager().setSessionId(data['SessionId']);
      SessionManager().setUserName(username);
      SessionManager().setUserId(data['UserId']);
     /* await UserPreferences.saveUserInfo(
        data['SessionId']
      );*/

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed! Please check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  /*    appBar: AppBar(
        title: Text('Login'),
      ),*/
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
            ElevatedButton(
              onPressed: () {
                handleLogin(context);
                /*Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*/
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      //  Fluttertoast.showToast(msg: "Forgot Password Clicked!");
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(width: 50),
                  GestureDetector(
                    onTap: () {
                      //  Fluttertoast.showToast(msg: "Sign Up Clicked!");
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  Spacer()
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}
