import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/B2bMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CartPage.dart';
import 'helpers/Strings.dart';


class B2bOrderCompletePage extends StatelessWidget {
  final String orderId;


  const B2bOrderCompletePage({required this.orderId, super.key});






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 100,
              color: Color(0xFF4E6EF2),
            ),
            SizedBox(height: 20),
            Text(
              Strings.orderSuccess,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),
            Text(
              '${Strings.orderNumber}\n$orderId',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),
         /*   Text(
              Strings.paymentReminder,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),*/

            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child:
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => B2bMainPage()),
                        (Route<dynamic> route) => false,
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4E6EF2),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.home_filled, color: Colors.white),
                label: Text(
                  Strings.backToHome,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),

              ),


            ),
          ],
        ),
      ),
    );
  }
}