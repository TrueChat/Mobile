import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/user_response.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/widgets/loading_screen.dart';
import 'package:true_chat/widgets/pages/user_settings_page.dart';
import 'package:true_chat/api/api.dart' as api;

class UserPage extends StatefulWidget {
  const UserPage({this.userId});

  final int userId;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  LoadingScreen _loadingScreen;

  bool _isLoading = true;

  User _user;

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
        if (widget.userId == null) {
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
        title: Text(
          'User profile',
          style: TextStyle(
              fontSize: 28.0,
              color: constants.accentColor,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: constants.appBarColor,
      ),
      body: _isLoading ? _loadingScreen : _body(),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  String avatarText() => '${_user.firstName[0]}${_user.lastName[0]}';

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
                      '',
                      radius: 40.0,
                      initialsText: Text(
                        avatarText(),
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
                          _user.firstName,
                          style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          _user.lastName,
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
                            _user.about,
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
            if (widget.userId == null)
              RaisedButton(
                child: const Text('Settings'),
                onPressed: () {
                  constants.goToPage(
                      context,
                      UserSettingsPage(
                        user: _user,
                      ));
                },
              ),
          ],
        ),
      ),
    );
  }
}
