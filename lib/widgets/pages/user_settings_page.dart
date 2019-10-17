import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/blocs/user_settings/user_settings_bloc.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/helpers/constants.dart' as constants;

class UserSettingsPage extends StatefulWidget {
  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  UserSettingsBloc _userSettingsBloc;

  bool _isNamePressed = false;
  bool _isUsernamePressed = false;
  bool _isBioPressed = false;

  TextEditingController _nameController = TextEditingController();
  String _currentName = 'Name Surname';
  TextEditingController _usernameController = TextEditingController();
  String _currentUsername = 'StandartUsername';
  TextEditingController _bioController = TextEditingController();
  String _currentBio = 'Literally anything.';

  InputDecoration _textFieldDecoration = InputDecoration(
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primarySwatchColor, width: 2.0)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primarySwatchColor, width: 2.0)));

  Widget _nameWidget() => _isNamePressed
      ? Expanded(
          child: SizedBox(
            child: TextField(
              controller: _nameController,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              autofocus: true,
              onSubmitted: (query) {
                _currentName = _nameController.text;
                setState(() {
                  _isNamePressed = !_isNamePressed;
                });
              },
              decoration: _textFieldDecoration,
            ),
          ),
        )
      : Text(
          _currentName,
          style: Theme.of(context)
              .textTheme
              .body1
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        );

  Widget _usernameWidget() => _isUsernamePressed
      ? Expanded(
          child: TextField(
            controller: _usernameController,
            style:
                Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
            autofocus: true,
            onSubmitted: (query) {
              _currentUsername = _usernameController.text;
              setState(() {
                _isUsernamePressed = !_isUsernamePressed;
              });
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
        maxLines: 3,
        textInputAction: TextInputAction.done,
        controller: _bioController,
        style:
            Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
        autofocus: true,
        onSubmitted: (query) {
          _currentBio = _bioController.text;
          setState(() {
            _isBioPressed = !_isBioPressed;
          });
        },
        decoration: _textFieldDecoration,
      )
      : Text(
          _currentBio,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
        );

  @override
  void initState() {
    super.initState();
    _userSettingsBloc = UserSettingsBloc();
    _usernameController.text = _currentUsername;
    _nameController.text = _currentName;
    _bioController.text = _currentBio;
  }

  @override
  void dispose() {
    _userSettingsBloc.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
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
      body: _body(),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

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
                        CircleAvatar(
                          backgroundColor: primaryColor,
                          radius: 40.0,
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
                  color: constants.containerColor,
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
                  color: constants.containerColor,
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
                                "You can write anything about you.",
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
              onPressed: () {},
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
}
