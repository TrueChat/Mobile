import 'package:flutter/material.dart';


//Strings
const appName = "TrueChat";
const noConnectionMessage = "No connection";

//SharedPreferences
const accessTokenKey = "access_token";
const refreshTokenKey = "refresh_token";
const isFirstLaunchKey = "first_launch";

//Colors
const Color colorPrimary = Color(0xFF2A3235);
const Color colorAccent = Color(0xFF09804D);
const Color colorBackground = Color(0xFFF0F0F0);

//Functions
snackBar(BuildContext context,String message,bool isError,
    {Duration duration = const Duration(seconds: 3),
      TextAlign textAlign = TextAlign.center}){
  return Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(message,textAlign: textAlign,),
    backgroundColor: isError ? Colors.red : Colors.green,
    duration: duration,
  ));
}

goToPage(BuildContext context,Widget page) => Navigator
    .push(
    context,
    MaterialPageRoute(builder: (context) => page)
);