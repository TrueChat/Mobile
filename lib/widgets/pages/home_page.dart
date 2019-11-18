import 'dart:async';
import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/chats_response.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/storage/storage_manager.dart' as storage_manager;
import 'package:true_chat/widgets/pages/create_group_page.dart';
import 'package:true_chat/widgets/pages/edit_group_page.dart';
import 'package:true_chat/widgets/pages/login_page.dart';
import 'package:true_chat/widgets/pages/search_members_page.dart';
import 'package:true_chat/widgets/pages/user_page.dart';
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/widgets/pages/user_settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  BuildContext _scaffoldContext;

  bool _isBackTappedTwice = false;

  String _firstName = 'N';
  String _lastName = 'S';

  List<Chat> _chats = [];

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _initChats();
  }

  @override
  void didPopNext() {
    _initChats();
  }

  @override
  void initState() {
    super.initState();
    _initUserData();
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

  Future<void> _initUserData() async {
    final User user = await storage_manager.getUser();
    setState(() {
      _firstName =
          user.firstName == null || user.firstName == '' ? 'N' : user.firstName;
      _lastName =
          user.lastName == null || user.lastName == '' ? 'S' : user.lastName;
    });
    if (user.firstName.isEmpty || user.lastName.isEmpty) {
      final bool result = await Navigator.push(context,
          MaterialPageRoute<bool>(builder: (context) => UserSettingsPage(user: user)));
      if (result) {
        _initUserData();
      }
    }
  }

  Future<void> _initChats() async {
    try {
      final ChatsResponse response = await api.fetchChats(1);
      setState(() {
        _chats = response.results;
      });
    } catch (e) {
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message);
    }
  }

  Widget _body() {
    return FutureBuilder<ChatsResponse>(
        future: api.fetchChats(1),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _chats = snapshot.data.results;
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(
                height: 8.0,
              ),
              itemBuilder: (context, index) => _chatItem(index),
              itemCount: _chats.length,
              padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
            );
          } else if (snapshot.hasError) {
            final api.ApiException error = snapshot.error;
            return Center(
              child: Text(
                error.message,
                style: Theme.of(context).textTheme.title,
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Future<void> _onChatItemPressed(int index) async {
    final Chat result = await Navigator.push(
      context,
      MaterialPageRoute<Chat>(
        builder: (context) => EditGroupPage(
          chat: _chats[index],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _chats[index] = result;
      });
    }
  }

  Widget _chatItem(int index) {
    final chat = _chats[index];
    String initText = '';
    final List<String> chatName = chat.name.split(' ');
    if (chatName.length == 2) {
      initText = '${chatName[0][0]}${chatName[1][0]}';
    } else {
      initText = '${chatName[0][0]}';
    }
    return GestureDetector(
      onTap: () => _onChatItemPressed(index),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: constants.containerColor,
        child: Row(
          children: <Widget>[
            CircularProfileAvatar(
              '',
              radius: 40.0,
              initialsText: Text(
                initText.toUpperCase(),
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
                      Flexible(
                        child: Text(
                          chat.name,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.white,
                              ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    chat.description,
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
                  _goToUserPage(context);
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
            const SizedBox(
              height: 8.0,
            ),
            GestureDetector(
              child: Container(
                color: constants.containerColor,
                child: ListTile(
                  leading: Icon(
                    Icons.search,
                    color: constants.fontColor,
                  ),
                  title: Text(
                    'Search for users',
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
              ),
              onTap: () {
                constants.goToPage(context, const SearchMembersPage());
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

  Future _goToUserPage(BuildContext context) async {
    final bool result = await Navigator.push(context,
        MaterialPageRoute<bool>(builder: (context) => const UserPage()));
    if (result) {
      _initUserData();
    }
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
