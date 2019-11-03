import 'dart:async';
import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/storage/storage_manager.dart' as storage_manager;
import 'package:true_chat/widgets/pages/create_group_page.dart';
import 'package:true_chat/widgets/pages/edit_group_page.dart';
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

  final List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _initUserData();
    for (int i = 0; i < 10; ++i) {
      final List<User> users = [];
      for (int j = 0; j < 5; j++) {
        users.add(
          User(
            firstName: 'firstname $j',
            lastName: 'lastname $j',
            username: 'username $j',
          ),
        );
      }
      _chats.add(
        Chat(
          id: i,
          name: 'Chat #$i',
          description: 'Chat with number $i',
          users: users,
        ),
      );
    }
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
        constants.snackBar(
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
                constants.logoAsset,
                height: 30.0,
                width: 30.0,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                'True chat',
                style: TextStyle(fontSize: 28.0, color: constants.accentColor),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: _searchPressed,
            )
          ],
          backgroundColor: constants.appBarColor,
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

  void _searchPressed() {}

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
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(
        height: 8.0,
      ),
      itemBuilder: (context, index) => _chatItem(index),
      itemCount: _chats.length,
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
    );
  }

  Widget _chatItem(int index) {
    final chat = _chats[index];
    return GestureDetector(
      onTap: () {
        constants.goToPage(
            context,
            EditGroupPage(
              chat: chat,
            ));
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: constants.containerColor,
        child: Row(
          children: <Widget>[
            CircularProfileAvatar(
              'NS',
              radius: 40.0,
              initialsText: Text(
                'NS',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              backgroundColor: constants.appBarColor,
              borderColor: constants.appBarColor,
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        chat.name,
                        style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        '20:24',
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(fontSize: 16.0),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'sajdksakdkasdkaksdkaasdsadsadsadsaddassdkdj',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leftSideDrawer() {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: constants.backgroundColor),
      child: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: constants.drawerHeaderColor),
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
                      backgroundColor: constants.containerColor,
                      borderColor: constants.containerColor,
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
                  constants.goToPage(context, UserPage());
                },
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            GestureDetector(
              child: Container(
                color: constants.containerColor,
                child: ListTile(
                  leading: Icon(
                    Icons.add,
                    color: constants.fontColor,
                  ),
                  title: Text(
                    'Create group chat',
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
              ),
              onTap: () {
                constants.goToPage(context, CreateGroupPage());
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  child: Container(
                    color: constants.containerColor,
                    child: ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: constants.fontColor,
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
      } else {
        constants.snackBar(_scaffoldContext, response.message, Colors.red);
      }
    });
  }
}
