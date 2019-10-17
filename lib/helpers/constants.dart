import 'package:flutter/material.dart';

//Strings
const appName = "TrueChat";
const emailHint = "Email";
const loginHint = "Login";
const passwordHint = "Password";
const password2Hint = "Confirm password";
const smthWentWrong = "Something went wrong";
const noConnectionMessage = "No connection";
const yourName = "Name";
const yourSurName = "Surname";
const literallyAnything = 'Literally anything.';

//SharedPreferences
const accessTokenKey = "jwt";
const isFirstLaunchKey = "first_launch";

//Colors
const Color primaryColor = Color(0xFF614bf8);
const Color accentColor = Color(0xFFFC9E4F);
const Color backgroundColor = Color(0xFF2D2D37);
const Color containerColor = Color(0xFF292933);
const Color primarySwatchColor = Color(0xFFD66247);
const Color appBarColor = Color(0xFF12121d);
const Color fontColor = Color(0xFFc6c6c9);

//Values
const textFieldWidth = 300.0;

//Regular Expressions
RegExp emailRegExp = RegExp(
    "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$");
RegExp loginRegExp = RegExp("[a-zA-Z0-9]");

//Functions
snackBar(BuildContext context, String message,
    [Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 3)]) {
  return Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
      style: Theme.of(context).textTheme.body1,
      textAlign: TextAlign.center,
    ),
    backgroundColor: backgroundColor,
    duration: duration,
  ));
}

goToPage(BuildContext context, Widget page) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
