import 'dart:async';

import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart';

class NoConnectionEvent {
  NoConnectionEvent({this.message});

  final String message;
}

const _noConnectionMessage = 'No internet connection';

class LoadingScreen extends StatefulWidget {
  LoadingScreen(
      {this.doWhenReload});

  final Function doWhenReload;

  final _controller = StreamController<NoConnectionEvent>.broadcast();

  void noConnection({String message}) {
    _controller.sink.add(NoConnectionEvent(message: message));
  }

  @override
  State<StatefulWidget> createState() {
    return _LoadingScreenState(_controller.stream);
  }
}

class _LoadingScreenState extends State<LoadingScreen> {
  _LoadingScreenState(this._stream) {
    _stream.listen((event) {
      if(mounted){
        noConnection(message: event.message);
      }
    });
  }


  @override
  void dispose() {
    if(!mounted){
      widget._controller.close();
    }
    super.dispose();
  }

  final Stream<NoConnectionEvent> _stream;

  bool _isConnected = true;

  String _noConnectionText = _noConnectionMessage;

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
                Text(_noConnectionText),
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
      _noConnectionText = message ?? _noConnectionText;
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
