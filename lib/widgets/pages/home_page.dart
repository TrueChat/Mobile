import 'dart:async';
import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/message.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/chats_response.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/storage/storage_manager.dart' as storage_manager;
import 'package:true_chat/widgets/pages/chat_page.dart';
import 'package:true_chat/widgets/pages/chat_create_page.dart';
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
  User _user;

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
    _user = await storage_manager.getUser();
    setState(() {
      _firstName = _user.firstName == null || _user.firstName == ''
          ? 'N'
          : _user.firstName;
      _lastName =
          _user.lastName == null || _user.lastName == '' ? 'S' : _user.lastName;
    });
    if (_user.firstName.isEmpty || _user.lastName.isEmpty) {
      final bool result = await Navigator.push(
          context,
          MaterialPageRoute<bool>(
              builder: (context) => UserSettingsPage(user: _user)));
      if (result) {
        _initUserData();
      }
    }
  }

  Future<void> _initChats() async {
    try {
      await api.fetchChats(1).then((result) {
        setState(() {
          _chats = result.results;
        });
        _initChats();
      });
    } catch (e) {
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message, Colors.red);
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
    final Chat chat = _chats[index];
    if(chat.users[0].id != chat.creator.id){
      chat.users.insert(0,chat.creator);
    }
    final Chat result = await Navigator.push(
      context,
      MaterialPageRoute<Chat>(
        builder: (context) => ChatPage(
          chat: chat,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _chats[index] = result;
      });
    }
  }

  String _chatName(Chat chat) {
    String name = '';
    final User user =
        chat.users[0].id == _user.id ? chat.creator : chat.users[0];
    if (user.firstName.isNotEmpty) {
      name += '${user.firstName} ';
    }
    if (user.lastName.isNotEmpty) {
      name += '${user.lastName}';
    }
    if (name.isEmpty) {
      name = user.username;
    }
    return name;
  }

  String _getTime(String dateTime){
    String messageTime;
    final RegExpMatch match =
    constants.timeRegExp.firstMatch(dateTime);
    messageTime = match.input.substring(match.start, match.end);
    int messageHours = int.parse(messageTime.substring(0, 2)) + 2;
    String replace;
    if (messageHours >= 24) {
      messageHours -= 24;
      replace = '0$messageHours';
    } else {
      replace = messageHours.toString();
    }

    messageTime = messageTime.replaceRange(0, 2, replace.toString());

    return messageTime;
  }

  Widget _chatItem(int index) {
    final chat = _chats[index];
    String initText = '';
    if (chat.isDialog) {
      final List<String> chatName = _chatName(chat).split(' ');
      if (chatName.length == 2) {
        initText = '${chatName[0][0]}${chatName[1][0]}';
      } else {
        initText = '${chatName[0][0]}';
      }
    } else {
      final List<String> chatName = chat.name.split(' ');
      if (chatName.length == 2) {
        initText = '${chatName[0][0]}${chatName[1][0]}';
      } else {
        initText = '${chatName[0][0]}';
      }
    }
    String messageTime;
    String lastMessage;
    if(chat.lastMessage != null){
      messageTime = _getTime(chat.lastMessage.dateCreated);
      if(chat.lastMessage != null){
        lastMessage = chat.lastMessage.content;
        if(chat.lastMessage.user.id == _user.id){
          lastMessage = 'You: $lastMessage';
        }else{
          if(!chat.isDialog){
            lastMessage = '${chat.lastMessage.user.username}: $lastMessage';
          }
        }
      }else{
        lastMessage = '';
      }
    }else{
      messageTime = _getTime(chat.dateCreated);
    }
    if(!chat.isDialog && chat.description.isNotEmpty && chat.description != null){
      lastMessage = chat.description;
    }
    return GestureDetector(
      onTap: () => _onChatItemPressed(index),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: constants.containerColor,
        child: Row(
          children: <Widget>[
            CircularProfileAvatar(
              chat.images.isEmpty ? '' : chat.images[0].imageURL,
              cacheImage: true,
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
                      Expanded(
                        child: Text(
                          chat.isDialog ? _chatName(chat) : chat.name,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.white,
                              ),
                          maxLines: 2,
                        ),
                      ),
                      Text(
                        messageTime ?? '',
                        style: Theme.of(context).textTheme.body1.copyWith(fontSize: 14.0),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    lastMessage ?? '',
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
                      _user == null || _user.images.isEmpty ? '' : _user.images[0].imageURL,
                      cacheImage: true,
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
                constants.goToPage(context, CreateChatPage());
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
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            backgroundColor: constants.backgroundColor,
            title: Container(
              color: constants.containerColor,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Are you sure you want to log out?',
                style: Theme.of(context).textTheme.title,
                textAlign: TextAlign.center,
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: constants.containerColor,
                      child: Text(
                        'Yes',
                        style: Theme.of(context).textTheme.body1,
                      ),
                      onPressed: () {
                        api.logout().whenComplete((){
                          Navigator.of(context).pushAndRemoveUntil<void>(
                              MaterialPageRoute(
                                  builder: (context) => LogInPage()),
                                  (Route<dynamic> route) => false);
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: constants.containerColor,
                      child: Text(
                        'No',
                        style: Theme.of(context).textTheme.body1,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
