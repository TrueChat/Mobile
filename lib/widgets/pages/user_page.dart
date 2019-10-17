import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/widgets/pages/user_settings_page.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "User",
            style: TextStyle(
                fontSize: 28.0,
                color: primarySwatchColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: appBarColor,
      ),
      body: _body(),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _body() {
    return Center(
      child: RaisedButton(
        child: Text("Settings"),
        onPressed: () {
          goToPage(context, UserSettingsPage());
        },
      ),
    );
  }
}
