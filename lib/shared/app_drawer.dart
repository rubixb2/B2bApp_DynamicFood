// lib/widgets/AppDrawer.dart

import 'package:flutter/material.dart';
import '../helpers/LanguageManager.dart';
import '../helpers/Strings.dart';
import '../B2bLoginPage.dart';
import '../services/UserService.dart';
import '../helpers/SessionManager.dart';

class AppDrawer extends StatefulWidget {
  final Function(int) onNavItemSelected;

  const AppDrawer({
    Key? key,
    required this.onNavItemSelected,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  AppLanguage selectedLanguage = LanguageManager().currentLanguage;

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Strings.logout),
        content: Text(Strings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(Strings.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userService = UserService();
      final sessionId = SessionManager().sessionId ?? '';
      final customerId = SessionManager().customerId ?? 0;

      try {
        final response = await userService.logout(sessionId, customerId);

        if (response != null && response['Control'] == 1) {
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout failed.')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _setLanguage(AppLanguage lang) async {
    await LanguageManager().setLanguage(lang);
    setState(() {
      selectedLanguage = lang;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(Strings.menu),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(Strings.myOrders),
            onTap: () {
              Navigator.pop(context);
              widget.onNavItemSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: Text(Strings.myInvoice),
            onTap: () {
              Navigator.pop(context);
              widget.onNavItemSelected(3);
            },
          ),
          const Divider(),
          ListTile(
            title: InkWell(
              onTap: () => _setLanguage(AppLanguage.dutch),
              child: Row(
                children: [
                  Image.network(
                    'https://flagcdn.com/w20/nl.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Nederlands'),
                  const Spacer(),
                  Radio<AppLanguage>(
                    value: AppLanguage.dutch,
                    groupValue: selectedLanguage,
                    onChanged: (AppLanguage? value) {
                      if (value != null) _setLanguage(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: InkWell(
              onTap: () => _setLanguage(AppLanguage.english),
              child: Row(
                children: [
                  Image.network(
                    'https://flagcdn.com/w20/gb.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('English'),
                  const Spacer(),
                  Radio<AppLanguage>(
                    value: AppLanguage.english,
                    groupValue: selectedLanguage,
                    onChanged: (AppLanguage? value) {
                      if (value != null) _setLanguage(value);
                    },
                  ),
                ],
              ),
            ),
          ),

          ListTile(
            title: InkWell(
              onTap: () => _setLanguage(AppLanguage.french),
              child: Row(
                children: [
                  Image.network(
                    'https://flagcdn.com/w20/fr.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Français'),
                  const Spacer(),
                  Radio<AppLanguage>(
                    value: AppLanguage.french,
                    groupValue: selectedLanguage,
                    onChanged: (AppLanguage? value) {
                      if (value != null) _setLanguage(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: InkWell(
              onTap: () => _setLanguage(AppLanguage.turkish),
              child: Row(
                children: [
                  Image.network(
                    'https://flagcdn.com/w20/tr.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Türkçe'),
                  const Spacer(),
                  Radio<AppLanguage>(
                    value: AppLanguage.turkish,
                    groupValue: selectedLanguage,
                    onChanged: (AppLanguage? value) {
                      if (value != null) _setLanguage(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(Strings.logout, style: const TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
