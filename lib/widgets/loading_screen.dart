import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart';

class LoadingScreen extends StatefulWidget{

  Function _doWhenReload;
  _LoadingScreenState _loadingScreenState;
  _LoadingScreenState get state => _loadingScreenState;

  LoadingScreen({doWhenReload}){
    _doWhenReload = doWhenReload;
  }

  @override
  State<StatefulWidget> createState() {
    _loadingScreenState = _doWhenReload == null ? _LoadingScreenState()
        : _LoadingScreenState(doWhenReload: _doWhenReload);
    return _loadingScreenState;
  }
}

class _LoadingScreenState extends State<LoadingScreen>{
  bool _isConnected = true;

  String _noConnectionMessage = noConnectionMessage;

  Function _doWhenReload;

  _LoadingScreenState({Function doWhenReload}){
    _doWhenReload = doWhenReload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: _isConnected ? _loading : _noConnection(),
    );
  }

  Widget _loading = Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              accentColor),
        ),
        SizedBox(height: 20.0,),
        Text("Loading")
      ],
    ),
  );

  Widget _noConnection() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(children: <Widget>[
          Icon(Icons.error),
          SizedBox(width: 10.0,),
          Text(_noConnectionMessage),
        ],
        mainAxisAlignment: MainAxisAlignment.center,),
        SizedBox(height: 10.0,),
        InkWell(
          child: Text("Reload",style: TextStyle(color: Colors.blue),),
          onTap: () => _reloadPressed(),
        ),
      ],
    ),
  );

  noConnection({String message}){
    setState(() {
      _noConnectionMessage = message ?? _noConnectionMessage;
      _isConnected = false;
    });
  }

  _reloadPressed(){
    setState(() {
      _isConnected = true;
      if(_doWhenReload != null){
        _doWhenReload();
      }
    });
  }
}