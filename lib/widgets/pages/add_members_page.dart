import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart' as constants;

class AddMembersPage extends StatefulWidget {

  const AddMembersPage({@required this.chatId}) : assert(chatId != null);

  final int chatId;

  @override
  _AddMembersPageState createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          constants.addMembersPageTitle,
          style: Theme.of(context).textTheme.title.copyWith(
            color: constants.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: constants.appBarColor,
      ),
      body: _body(),
      backgroundColor: constants.backgroundColor,
    );
  }

  Widget _body() {
    return Container();
  }
}
