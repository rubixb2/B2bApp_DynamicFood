import 'package:flutter/material.dart';
import 'package:odoosaleapp/theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Password does not match';
    }
    return null;
  }

  void handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Burada API çağrısı yapılabilir
      await Future.delayed(const Duration(seconds: 2)); // Örnek gecikme

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Success! Redirecting to Login...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );


      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context); // Login sayfasına geri dön
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: validateEmail,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: validatePassword,
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: validateConfirmPassword,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,  // Buton genişliği tam ekran olacak
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleSignUp, // Yüklenirken buton devre dışı
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Sign Up', style: AppTextStyles.buttonTextWhite),
                  style: AppButtonStyles.primaryButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
