import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:true_chat/blocs/bloc.dart';
import 'package:true_chat/blocs/login/login_bloc.dart';
import 'package:true_chat/blocs/login/login_event.dart';
import 'package:true_chat/blocs/login/login_state.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/helpers/ensure_visible_when_hidden.dart';
import 'package:true_chat/widgets/pages/home_page.dart';

class LogInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LogInPageState();
  }
}

class _LogInPageState extends State<LogInPage> with WidgetsBindingObserver {
  LoginBloc _loginBloc;
  LoginPageControllerBloc _loginPageControllerBloc;

  final PageController _controller = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _regUsernameController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regPassword2Controller = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();

  final FocusNode _focusNodeLoginEmail = FocusNode();
  final FocusNode _focusNodeLoginPassword = FocusNode();

  final FocusNode _focusNodeRegConfirmPassword = FocusNode();
  final FocusNode _focusNodeRegEmail = FocusNode();
  final FocusNode _focusNodeRegUsername = FocusNode();
  final FocusNode _focusNodeRegPassword = FocusNode();

  BuildContext _scaffoldContext;

  final _formKey = GlobalKey<FormState>();
  final _regFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc();
    _loginPageControllerBloc = LoginPageControllerBloc();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    _regUsernameController.dispose();
    _regPasswordController.dispose();
    _regPassword2Controller.dispose();
    _regEmailController.dispose();
    _controller.dispose();
    _loginBloc.dispose();
    _loginPageControllerBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => _loginBloc,
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
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginStateError) {
              constants.snackBar(_scaffoldContext, state.message, Colors.red);
            } else if (state is LoginStateSuccess) {
              Navigator.of(context).pushAndRemoveUntil<void>(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
            } else if (state is RegisterStateSuccess) {
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: const Text(
                    'Werify your email to log in',
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(minutes: 5),
                  action: SnackBarAction(
                    label: 'Ok',
                    onPressed: () {
                      Scaffold.of(_scaffoldContext).hideCurrentSnackBar();
                    },
                  )));
              _loginPageControllerBloc
                  .dispatch(const PageChange(tab: LoginTab.signIn));
            }
          },
          child: Builder(builder: (context) {
            _scaffoldContext = context;
            return BlocBuilder<LoginBloc, LoginState>(
                bloc: _loginBloc,
                builder: (context, state) {
                  return Stack(
                    children: <Widget>[
                      _body(),
                      if (state is LoginStateLoading)
                        Container(
                          color: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.9),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).accentColor),
                            ),
                          ),
                        ),
                    ],
                  );
                });
          }),
        ),
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF262632),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 20.0,
        ),
        BlocBuilder<LoginPageControllerBloc, LoginTab>(
            bloc: _loginPageControllerBloc,
            builder: (context, state) {
              return topMenuRow();
            }),
        Expanded(
          child: _getPage(),
        )
      ],
      mainAxisSize: MainAxisSize.max,
    );
  }

  Widget topMenuRow() => Row(
        children: <Widget>[
          GestureDetector(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
              ),
              decoration: _decoration(LoginTab.signIn),
            ),
            onTap: () {
              _menuPressed(0, LoginTab.signUp);
            },
          ),
          const SizedBox(
            width: 50.0,
          ),
          GestureDetector(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Sign Up',
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
              ),
              decoration: _decoration(LoginTab.signUp),
            ),
            onTap: () {
              _menuPressed(1, LoginTab.signIn);
            },
          ),
        ],
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
      );

  BoxDecoration _decoration(LoginTab tab) {
    Color color;
    if (tab != _loginPageControllerBloc.currentState) {
      color = constants.fontColor;
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
        _loginPageControllerBloc.dispatch(
            PageChange(tab: index == 0 ? LoginTab.signUp : LoginTab.signIn));
      },
    );
  }

  void _menuPressed(int index, LoginTab tab) {
    _loginPageControllerBloc.dispatch(PageChange(tab: tab));
    _controller.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  InputDecoration _textFieldDecoration(String labelText) => InputDecoration(
        contentPadding:
            const EdgeInsets.only(left: 10.0, right: 10.0, top: 35.0),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: constants.fontColor),
            borderRadius: BorderRadius.circular(5.0)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: constants.fontColor),
            borderRadius: BorderRadius.circular(5.0)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: constants.fontColor),
            borderRadius: BorderRadius.circular(5.0)),
        fillColor: constants.fontColor,
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
                width: constants.textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Login required';
                    }
                    if (!constants.loginRegExp.hasMatch(value)) {
                      return 'Wrong Login';
                    }
                    return null;
                  },
                  controller: _emailController,
                  cursorColor: constants.fontColor,
                  focusNode: _focusNodeLoginEmail,
                  decoration: _textFieldDecoration(constants.loginHint),
                  style: Theme.of(context).textTheme.body1,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeLoginEmail, _focusNodeLoginPassword);
                  },
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              Container(
                width: constants.textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password required';
                    }
                    return null;
                  },
                  controller: _passwordController,
                  obscureText: true,
                  cursorColor: constants.fontColor,
                  focusNode: _focusNodeLoginPassword,
                  decoration: _textFieldDecoration(constants.passwordHint),
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term) {
                    _logInPressed();
                  },
                ),
              ),
              const SizedBox(
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
            'Submit',
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
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
                width: constants.textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Emil required';
                    }
                    if (!constants.emailRegExp.hasMatch(value)) {
                      return 'Wrong email';
                    }
                    return null;
                  },
                  controller: _regEmailController,
                  cursorColor: constants.fontColor,
                  decoration: _textFieldDecoration(constants.emailHint),
                  focusNode: _focusNodeRegEmail,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeRegEmail, _focusNodeRegUsername);
                  },
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Container(
                width: constants.textFieldWidth,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Login required';
                    }
                    if (!constants.loginRegExp.hasMatch(value)) {
                      return 'Wrong login';
                    }
                    return null;
                  },
                  controller: _regUsernameController,
                  focusNode: _focusNodeRegUsername,
                  cursorColor: constants.fontColor,
                  textInputAction: TextInputAction.next,
                  decoration: _textFieldDecoration(constants.loginHint),
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeRegUsername, _focusNodeRegPassword);
                  },
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Container(
                width: constants.textFieldWidth,
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
                  cursorColor: constants.fontColor,
                  decoration: _textFieldDecoration(constants.passwordHint),
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _focusNodeRegPassword,
                        _focusNodeRegConfirmPassword);
                  },
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Container(
                width: constants.textFieldWidth,
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
                    cursorColor: constants.fontColor,
                    decoration: _textFieldDecoration(constants.password2Hint),
                    style: Theme.of(context).textTheme.body1,
                    onFieldSubmitted: (term) {
                      _registerPressed();
                    },
                  ),
                ),
              ),
              const SizedBox(
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
            'Submit',
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
        ),
      );

  void _logInPressed() {
    if (_formKey.currentState.validate()) {
      _loginBloc.dispatch(LoginSubmitted(
          login: _emailController.text, password: _passwordController.text));
    }
  }

  void _registerPressed() {
    if (_regFormKey.currentState.validate()) {
      final username = _regUsernameController.text;
      final password = _regPasswordController.text;
      final email = _regEmailController.text;

      _loginBloc.dispatch(
        RegisterSubmitted(
          username: username,
          email: email,
          password: password,
        ),
      );
    }
  }
}
