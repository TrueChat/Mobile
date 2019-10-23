import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/widgets/pages/login_page.dart';
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
                color: accentColor,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RaisedButton(
            child: Text("Settings"),
            onPressed: () {
              goToPage(context, UserSettingsPage());
            },
          ),
          SizedBox(height: 10.0,),
          RaisedButton(
            child: Text("Logout"),
            onPressed: () async{
              Api.logout().whenComplete((){
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LogInPage()),
                        (Route<dynamic> route) => false);
              });
            },
          ),
        ],
      ),
    );
  }
}
