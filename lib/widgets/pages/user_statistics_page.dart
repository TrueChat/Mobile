import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart' as constants;

class UserStatisticsPage extends StatefulWidget {
  @override
  _UserStatisticsPageState createState() => _UserStatisticsPageState();
}

class _UserStatisticsPageState extends State<UserStatisticsPage> {
  bool _isLoading = true;
  BuildContext _scaffoldContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'User Statistics',
          style: TextStyle(
              fontSize: 28.0,
              color: constants.accentColor,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: constants.appBarColor,
      ),
      body: Builder(builder: (context) {
        _scaffoldContext = context;
        return _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _body();
      }),
      backgroundColor: constants.backgroundColor,
    );
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {

  }

  Widget _body() {
    return Container();
  }
}
