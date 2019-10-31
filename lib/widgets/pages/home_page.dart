import 'dart:async';
import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/storage/storage_manager.dart' as storage_manager;
import 'package:true_chat/widgets/pages/create_group_page.dart';
import 'package:true_chat/widgets/pages/login_page.dart';
import 'package:true_chat/widgets/pages/user_page.dart';
import 'package:true_chat/api/api.dart' as api;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BuildContext _scaffoldContext;

  bool _isBackTappedTwice = false;

  String _firstName = 'N';
  String _lastName = 'S';

  @override
  void initState() {
    _initUserData();
    super.initState();
  }

  String _initialText() => '${_firstName[0]}${_lastName[0]}'.toUpperCase();

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
            _scaffoldContext, 'Press again to exit', Colors.green, duration);
        Timer(duration, () {
          _isBackTappedTwice = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            children: <Widget>[
              Image.asset(
                logoAsset,
                height: 30.0,
                width: 30.0,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                'True chat',
                style: TextStyle(fontSize: 28.0, color: accentColor),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
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
        drawer: _leftSideDrawer(),
      ),
    );
  }

  Future<void> _initUserData() async {
    final User user = await storage_manager.getUser();
    setState(() {
      _firstName =
          user.firstName == null || user.firstName == '' ? 'N' : user.firstName;
      _lastName =
          user.lastName == null || user.lastName == '' ? 'S' : user.lastName;
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

  Widget _leftSideDrawer() {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: backgroundColor),
      child: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: drawerHeaderColor),
              child: GestureDetector(
                child: Row(
                  children: <Widget>[
                    CircularProfileAvatar(
                      '',
                      radius: 40.0,
                      initialsText: Text(
                        _initialText(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      backgroundColor: containerColor,
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          _firstName,
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        Text(
                          _lastName,
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  goToPage(context, UserPage());
                },
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            GestureDetector(
              child: Container(
                color: containerColor,
                child: ListTile(
                  leading: Icon(
                    Icons.add,
                    color: fontColor,
                  ),
                  title: Text(
                    'Create group chat',
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
              ),
              onTap: (){
                goToPage(context,CreateGroupPage());
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  child: Container(
                    color: containerColor,
                    child: ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: fontColor,
                      ),
                      title: Text(
                        'Logout',
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ),
                  onTap: () => _logout(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    api.logout().then((response) {
      if (response != null && !response.isError) {
        Navigator.of(context).pushAndRemoveUntil<void>(
            MaterialPageRoute(builder: (context) => LogInPage()),
            (Route<dynamic> route) => false);
      }
    });
  }
}
