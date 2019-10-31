import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/user_response.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/widgets/loading_screen.dart';

class UserSettingsPage extends StatefulWidget {
  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  LoadingScreen _loadingScreen;

  bool _isNamePressed = false;
  bool _isUsernamePressed = false;
  bool _isBioPressed = false;
  bool _isLoading = true;

  BuildContext _scaffoldContext;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _currentName;
  String _currentSurname;
  String _currentUsername;
  String _currentBio;

  final FocusNode _focusNodeSurname = FocusNode();
  final FocusNode _focusNodeName = FocusNode();

  final InputDecoration _textFieldDecoration = InputDecoration(
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor, width: 2.0)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor, width: 2.0)));

  Widget _nameWidget() => _isNamePressed
      ? Expanded(
          child: SizedBox(
              child: Column(
            children: <Widget>[
              TextField(
                controller: _nameController,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                autofocus: true,
                onSubmitted: (query) {
                  _fieldFocusChange(context, _focusNodeName, _focusNodeSurname);
                },
                decoration: _textFieldDecoration,
                onChanged: (query) {
                  _currentName = query;
                },
                focusNode: _focusNodeName,
                textInputAction: TextInputAction.next,
              ),
              TextField(
                controller: _surNameController,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                autofocus: true,
                onSubmitted: (query) {
                  setState(() {
                    _isNamePressed = !_isNamePressed;
                  });
                },
                decoration: _textFieldDecoration,
                onChanged: (query) {
                  _currentSurname = query;
                },
                focusNode: _focusNodeSurname,
              ),
            ],
          )),
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _currentName,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              _currentSurname,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        );

  Widget _usernameWidget() => _isUsernamePressed
      ? Expanded(
          child: TextField(
            controller: _usernameController,
            style:
                Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
            autofocus: true,
            onSubmitted: (query) {
              setState(() {
                _isUsernamePressed = !_isUsernamePressed;
              });
            },
            onChanged: (query) {
              _currentUsername = query;
            },
            decoration: _textFieldDecoration,
          ),
        )
      : Text(
          _currentUsername,
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
        );

  Widget _bioWidget() => _isBioPressed
      ? TextField(
          minLines: 1,
          maxLines: 5,
          textInputAction: TextInputAction.done,
          controller: _bioController,
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
          autofocus: true,
          onSubmitted: (query) {
            setState(() {
              _isBioPressed = !_isBioPressed;
            });
          },
          onChanged: (query) {
            _currentBio = query;
          },
          decoration: _textFieldDecoration,
        )
      : Text(
          _currentBio,
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
        );

  @override
  void initState() {
    super.initState();
    _loadingScreen = LoadingScreen(
      doWhenReload: _initUserData,
    );
    _initUserData();
  }

  void _updateControllers() {
    _usernameController.text = _currentUsername;
    _nameController.text = _currentName;
    _surNameController.text = _currentSurname;
    _bioController.text = _currentBio;
  }

  void _initUserData() {
    try {
      bool isThenReached = false;
      api.getCurrentUser().then((response) {
        isThenReached = true;
        if (response.isError) {
          _loadingScreen.state.noConnection(message: response.message);
        } else {
          final UserResponse userResponse = response;
          final User user = userResponse.user;
          setState(() {
            _currentName = user.firstName == null || user.firstName == ''
                ? yourName
                : user.firstName;
            _currentSurname = user.lastName == null || user.lastName == ''
                ? yourSurName
                : user.lastName;
            _currentBio = user.about == null || user.about == ''
                ? literallyAnything
                : user.about;
            _currentUsername = user.username;
            _updateControllers();
            _isLoading = false;
          });
        }
      }).whenComplete(() {
        if (!isThenReached) {
          _loadingScreen.state.noConnection(message: noConnectionMessage);
        }
      });
    } on SocketException {
      _loadingScreen.state.noConnection(message: noConnectionMessage);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.title.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: appBarColor,
      ),
      body: Builder(
        builder: (context) {
          _scaffoldContext = context;
          return _isLoading ? _loadingScreen : _body();
        },
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  String _initialText() =>
      '${_nameController.text[0]}${_surNameController.text[0]}'.toUpperCase();

  Widget _body() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: <Widget>[
                Container(
                  color: containerColor,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0).copyWith(left: 20.0),
                    child: Row(
                      children: <Widget>[
                        CircularProfileAvatar(
                          '',
                          radius: 40.0,
                          initialsText: Text(
                            _initialText(),
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                          backgroundColor: primaryColor,
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        _nameWidget(),
                        if (!_isNamePressed)
                          const Expanded(
                            child: SizedBox(),
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: fontColor,
                          ),
                          iconSize: 30.0,
                          onPressed: () {
                            setState(() {
                              if (!_isNamePressed) {
                                _isBioPressed = false;
                                _isUsernamePressed = false;
                                _isNamePressed = !_isNamePressed;
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  color: containerColor,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0).copyWith(left: 20.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
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
                                        .copyWith(color: fontColor),
                                  ),
                                  _usernameWidget()
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: fontColor,
                          ),
                          iconSize: 30.0,
                          onPressed: () {
                            setState(() {
                              if (!_isUsernamePressed) {
                                _isNamePressed = false;
                                _isBioPressed = false;
                                _isUsernamePressed = !_isUsernamePressed;
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  color: containerColor,
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
                                'You can write anything about you:',
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(color: Colors.white),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              _bioWidget()
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: fontColor,
                          ),
                          iconSize: 30.0,
                          onPressed: () {
                            setState(() {
                              if (!_isBioPressed) {
                                _isNamePressed = false;
                                _isUsernamePressed = false;
                                _isBioPressed = !_isBioPressed;
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 80.0,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: RawMaterialButton(
              onPressed: _submitPressed,
              child: Icon(
                Icons.done,
                color: Theme.of(context).backgroundColor,
                size: 60.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: accentColor,
              padding: const EdgeInsets.all(5.0),
            ),
          ),
        ),
      ],
    );
  }

  void _submitPressed() {
    try {
      setState(() {
        _isLoading = true;
      });
      String name;
      String bio;
      String surname;
      if (_currentName != yourName) {
        name = _currentName;
      }
      if (_currentBio != literallyAnything) {
        bio = _currentBio;
      }
      if (_currentSurname != yourSurName) {
        surname = _currentSurname;
      }
      bool isThenReached = false;
      api
          .changeUserData(
              name: name,
              surname: surname,
              bio: bio,
              username: _currentUsername)
          .then((response) {
        isThenReached = true;
        if (response.isError) {
          snackBar(_scaffoldContext, response.message, Colors.red);
        } else {
          setState(() {
            _isLoading = false;
          });
          snackBar(_scaffoldContext, response.message, Colors.green);
        }
      }).whenComplete(() {
        if (!isThenReached) {
          _loadingScreen.state.noConnection(message: noConnectionMessage);
        }
      });
    } on SocketException {
      _loadingScreen.state.noConnection(message: noConnectionMessage);
    }
  }
}
