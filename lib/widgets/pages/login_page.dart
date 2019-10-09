import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/helpers/custom_icons.dart';
import 'package:true_chat/helpers/ensure_visible_when_hidden.dart';
import 'package:true_chat/widgets/pages/home_page.dart';

class LogInPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _LogInPageState();
  }

}

class _LogInPageState extends State<LogInPage> with WidgetsBindingObserver{
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
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Row(children: <Widget>[
          Text("True ",style: Theme.of(context).textTheme.headline.copyWith(color: primarySwatchColor),),
          Text("Chat",style: Theme.of(context).textTheme.headline.copyWith(color: Theme.of(context).accentColor),)
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        ),
        ),
        backgroundColor: appBarColor,
      ),
      body: Builder(builder: (context){
        _scaffoldContext = context;
        return Stack(children: <Widget>[
          _body(),
          if(_isLoading) Container(
            color: Theme.of(context).backgroundColor.withOpacity(0.9),
            child: Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
            ),),
          ),
        ],
        );
      }),
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _body(){
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          GestureDetector(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Sign In",style: Theme.of(context).textTheme.title,textAlign: TextAlign.center,),
              ),
              decoration: _decoration(0),

            ),
            onTap: () {
              _menuPressed(0);
            },),
          GestureDetector(child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Sign Up",style: Theme.of(context).textTheme.title,textAlign: TextAlign.center,),
            ),
            decoration: _decoration(1),
          ),
            onTap: () {
              _menuPressed(1);
            },),
        ],
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      Expanded(child: _getPage(),)
    ],
      mainAxisSize: MainAxisSize.max,
    );
  }

  BoxDecoration _decoration(int num) {
    Color color;
    if(_currentPressed == num) {
      color = Colors.white;
    }else {
      color = Colors.transparent;
    }

    return BoxDecoration(
      border: Border(
          bottom: BorderSide(
              color: color,
              width: 2.0
        )
      ),
    );
  }

  Widget _getPage(){
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
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(5.0)
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(5.0)
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(5.0)
    ),
    fillColor: Colors.white,
    labelText: labelText,
    labelStyle: Theme.of(context).textTheme.title,
  );

  Widget _logInPage(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            Container(
              width: textFieldWidth,
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'email required';
                  }
                  if(!emailRegExp.hasMatch(value)){
                    return 'wrong email';
                  }
                  return null;
                },
                controller: _emailController,
                focusNode: _focusNodeLoginEmail,
                textAlign: TextAlign.center,
                decoration: _textFieldDecoration(emailHint),
                style: Theme.of(context).textTheme.body1,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term){
                  _fieldFocusChange(context, _focusNodeLoginEmail, _focusNodeLoginPassword);
                },
              ),
            ),
            SizedBox(height: 30.0,),
            Container(
              width: textFieldWidth,
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'password required';
                  }
                  return null;
                },
                controller: _passwordController,
                obscureText: true,
                textAlign: TextAlign.center,
                focusNode: _focusNodeLoginPassword,
                decoration: _textFieldDecoration(passwordHint),
                style: Theme.of(context).textTheme.body1,
                onFieldSubmitted: (term){
                  _logInPressed();
                },
              ),
            ),
            SizedBox(height: 30.0,),
            _logInButton(),
          ],
          ),
        ),
      ),
    );
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _logInButton() => ButtonTheme(
    height: 40.0,
    child: RaisedButton(
      onPressed: () => _logInPressed(),
      child: Text("Submit",style: Theme.of(context).textTheme.button,),
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)
      ),
    ),
  );


  Widget _registerPage(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Form(
          key: _regFormKey,
          child: Column(children: <Widget>[
            Container(
              width: textFieldWidth,
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'emil required';
                  }
                  if(!emailRegExp.hasMatch(value)){
                    return 'wrong email';
                  }
                  return null;
                },
                controller: _regEmailController,
                textAlign: TextAlign.center,
                decoration: _textFieldDecoration(emailHint),
                focusNode: _focusNodeRegEmail,
                textInputAction: TextInputAction.next,
                style: Theme.of(context).textTheme.body1,
                onFieldSubmitted: (term){
                  _fieldFocusChange(context, _focusNodeRegEmail, _focusNodeRegUsername);
                },
              ),
            ),
            SizedBox(height: 10.0,),
            Container(
              width: textFieldWidth,
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'username required';
                  }
                  if(!usernameRegExp.hasMatch(value)){
                    return 'wrong username';
                  }
                  return null;
                },
                controller: _regUsernameController,
                focusNode: _focusNodeRegUsername,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
                decoration: _textFieldDecoration(regUsernameHint),
                style: Theme.of(context).textTheme.body1,
                onFieldSubmitted: (term){
                  _fieldFocusChange(context, _focusNodeRegUsername, _focusNodeRegPassword);
                },
              ),
            ),
            SizedBox(height: 10.0,),
            Container(
              width: textFieldWidth,
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'password required';
                  }
                  return null;
                },
                controller: _regPasswordController,
                obscureText: true,
                focusNode: _focusNodeRegPassword,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.center,
                decoration: _textFieldDecoration(passwordHint),
                style: Theme.of(context).textTheme.body1,
                onFieldSubmitted: (term){
                  _fieldFocusChange(context, _focusNodeRegPassword, _focusNodeRegConfirmPassword);
                },
              ),
            ),
            SizedBox(height: 10.0,),
            Container(
              width: textFieldWidth,
              child: EnsureVisibleWhenFocused(
                focusNode: _focusNodeRegConfirmPassword,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'password confirmation required';
                    }
                    if(_regPasswordController.text != value){
                      return 'passwords do not match';
                    }
                    return null;
                  },
                  controller: _regPassword2Controller,
                  obscureText: true,
                  focusNode: _focusNodeRegConfirmPassword,
                  textAlign: TextAlign.center,
                  decoration: _textFieldDecoration(password2Hint),
                  style: Theme.of(context).textTheme.body1,
                  onFieldSubmitted: (term){
                    _registerPressed();
                  },
                ),
              ),
            ),
            SizedBox(height: 30.0,),
            _registerButton()
          ],),
        ),
      ),
    );
  }

  Widget _registerButton() => ButtonTheme(
    height: 40.0,
    child: RaisedButton(
      onPressed: () => _registerPressed(),
      child: Text("Register",style: Theme.of(context).textTheme.button,),
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)
      ),
    ),
  );

  _registerPressed(){
    if(_regFormKey.currentState.validate()) {
      bool _isThenReached = false;
      setState(() {
        _isLoading = true;
      });
      String username = _regUsernameController.text;
      String password = _regPasswordController.text;
      String email = _regEmailController.text;

    }
  }

  _menuPressed(int index){
    setState(() {
      _currentPressed = index;
      _controller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  _logInPressed(){
    if(_formKey.currentState.validate()) {
      bool _isThenReached = false;
      setState(() {
        _isLoading = true;
        Future.delayed(Duration(seconds: 2),
              () {
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                    HomePage()), (Route<dynamic> route) => false);
              },);
      });
      String username = _emailController.text;
      String password = _passwordController.text;
    }
  }
}