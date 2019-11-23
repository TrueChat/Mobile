import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:true_chat/api/models/user_statistics.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/api/api.dart' as api;

class UserStatisticsPage extends StatefulWidget {
  @override
  _UserStatisticsPageState createState() => _UserStatisticsPageState();
}

class _UserStatisticsPageState extends State<UserStatisticsPage> {
  bool _isLoading = true;
  BuildContext _scaffoldContext;

  UserStatistics _userStatistics;

  Uint8List _usedWordsPlot;

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
    try {
      setState(() {
        _isLoading = true;
      });
      _userStatistics = await api.getUserStatistics();
      _usedWordsPlot = await api.getUserStatisticsPlot();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message, Colors.red);
    }
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 8.0,
          ),
          Container(
            color: constants.appBarColor,
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'Chats',
              style: Theme.of(context).textTheme.body1.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          Container(
            color: constants.containerColor,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Number of chats:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.chatsNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Dialogs:',
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.dialogsNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Groups:',
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.groupsNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Container(
            color: constants.appBarColor,
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'Activity',
              style: Theme.of(context).textTheme.body1.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          Container(
            color: constants.containerColor,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Days since registration:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.daysWith.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Total number of messages:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.messagesNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Words:',
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.wordsNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Characters:',
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.charsNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Container(
            color: constants.appBarColor,
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'Active period',
              style: Theme.of(context).textTheme.body1.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          Container(
            color: constants.containerColor,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Most active period:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Flexible(
                      child: Text(
                        _userStatistics.activePeriod,
                        style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Messages this period:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.actMessagesNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Words:',
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.actWordsNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Characters:',
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _userStatistics.actCharsNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Container(
            color: constants.appBarColor,
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'Most used words',
              style: Theme.of(context).textTheme.body1.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          Container(
            color: constants.containerColor,
            child: Image.memory(_usedWordsPlot),
          ),
        ],
      ),
    );
  }
}
