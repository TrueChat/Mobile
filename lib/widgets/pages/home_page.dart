import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/widgets/pages/user_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BuildContext _scaffoldContext;

  bool _isBackTappedTwice = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () async {
        if (_isBackTappedTwice) {
          exit(0);
        }
        _isBackTappedTwice = true;
        const duration = Duration(seconds: 2);
        snackBar(
            _scaffoldContext, "Press again to exit", Colors.green, duration);
        Timer(duration, () {
          _isBackTappedTwice = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/launcher/foreground.png',
                  height: 30.0,
                  width: 30.0,
                ),
                SizedBox(width: 10.0,),
                Text(
                  "True ",
                  style: TextStyle(fontSize: 28.0, color: primarySwatchColor),
                ),
                Text(
                  "Chat",
                  style: TextStyle(
                      fontSize: 28.0, color: Theme.of(context).accentColor),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          backgroundColor: appBarColor,
        ),
        body: Builder(
          builder: (buildContext) {
            _scaffoldContext = buildContext;
            return _body();
          },
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Center(
                  child: GestureDetector(
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 100.0,
                    ),
                    onTap: () {
                      goToPage(context, UserPage());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return Center(
      child: Text(
        'Hello TrueChat!',
        style: Theme.of(context).textTheme.headline,
      ),
    );
  }
}
