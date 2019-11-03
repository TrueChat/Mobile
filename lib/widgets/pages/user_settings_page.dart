import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/user_response.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/widgets/loading_screen.dart';

class UserSettingsPage extends StatefulWidget {

  const UserSettingsPage({@required this.user}) : assert(user != null);

  final User user;

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  LoadingScreen _loadingScreen;

  bool _isNamePressed = false;
  bool _isUsernamePressed = false;
  bool _isBioPressed = false;
  bool _isLoading = false;

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

  User _user;

  final InputDecoration _textFieldDecoration = InputDecoration(
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: constants.accentColor, width: 2.0)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: constants.accentColor, width: 2.0)));

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
    _user = widget.user;
    _updateUserData();
  }

  void _updateUserData() {
    _currentName = _user.firstName == null ||
        _user.firstName == ''
        ? constants.yourName
        : _user.firstName;
    _currentSurname =
    _user.lastName == null || _user.lastName == ''
            ? constants.yourSurName
            : _user.lastName;
    _currentBio =
    _user.about == null || _user.about == ''
            ? constants.literallyAnything
            : _user.about;
    _currentUsername = _user.username;
    _usernameController.text = _currentUsername;
    _nameController.text = _currentName;
    _surNameController.text = _currentSurname;
    _bioController.text = _currentBio;
  }

  Future<void> _initUserData() async {
    bool connection = await constants.checkConnection();
    if (connection) {
      connection = await constants.checkConnection(
          connectionUrl: 'true-chat.herokuapp.com');
      if (connection) {
        final response = await api.getCurrentUser();
        if (response.isError) {
          _loadingScreen.noConnection(message: response.message);
        } else {
          final UserResponse userResponse = response;
          setState(() {
            _user = userResponse.user;
            _updateUserData();
            _isLoading = false;
          });
        }
      } else {
        _loadingScreen.noConnection(message: constants.noConnectionToServer);
      }
    } else {
      _loadingScreen.noConnection();
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
                color: constants.accentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: constants.appBarColor,
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

  Widget _body() {
    final _initialText =
        '${_nameController.text[0]}${_surNameController.text[0]}'.toUpperCase();
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
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
                            _initialText,
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                          backgroundColor: constants.appBarColor,
                          borderColor: constants.appBarColor,
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
                            color: constants.fontColor,
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
                                  _usernameWidget()
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: constants.fontColor,
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
                            color: constants.fontColor,
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
              fillColor: constants.accentColor,
              padding: const EdgeInsets.all(5.0),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitPressed() async {
    setState(() {
      _isLoading = true;
    });
    final connection = await constants.checkConnection();
    if (connection) {
      String name;
      String bio;
      String surname;
      if (_currentName != constants.yourName) {
        name = _currentName;
      }
      if (_currentBio != constants.literallyAnything) {
        bio = _currentBio;
      }
      if (_currentSurname != constants.yourSurName) {
        surname = _currentSurname;
      }
      api
          .changeUserData(
              name: name,
              surname: surname,
              bio: bio,
              username: _currentUsername)
          .then((response) {
        if (response.isError) {
          constants.snackBar(_scaffoldContext, response.message, Colors.red);
        } else {
          setState(() {
            _isLoading = false;
          });
          constants.snackBar(_scaffoldContext, response.message, Colors.green);
        }
      });
    } else {
      _loadingScreen.noConnection();
    }
  }
}
