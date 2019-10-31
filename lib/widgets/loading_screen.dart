import 'package:flutter/material.dart';

import 'package:true_chat/helpers/constants.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({this.doWhenReload});

  final Function doWhenReload;
  _LoadingScreenState get state => _LoadingScreenState(doWhenReload: doWhenReload);


  @override
  State<StatefulWidget> createState() => state;
}

class _LoadingScreenState extends State<LoadingScreen> {
  _LoadingScreenState({Function doWhenReload}) {
    _doWhenReload = doWhenReload;
  }

  bool _isConnected = true;

  String _noConnectionMessage = noConnectionMessage;

  Function _doWhenReload;

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
      if (_doWhenReload != null) {
        _doWhenReload();
      }
    });
  }
}
