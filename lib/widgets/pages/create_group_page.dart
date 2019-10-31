import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create Group',
          style: Theme.of(context).textTheme.title.copyWith(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor,
      ),
      body: _body(),
      backgroundColor: backgroundColor,
    );
  }

  Widget _body() {
    return Container();
  }
}
