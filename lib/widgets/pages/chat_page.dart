import 'dart:async';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/message.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/widgets/pages/edit_group_page.dart';
import 'package:true_chat/storage/storage_manager.dart' as storage;

class ChatPage extends StatefulWidget {
  const ChatPage({this.chat});

  final Chat chat;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  List<Message> _messages;

  bool _isLoading = true;

  String _errorMessage;

  String _chatName() {
    if (_chat.isDialog) {
      return '${_chat.name} - dialog';
    }
    return _chat.name;
  }

  String _initText() {
    String initText = '';
    final List<String> chatName = _chat.name.split(' ');
    if (chatName.length == 2) {
      initText = '${chatName[0][0]}${chatName[1][0]}';
    } else {
      initText = '${chatName[0][0]}';
    }
    return initText.toUpperCase();
  }

  Widget _chatTitle() {
    return Row(
      children: <Widget>[
        CircularProfileAvatar(
          '',
          radius: 20.0,
          initialsText: Text(
            _initText(),
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          backgroundColor: constants.backgroundColor,
          borderColor: constants.appBarColor,
        ),
        const SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _chatName(),
                style: Theme.of(context).textTheme.body1.copyWith(
                      color: constants.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${_chat.users.length} members',
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: constants.fontColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Chat _chat;

  @override
  void initState() {
    super.initState();
    _chat = widget.chat;
    _initMessages();
  }

  Future<void> _initMessages() async {
    try {
      await api.getMessages(id: _chat.id).then((messages){
        _messages = messages.reversed.toList();
      }).whenComplete((){
        if(mounted){
          setState(() {
            _isLoading = false;
            _errorMessage = null;
          });
          _initMessages();
        }
      });
    } catch (e) {
      if(e is api.ApiException){
        final api.ApiException error = e;
        setState(() {
          _isLoading = false;
          _errorMessage = error.message;
        });
      }else{
        setState(() {
          _isLoading = false;
          _errorMessage = constants.smthWentWrong;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _chat),
        ),
        title: _chatTitle(),
        backgroundColor: constants.appBarColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () async {
              final Chat result = await Navigator.push(
                context,
                MaterialPageRoute<Chat>(
                  builder: (context) => EditGroupPage(
                    chat: _chat,
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  _chat = result;
                });
              }
            },
          ),
        ],
      ),
      body: _body(),
      backgroundColor: constants.backgroundColor,
    );
  }

  Widget _body() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (_isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
          _chatBody(),
        _sendBar(),
      ],
    );
  }

  Widget _chatBody() {
    return _errorMessage == null
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _messageItem(index);
              },
              separatorBuilder: (context, index) {
                return _messageSeparator(index);
              },
              itemCount: _messages.length,
            ),
          )
        : Expanded(
            child: Center(
              child: Text(
                _errorMessage,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          );
  }

  Widget _messageSeparator(int index) {
    double height = 8.0;
    if (index + 1 < _messages.length) {
      if (_messages[index].user.id != _messages[index + 1].user.id) {
        height = 16.0;
      }
    }
    return SizedBox(
      height: height,
    );
  }

  Widget _messageItem(int index) {
    return FutureBuilder(
      future: storage.getUser(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final User user = snapshot.data;
          final Message message = _messages[index];

          final RegExpMatch match =
              constants.timeRegExp.firstMatch(message.dateCreated);
          String messageTime = match.input.substring(match.start, match.end);
          int messageHours = int.parse(messageTime.substring(0, 2)) + 2;
          String replace;
          if (messageHours >= 24) {
            messageHours -= 24;
            replace = '0$messageHours';
          } else {
            replace = messageHours.toString();
          }

          messageTime = messageTime.replaceRange(0, 2, replace.toString());

          Widget messageWidget;
          if (message.user.id == user.id) {
            messageWidget = Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: constants.appBarColor.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          message.content,
                          style: Theme.of(context).textTheme.body1,
                        ),
                        Text(
                          messageTime,
                          style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            bool isFirstMessage = true;
            if (index - 1 >= 0) {
              if (_messages[index].user.id == _messages[index - 1].user.id) {
                isFirstMessage = false;
              }
            }
            bool isLastMessage = false;
            if (index + 1 < _messages.length) {
              if (_messages[index].user.id != _messages[index + 1].user.id) {
                isLastMessage = true;
              }
            } else {
              isLastMessage = true;
            }
            String name = '';
            String userInitText = '';
            if (message.user.firstName.isNotEmpty) {
              name += '${message.user.firstName} ';
              userInitText += message.user.firstName[0].toUpperCase();
            }
            if (message.user.lastName.isNotEmpty) {
              name += '${message.user.lastName}';
              userInitText += message.user.lastName[0].toUpperCase();
            }
            if (name.isEmpty) {
              name = message.user.username;
              userInitText += message.user.username[0].toUpperCase();
            }
            messageWidget = Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (isFirstMessage)
                    CircularProfileAvatar(
                      '',
                      radius: 20.0,
                      initialsText: Text(
                        userInitText,
                        style: TextStyle(
                            fontSize: userInitText.length == 1 ? 30 : 20,
                            color: Colors.white),
                      ),
                      backgroundColor: constants.appBarColor,
                      borderColor: constants.appBarColor,
                    ),
                  if (isFirstMessage)
                    const SizedBox(
                      width: 8.0,
                    ),
                  if (!isFirstMessage)
                    const SizedBox(
                      width: 48.0,
                    ),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                          color: constants.appBarColor.withOpacity(0.3),
                          borderRadius: BorderRadius.only(
                            topRight: const Radius.circular(12.0),
                            bottomLeft: isLastMessage
                                ? const Radius.circular(12.0)
                                : Radius.zero,
                            bottomRight: const Radius.circular(12.0),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (isFirstMessage)
                              Text(
                                name,
                                style:
                                    Theme.of(context).textTheme.body1.copyWith(
                                          color: constants.accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  message.content,
                                  style: Theme.of(context).textTheme.body1,
                                ),
                                Text(
                                  messageTime,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 48.0,
                  ),
                ],
              ),
            );
          }
          return messageWidget;
        }
        return Container();
      },
    );
  }

  Widget _sendBar() {
    return Container(
      color: constants.appBarColor,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _attachFilePressed,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          const SizedBox(
            width: 8.0,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Your message',
              ),
              style: Theme.of(context).textTheme.body1.copyWith(
                    color: Colors.white,
                  ),
              cursorColor: constants.fontColor,
              onSubmitted: (query) {
                _sendMessagePressed();
              },
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessagePressed,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  void _attachFilePressed() {}

  void _sendMessagePressed() {}
}
