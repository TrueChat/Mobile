import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart';
import 'package:true_chat/api/responses/login_response.dart';
import 'package:true_chat/api/responses/response.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/helpers/ensure_visible_when_hidden.dart';
import 'package:true_chat/storage/storage_manager.dart';
import 'package:true_chat/widgets/pages/home_page.dart';

class LogInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LogInPageState();
  }
}

class _LogInPageState extends State<LogInPage> with WidgetsBindingObserver {
  int _currentPressed = 0;
  PageController _controller = PageController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  TextEditingController _regUsernameController = TextEditingController();
  TextEditingController _regPasswordController = TextEditingController();
  TextEditingController _regPassword2Controller = TextEditingController();
  TextEditingController _regEmailController = TextEditingController();

  FocusNode _focusNodeLoginEmail = FocusNode();
  FocusNode _focusNodeLoginPassword = FocusNode();

  FocusNode _focusNodeRegConfirmPassword = FocusNode();
  FocusNode _focusNodeRegEmail = FocusNode();
  FocusNode _focusNodeRegUsername = FocusNode();
  FocusNode _focusNodeRegPassword = FocusNode();

  BuildContext _scaffoldContext;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _regFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            children: <Widget>[
              Text(
                "True ",
                style: Theme.of(context)
                    .textTheme
                    .headline
                    .copyWith(color: primarySwatchColor),
              ),
              Text(
                "chat",
                style: Theme.of(context)
                    .textTheme
                    .headline
                    .copyWith(color: Theme.of(context).accentColor),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        backgroundColor: appBarColor,
      ),
      body: Builder(builder: (context) {
        _scaffoldContext = context;
        return Stack(
          children: <Widget>[
            _body(),
            if (_isLoading)
              Container(
                color: Theme.of(context).backgroundColor.withOpacity(0.9),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor),
                  ),
                ),
              ),
          ],
        );
      }),
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFF262632),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: <Widget>[
            GestureDetector(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Sign In",
                    style: Theme.of(context).textTheme.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                decoration: _decoration(0),
              ),
              onTap: () {
                _menuPressed(0);
              },
            ),
            SizedBox(
              width: 50.0,
            ),
            GestureDetector(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                decoration: _decoration(1),
              ),
              onTap: () {
                _menuPressed(1);
              },
            ),
          ],
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Expanded(
          child: _getPage(),
        )
      ],
      mainAxisSize: MainAxisSize.max,
    );
  }

  BoxDecoration _decoration(int num) {
    Color color;
    if (_currentPressed == num) {
      color = fontColor;
    } else {
      color = Colors.transparent;
    }

    return BoxDecoration(
      border: Border(bottom: BorderSide(color: color, width: 3.0)),
    );
  }

  Widget _getPage() {
    return PageView(
      controller: _controller,
      children: <Widget>[
        _logInPage(),
        _registerPage(),
      ],
      onPageChanged: (index) {
        setState(() {
          _currentPressed = index;
        });
      },
    );
  }

  InputDecoration _textFieldDecoration(String labelText) => InputDecoration(
        contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 35.0),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: fontColor),
            borderRadius: BorderRadius.circular(5.0)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: fontColor),
            borderRadius: BorderRadius.circular(5.0)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: fontColor),
            borderRadius: BorderRadius.circular(5.0)),
        fillColor: fontColor,
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.title,
      );

  Widget _logInPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                width: textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Login required';
                    }
                    if (!loginRegExp.hasMatch(value)) {
                      return 'Wrong Login';
                    }
                    return null;
                  },
                  controller: _emailController,
                  cursorColor: fontColor,
                  focusNode: _focusNodeLoginEmail,
                  decoration: _textFieldDecoration(loginHint),
                  style: Theme.of(context).textTheme.body1,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeLoginEmail, _focusNodeLoginPassword);
                  },
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              Container(
                width: textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password required';
                    }
                    return null;
                  },
                  controller: _passwordController,
                  obscureText: true,
                  cursorColor: fontColor,
                  focusNode: _focusNodeLoginPassword,
                  decoration: _textFieldDecoration(passwordHint),
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term) {
                    _logInPressed();
                  },
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              _logInButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _logInButton() => ButtonTheme(
        height: 40.0,
        child: RaisedButton(
          onPressed: () => _logInPressed(),
          child: Text(
            "Submit",
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
        ),
      );

  Widget _registerPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Form(
          key: _regFormKey,
          child: Column(
            children: <Widget>[
              Container(
                width: textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Emil required';
                    }
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Wrong email';
                    }
                    return null;
                  },
                  controller: _regEmailController,
                  cursorColor: fontColor,
                  decoration: _textFieldDecoration(emailHint),
                  focusNode: _focusNodeRegEmail,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeRegEmail, _focusNodeRegUsername);
                  },
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                width: textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Login required';
                    }
                    if (!loginRegExp.hasMatch(value)) {
                      return 'Wrong login';
                    }
                    return null;
                  },
                  controller: _regUsernameController,
                  focusNode: _focusNodeRegUsername,
                  cursorColor: fontColor,
                  textInputAction: TextInputAction.next,
                  decoration: _textFieldDecoration(loginHint),
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeRegUsername, _focusNodeRegPassword);
                  },
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                width: textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password required';
                    }
                    return null;
                  },
                  controller: _regPasswordController,
                  obscureText: true,
                  focusNode: _focusNodeRegPassword,
                  textInputAction: TextInputAction.next,
                  cursorColor: fontColor,
                  decoration: _textFieldDecoration(passwordHint),
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _focusNodeRegPassword,
                        _focusNodeRegConfirmPassword);
                  },
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                width: textFieldWidth,
                child: EnsureVisibleWhenFocused(
                  focusNode: _focusNodeRegConfirmPassword,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password confirmation required';
                      }
                      if (_regPasswordController.text != value) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    controller: _regPassword2Controller,
                    obscureText: true,
                    focusNode: _focusNodeRegConfirmPassword,
                    cursorColor: fontColor,
                    decoration: _textFieldDecoration(password2Hint),
                    style: Theme.of(context).textTheme.body1,
                    onFieldSubmitted: (term) {
                      _registerPressed();
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              _registerButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerButton() => ButtonTheme(
        height: 40.0,
        child: RaisedButton(
          onPressed: () => _registerPressed(),
          child: Text(
            "Submit",
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
        ),
      );

  _menuPressed(int index) {
    setState(() {
      _currentPressed = index;
      _controller.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  _registerPressed() {
    if (_regFormKey.currentState.validate()) {
      bool isThenReached = false;
      setState(() {
        _isLoading = true;
      });
      String username = _regUsernameController.text;
      String password = _regPasswordController.text;
      String email = _regEmailController.text;

      Api.registration(username: username, email: email, password: password)
          .then((res) async {
        isThenReached = true;
        LoginResponse response = res;
        if (!res.isError) {
          await StorageManager.saveUser(accessToken: response.accessToken);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
        } else {
          setState(() {
            _isLoading = false;
          });
          snackBar(_scaffoldContext, response.message);
        }
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
        if (!isThenReached) {
          snackBar(_scaffoldContext, noInternet);
        }
      });
    }
  }

  _logInPressed() {
    if (_formKey.currentState.validate()) {
      bool isThenReached = false;
      String username, email;
      String password = _passwordController.text;

      if (loginRegExp.hasMatch(_emailController.text)) {
        username = _emailController.text;
      } else {
        email = _emailController.text;
      }
      Future<Response> loginResponse = username == null
          ? Api.login(email: email, password: password)
          : Api.login(username: username, password: password);

      loginResponse.then((res) async {
        isThenReached = true;
        LoginResponse response = res;
        if (!res.isError) {
          await StorageManager.saveUser(accessToken: response.accessToken);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
        } else {
          setState(() {
            _isLoading = false;
          });
          snackBar(_scaffoldContext, response.message);
        }
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
        if (!isThenReached) {
          snackBar(_scaffoldContext, noInternet);
        }
      });
    }
  }
}
