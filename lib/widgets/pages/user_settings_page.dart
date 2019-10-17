import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/user_response.dart';
import 'package:true_chat/blocs/user_settings/user_settings_bloc.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/widgets/loading_screen.dart';

class UserSettingsPage extends StatefulWidget {
  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  UserSettingsBloc _userSettingsBloc;

  LoadingScreen _loadingScreen;

  bool _isNamePressed = false;
  bool _isUsernamePressed = false;
  bool _isBioPressed = false;
  bool _isLoading = true;

  BuildContext _scaffoldContext;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _surNameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  String _currentName;
  String _currentSurname;
  String _currentUsername;
  String _currentBio;

  FocusNode _focusNodeSurname = FocusNode();
  FocusNode _focusNodeName = FocusNode();

  InputDecoration _textFieldDecoration = InputDecoration(
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primarySwatchColor, width: 2.0)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primarySwatchColor, width: 2.0)));

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
            SizedBox(
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
    _userSettingsBloc = UserSettingsBloc();
    _loadingScreen = LoadingScreen(
      doWhenReload: _initUserData(),
    );
  }

  _updateControllers() {
    _usernameController.text = _currentUsername;
    _nameController.text = _currentName;
    _surNameController.text = _currentSurname;
    _bioController.text = _currentBio;
  }

  _initUserData() {
    try {
      bool isThenReached = false;
      Api.getCurrentUser().then((response) {
        isThenReached = true;
        if (response.isError) {
          _loadingScreen.state.noConnection(message: response.message);
        } else {
          User user = (response as UserResponse).user;
          setState(() {
            _currentName = user.firstName ?? yourName;
            _currentSurname = user.lastName ?? yourSurName;
            if (_currentSurname == "") {
              _currentSurname = yourSurName;
            }
            _currentBio = user.about ?? literallyAnything;
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
    _userSettingsBloc.dispose();
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
        title: Center(
          child: Text(
            "Settings",
            style: TextStyle(
                fontSize: 28.0,
                color: primarySwatchColor,
                fontWeight: FontWeight.bold),
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
                        SizedBox(
                          width: 20.0,
                        ),
                        _nameWidget(),
                        if (!_isNamePressed)
                          Expanded(
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
                SizedBox(
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
                              Text("Username"),
                              SizedBox(
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
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  color: containerColor,
                  child: Padding(
                    padding:
                        EdgeInsets.all(10.0).copyWith(left: 20.0, bottom: 20.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Bio"),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                "You can write anything about you:",
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(color: Colors.white),
                              ),
                              SizedBox(
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
                SizedBox(
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
              fillColor: primarySwatchColor,
              padding: const EdgeInsets.all(5.0),
            ),
          ),
        ),
      ],
    );
  }

  _submitPressed() {
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
      Api.changeUserData(name: name, surname: surname, bio: bio)
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
