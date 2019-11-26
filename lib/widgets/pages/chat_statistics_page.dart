import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart';
import 'package:true_chat/api/models/chat_statistics.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/widgets/custom_expansion_tile.dart' as custom;

class ChatStatisticsPage extends StatefulWidget {
  const ChatStatisticsPage({this.chatId});

  final int chatId;

  @override
  _ChatStatisticsPageState createState() => _ChatStatisticsPageState();
}

class _ChatStatisticsPageState extends State<ChatStatisticsPage> {
  bool _isLoading = true;
  ChatStatistics _chatStatistics;
  Uint8List _imageBits;
  BuildContext _scaffoldContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Group Statistics',
          style: Theme.of(context).textTheme.title.copyWith(
                color: constants.accentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: constants.appBarColor,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Builder(
              builder: (context) {
                _scaffoldContext = context;
                return _body();
              },
            ),
      backgroundColor: constants.backgroundColor,
    );
  }

  @override
  void initState() {
    super.initState();
    _initChatStatistics();
  }

  Future<void> _initChatStatistics() async {
    try {
      setState(() {
        _isLoading = true;
      });
      _chatStatistics = await api.getChatStatistics(widget.chatId);
      _imageBits = await api.getChatStatisticsPlot(widget.chatId);
      setState(() {
        _isLoading = false;
      });
    } on ApiException catch (e) {
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message);
    }
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
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
                      'Days since creation:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _chatStatistics.daysExists.toString(),
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
                      _chatStatistics.messagesNum.toString(),
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
                    Expanded(
                      child: Text(
                        'Mean words:',
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    Text(
                      _chatStatistics.meanMessWords.toStringAsFixed(2),
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
                    Expanded(
                      child: Text(
                        'Mean characters:',
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    Text(
                      _chatStatistics.meanMessChars.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
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
            child: Image.memory(_imageBits),
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
              'Users',
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
                      'Active users:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _chatStatistics.activeUsersNum.toString(),
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
                      'Inactive users:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _chatStatistics.afkUsersNum.toString(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          ListView.separated(
              itemBuilder: (context, index) => _userStatisticsItem(index),
              separatorBuilder: (context, index) => const SizedBox(
                    height: 8.0,
                  ),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _chatStatistics.members.length)
        ],
      ),
    );
  }

  Widget _userStatisticsItem(int index) {
    final ChatUserStatistics chatUserStatistics =
        _chatStatistics.members[index];
    return custom.ExpansionTile(
      headerBackgroundColor: constants.appBarColor,
      backgroundColor: constants.containerColor,
      iconColor: Colors.white,
      title: Text(
        chatUserStatistics.username,
        style: Theme.of(context)
            .textTheme
            .body1
            .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'days in chat:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      chatUserStatistics.daysIn.toString(),
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
                    Flexible(
                      child: Text(
                        'Activity percentage:',
                        style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      '${chatUserStatistics.messagesPercent.toStringAsFixed(2)}%',
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
                      chatUserStatistics.messagesNum.toString(),
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
                    Expanded(
                      child: Text(
                        'Words:',
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    Text(
                      chatUserStatistics.wordsNum.toString(),
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
                    Expanded(
                      child: Text(
                        'Characters:',
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    Text(
                      chatUserStatistics.charsNum.toString(),
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
                      'Average words in message:',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      chatUserStatistics.meanWord.toString(),
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
                    Expanded(
                      child: Text(
                        'Average characters:',
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    Text(
                      chatUserStatistics.meanChar.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
        ),
      ],
    );
  }
}
