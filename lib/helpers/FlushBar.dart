import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCustomToast(BuildContext context, String message) {
  Flushbar(
    title: 'Success',
    message: message,
    icon: Icon(Icons.check, color: Colors.white),
    duration: Duration(milliseconds: 1500),
    flushbarPosition: FlushbarPosition.BOTTOM,
    flushbarStyle: FlushbarStyle.FLOATING,
    reverseAnimationCurve: Curves.decelerate,
    forwardAnimationCurve: Curves.easeIn,
    backgroundColor: Colors.green,
    boxShadows: [
      BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 3)
    ],
    margin: EdgeInsets.all(8),
  )..show(context);
}
void showCustomErrorToast(BuildContext context, String message) {
  Flushbar(
    title: 'Error',
    message: message,
    icon: Icon(Icons.error, color: Colors.white),
    duration: Duration(milliseconds: 2000),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.GROUNDED,
    reverseAnimationCurve: Curves.decelerate,
    forwardAnimationCurve: Curves.easeInBack,
    backgroundColor: Colors.redAccent,
    boxShadows: [
      BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 3)
    ],
    margin: EdgeInsets.all(8),
  )..show(context);
}
void showCustomWarningToast(BuildContext context, String message) {
  Flushbar(
    title: 'Warning',
    message: message,
    icon: Icon(Icons.warning, color: Colors.white),
    duration: Duration(milliseconds: 2000),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.GROUNDED,
    reverseAnimationCurve: Curves.decelerate,
    forwardAnimationCurve: Curves.easeIn,
    backgroundColor: Colors.pinkAccent,
    boxShadows: [
      BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 3)
    ],
    margin: EdgeInsets.all(8),
  )..show(context);
}