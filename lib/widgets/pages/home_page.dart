import 'dart:async';
import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/user_response.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/helpers/constants.dart' as prefix0;
import 'package:true_chat/storage/storage_manager.dart';
import 'package:true_chat/widgets/pages/user_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BuildContext _scaffoldContext;

  bool _isBackTappedTwice = false;

  String firstName = 'N';
  String lastName = 'S';

  @override
  void initState() {
    _initUserData();
    super.initState();
  }

  String _initialText() => '${firstName[0]}${lastName[0]}'.toUpperCase();

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
                  logoAsset,
                  height: 30.0,
                  width: 30.0,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "True chat",
                  style: TextStyle(fontSize: 28.0, color: accentColor),
                ),
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
                    child: CircularProfileAvatar(
                      '',
                      radius: 40.0,
                      initialsText: Text(
                        _initialText(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
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

  _initUserData() async{
    User user = await StorageManager.getUser();
    setState(() {
      firstName = user.firstName == null || user.firstName == '' ? 'N' : user.firstName;
      lastName = user.lastName == null || user.lastName == '' ? 'S' : user.lastName;
    });
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
