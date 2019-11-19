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
import 'package:true_chat/widgets/pages/user_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({this.chat,this.isChatCreated});

  final Chat chat;
  final bool isChatCreated;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  List<Message> _messages;

  bool _isLoading = true;

  String _errorMessage;

  User _currentUser;

  BuildContext _scaffoldContext;

  bool _isEditing = false;

  String _chatName() {
    if (_chat.isDialog) {
      return '${_chat.name} - dialog';
    }
    return _chat.name;
  }

  String _initText() {
    String initText = '';
    if (_chat.isDialog) {
      final User user = _chat.users[0];
      if (user.firstName.isNotEmpty) {
        initText += user.firstName[0];
      }
      if (user.lastName.isNotEmpty) {
        initText += user.lastName[0];
      }
      if (initText.isEmpty) {
        initText = user.username[0];
      }
    } else {
      final List<String> chatName = _chat.name.split(' ');
      if (chatName.length == 2) {
        initText = '${chatName[0][0]}${chatName[1][0]}';
      } else {
        initText = '${chatName[0][0]}';
      }
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
            style: TextStyle(fontSize: 20, color: Colors.white),
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

  Widget _dialogTitle() {
    return GestureDetector(
      onTap: () {
        constants.goToPage(
          context,
          UserPage(
            username: _chat.users[0].username,
          ),
        );
      },
      child: Row(
        children: <Widget>[
          CircularProfileAvatar(
            '',
            radius: 20.0,
            initialsText: Text(
              _initText(),
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            backgroundColor: constants.backgroundColor,
            borderColor: constants.appBarColor,
          ),
          const SizedBox(
            width: 16.0,
          ),
          Text(
            _dialogName(_chat),
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: constants.fontColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Chat _chat;

  @override
  void initState() {
    super.initState();
    _chat = widget.chat;
    _initData();
  }

  Future<void> _initData() async {
    try {
      _currentUser ??= await storage.getUser();
      await api.getMessages(id: _chat.id).then((messages) {
        _messages = messages.reversed.toList();
      }).whenComplete(() {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
          });
          _initData();
        }
      });
    } catch (e) {
      if (e is api.ApiException) {
        final api.ApiException error = e;
        setState(() {
          _isLoading = false;
          _errorMessage = error.message;
        });
      } else {
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
        title: _chat.isDialog ? _dialogTitle() : _chatTitle(),
        backgroundColor: constants.appBarColor,
        actions: <Widget>[
          if (!_chat.isDialog)
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
      body: Builder(
        builder: (context) {
          _scaffoldContext = context;
          return _body();
        },
      ),
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
          Flexible(
            child: _chatBody(),
          ),
        _sendBar(),
      ],
    );
  }

  Widget _chatBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _errorMessage == null
          ? ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _messageItem(index);
              },
              separatorBuilder: (context, index) {
                return _messageSeparator(index);
              },
              itemCount: _messages.length,
            )
          : Expanded(
              child: Center(
                child: Text(
                  _errorMessage,
                  style: Theme.of(context).textTheme.title,
                ),
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

  String _dialogName(Chat chat) {
    String name = '';
    final User user = chat.users[0];
    if (user.firstName.isNotEmpty) {
      name += '${user.firstName} ';
    }
    if (user.lastName.isNotEmpty) {
      name += '${user.lastName}';
    }
    if (name.isEmpty) {
      name = user.username;
    }
    return name;
  }

  Widget _messageItem(int index) {
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
    if (message.user.id == _currentUser.id) {
      messageWidget = GestureDetector(
        onTap: () => _messagePressed(message),
        child: Align(
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
            if (isFirstMessage && !_chat.isDialog)
              GestureDetector(
                child: CircularProfileAvatar(
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
                onTap: () {
                  constants.goToPage(
                    context,
                    UserPage(
                      username: message.user.username,
                    ),
                  );
                },
              ),
            if (isFirstMessage && !_chat.isDialog)
              const SizedBox(
                width: 8.0,
              ),
            if (!isFirstMessage && !_chat.isDialog)
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
                      if (isFirstMessage && !_chat.isDialog)
                        Text(
                          name,
                          style: Theme.of(context).textTheme.body1.copyWith(
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

  void _messagePressed(Message message) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: constants.backgroundColor,
            elevation: 0.0,
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  _editMessage(message);
                },
                child: Text(
                  'Edit',
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  _deleteMessage(message.id);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Delete',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        color: Colors.red,
                      ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _deleteMessage(int id) async {
    try {
      await api.deleteMessage(id: id);
    } catch (e) {
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message);
    }
  }

  Message _messageToEdit;

  void _editMessage(Message message) {
    _messageController.text = message.content;
    Navigator.of(context).pop();
    setState(() {
      _isEditing = true;
    });
    _messageToEdit = message;
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
                _sendPressed();
              },
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          IconButton(
            icon: _isEditing ? Icon(Icons.done) : Icon(Icons.send),
            onPressed: () {
              _sendPressed();
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  void _attachFilePressed() {}

  Future<void> _sendPressed() async {
    try {
      if(widget.isChatCreated != null){
        _chat = await api.createDialog(username: _chat.users[0].username);
      }
      if (_isEditing) {
        if (_messageController.text.isEmpty) {
          setState(() {
            _isEditing = false;
          });
          return;
        }
        await api.editMessage(
            id: _messageToEdit.id, message: _messageController.text);
        setState(() {
          _isEditing = false;
        });
      } else {
        await api.sendMessage(_messageController.text, _chat.id);
      }
      _messageController.clear();
    } catch (e) {
      if (e is api.ApiException) {
        final api.ApiException error = e;
        constants.snackBar(_scaffoldContext, error.message, Colors.red);
      } else {
        constants.snackBar(_scaffoldContext, e.toString(), Colors.red);
      }
    }
  }
}
