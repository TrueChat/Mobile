import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/user_response.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/widgets/loading_screen.dart';
import 'package:true_chat/widgets/pages/chat_page.dart';
import 'package:true_chat/widgets/pages/user_settings_page.dart';
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/storage/storage_manager.dart' as storage_manager;
import 'package:true_chat/widgets/pages/user_statistics_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({this.username});

  final String username;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  LoadingScreen _loadingScreen;

  bool _isLoading = true;

  User _user;

  bool _isOwner = false;

  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
    _loadingScreen = LoadingScreen(
      doWhenReload: _initUserData,
    );
    _initUserData();
  }

  Future<void> _initUserData() async {
    bool connection = await constants.checkConnection();
    if (connection) {
      connection = await constants.checkConnection(
          connectionUrl: 'true-chat.herokuapp.com');
      if (connection) {
        final User user = await storage_manager.getUser();
        if (widget.username == user.username || widget.username == null) {
          _isOwner = true;
          final response = await api.getCurrentUser();
          if (response.isError) {
            _loadingScreen.noConnection(message: response.message);
          } else {
            final UserResponse userResponse = response;
            _user = userResponse.user;
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          try {
            final response = await api.getProfile(username: widget.username);
            setState(() {
              _user = response;
              _isLoading = false;
            });
          } catch (e) {
            final api.ApiException error = e;
            _loadingScreen.noConnection(message: error.message);
          }
        }
      } else {
        _loadingScreen.noConnection(message: constants.noConnectionToServer);
      }
    } else {
      _loadingScreen.noConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'User profile',
          style: TextStyle(
              fontSize: 28.0,
              color: constants.accentColor,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: constants.appBarColor,
        actions: <Widget>[
          if (_isOwner)
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => _goToSettingsPage(context),
            ),
        ],
      ),
      body: Builder(builder: (context) {
        _scaffoldContext = context;
        return _isLoading ? _loadingScreen : _body();
      }),
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_isOwner && !_isLoading)
            FloatingActionButton(
              heroTag: 'statistics',
              onPressed: () {
                constants.goToPage(context, UserStatisticsPage());
              },
              child: Icon(Icons.show_chart),
            ),
          const SizedBox(
            width: 8.0,
          ),
          if (!_isOwner && !_isLoading)
            FloatingActionButton(
              heroTag: 'message',
              onPressed: () {
                _goToDialogPage();
              },
              child: Icon(Icons.message),
            ),
        ],
      ),
    );
  }

  Future<void> _goToDialogPage() async {
    try {
      Chat chat = await api.getDialog(username: _user.username);
      bool isChatCreated;
      if (chat == null) {
        chat = Chat(
          creator: await storage_manager.getUser(),
          users: <User>[_user],
          isDialog: true,
        );
        isChatCreated = false;
      }
      constants.goToPage(
        context,
        ChatPage(
          chat: chat,
          isChatCreated: isChatCreated,
        ),
      );
    } catch (e) {
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message);
    }
  }

  String _avatarText() {
    String avatarText;
    if (_user.firstName.isEmpty || _user.lastName.isEmpty) {
      avatarText = 'NS';
    } else {
      avatarText = '${_user.firstName[0]}${_user.lastName[0]}'.toUpperCase();
    }
    return avatarText;
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: <Widget>[
            Container(
              color: constants.containerColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0).copyWith(left: 20.0),
                child: Row(
                  children: <Widget>[
                    CircularProfileAvatar(
                      _user == null  || _user.images.isEmpty ? '' : _user.images[0].imageURL,
                      cacheImage: true,
                      radius: 40.0,
                      initialsText: Text(
                        _avatarText(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      backgroundColor: constants.appBarColor,
                      borderColor: constants.appBarColor,
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _user.firstName.isEmpty ? 'Name' : _user.firstName,
                          style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          _user.lastName.isEmpty ? 'Surname' : _user.lastName,
                          style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              color: constants.containerColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0).copyWith(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Username'),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '@',
                          style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(color: constants.fontColor),
                        ),
                        Text(
                          _user.username,
                          style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              color: constants.containerColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0)
                    .copyWith(left: 20.0, bottom: 20.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Bio'),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            _user.about ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  Future _goToSettingsPage(BuildContext context) async {
    final User result = await Navigator.push(
        context,
        MaterialPageRoute<User>(
            builder: (context) => UserSettingsPage(
                  user: _user,
                )));
    if (result != null) {
      setState(() {
        _user = result;
      });
    }
  }
}
