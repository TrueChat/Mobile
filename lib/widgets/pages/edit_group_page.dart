import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/helpers/constants.dart' as constants;

class EditGroupPage extends StatefulWidget {
  const EditGroupPage({@required this.chat}) : assert(chat != null);

  final Chat chat;

  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  String _newChatName;
  String _newChatDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          constants.editGroupPageTitle,
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
