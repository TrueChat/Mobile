import 'package:flutter/material.dart';

import 'package:true_chat/helpers/constants.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({this.doWhenReload}){
    _state = _LoadingScreenState();
  }

  _LoadingScreenState _state;
  final Function doWhenReload;

  void noConnection({String message}){
    _state.noConnection(message: message);
  }

  @override
  State<StatefulWidget> createState() => _state;
}

class _LoadingScreenState extends State<LoadingScreen> {
  _LoadingScreenState();

  bool _isConnected = true;

  String _noConnectionMessage = noConnectionMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isConnected ? _loading : _noConnection(),
    );
  }

  final Widget _loading = Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
        ),
        const SizedBox(
          height: 20.0,
        ),
        const Text('Loading')
      ],
    ),
  );

  Widget _noConnection() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.error),
                const SizedBox(
                  width: 10.0,
                ),
                Text(_noConnectionMessage),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            const SizedBox(
              height: 10.0,
            ),
            InkWell(
              child: Text(
                'Reload',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () => _reloadPressed(),
            ),
          ],
        ),
      );

  void noConnection({String message}) {
    setState(() {
      _noConnectionMessage = message ?? _noConnectionMessage;
      _isConnected = false;
    });
  }

  void _reloadPressed() {
    setState(() {
      _isConnected = true;
      if (widget.doWhenReload != null) {
        widget.doWhenReload();
      }
    });
  }
}
