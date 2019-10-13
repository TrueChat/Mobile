import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/storage/storage_manager.dart';
import 'package:true_chat/widgets/pages/home_page.dart';
import 'package:true_chat/widgets/pages/login_page.dart';

import 'helpers/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: StorageManager.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            bool isLoggedIn = snapshot.data;
            return isLoggedIn ? HomePage() : LogInPage();
          } else {
            return Container();
          }
        },
      ),
      theme: ThemeData(
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        brightness: Brightness.dark,
        fontFamily: 'Arial',
        textTheme: TextTheme(
          headline: TextStyle(
              fontSize: 32.0, fontWeight: FontWeight.bold, color: fontColor),
          title: TextStyle(fontSize: 28.0, color: fontColor),
          body1: TextStyle(fontSize: 20.0, color: fontColor),
          button: TextStyle(fontSize: 22.0),
        ),
      ),
    );
  }
}
