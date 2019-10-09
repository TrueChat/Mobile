import 'package:flutter/material.dart';
import 'package:true_chat/storage/shared_pref_manager.dart';
import 'package:true_chat/widgets/pages/home_page.dart';
import 'package:true_chat/widgets/pages/login_page.dart';

import 'helpers/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _isLoggedIn = false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future:  SharedPrefManager.isLoggedIn().then((value){
          _isLoggedIn = value;
        }),
        builder: (context,snapshot){
          return _isLoggedIn ? LogInPage() : HomePage();
        },
      ),

      theme: ThemeData(
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        brightness: Brightness.dark,
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 24.0),
          body1: TextStyle(fontSize: 20.0),
          button: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
