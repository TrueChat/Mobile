import 'dart:async';
import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/message.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/widgets/pages/chat_edit_page.dart';
import 'package:true_chat/storage/storage_manager.dart' as storage;
import 'package:true_chat/widgets/pages/image_page.dart';
import 'package:true_chat/widgets/pages/user_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ChatPage extends StatefulWidget {
  const ChatPage({this.chat, this.isChatCreated});

  final Chat chat;
  final bool isChatCreated;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  List<Message> _messages;

  bool _isLoading = true;

  int _index = 0;

  Chat _chat;

  String _errorMessage;

  User _currentUser;

  final ScrollController _scrollController = ScrollController();

  BuildContext _scaffoldContext;

  bool _isEditing = false;

  String _initText() {
    String initText = '';
    if (_chat.isDialog) {
      final User user = _chat.users[_index].id == _currentUser.id
          ? _chat.creator
          : _chat.users[_index];
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
    return GestureDetector(
      onTap: () {
        constants.goToPage(
          context,
          EditChatPage(
            chat: _chat,
          ),
        );
      },
      child: Row(
        children: <Widget>[
          CircularProfileAvatar(
            _chat.images.isEmpty ? '' : _chat.images[0].imageURL,
            cacheImage: true,
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
                  _chat.name,
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
      ),
    );
  }

  Widget _dialogTitle() {
    String avatarUrl;
    if(_chat.isDialog){
      final User user =
      _chat.users[0].id == _currentUser.id ? _chat.creator : _chat.users[0];
      avatarUrl = user.images.isEmpty ? '' : user.images[0].imageURL;
    }else{
      avatarUrl = _chat.images.isEmpty ? '' : _chat.images[0].imageURL;
    }
    return GestureDetector(
      onTap: () {
        constants.goToPage(
          context,
          UserPage(
            username: _chat.users[_index].id == _currentUser.id
                ? _chat.creator.username
                : _chat.users[_index].username,
          ),
        );
      },
      child: Row(
        children: <Widget>[
          CircularProfileAvatar(
            avatarUrl,
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

  @override
  void initState() {
    super.initState();
    _chat = widget.chat;
    _initData();
    _currentUser = _chat.creator;
    storage.getUser().then((user) {
      setState(() {
        _currentUser = user;
      });
    });
    if (_chat.users.length > 1) {
      _index = 1;
    }
  }

  Future<void> _initData() async {
    try {
      await api.getMessages(id: _chat.id).then((messages) {
        int length = -1;
        if (_messages != null) {
          length = _messages.length;
        }
        _messages = messages;
        if (_messages.length > length) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0.0);
          }
        }
        _errorMessage = null;
      }).whenComplete(() {
        if (mounted) {
          setState(() {
            _isLoading = false;
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
          _errorMessage = e.toString();
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
                    builder: (context) => EditChatPage(
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
          _chatBody(),
        _sendBar(),
      ],
    );
  }

  Widget _chatBody() {
    return Flexible(
      child: _errorMessage == null
          ? ListView.separated(
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              reverse: true,
              controller: _scrollController,
              itemBuilder: (context, index) {
                return _messageItem(index);
              },
              separatorBuilder: (context, index) {
                return _messageSeparator(index);
              },
              itemCount: _messages.length,
            )
          : Center(
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

  String _dialogName(Chat chat) {
    String name = '';
    final User user = chat.users[_index].id == _currentUser.id
        ? _chat.creator
        : chat.users[_index];
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
                    if (message.images.isNotEmpty)
                      _imagesList(message),
                    const SizedBox(height: 8.0,),
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
            if (isLastMessage && !_chat.isDialog)
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
            if (isLastMessage && !_chat.isDialog)
              const SizedBox(
                width: 8.0,
              ),
            if (!isLastMessage && !_chat.isDialog)
              const SizedBox(
                width: 48.0,
              ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: constants.appBarColor.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(12.0),
                      bottomLeft: isFirstMessage
                          ? const Radius.circular(12.0)
                          : Radius.zero,
                      bottomRight: const Radius.circular(12.0),
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (isLastMessage && !_chat.isDialog)
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
                          if(message.images.isEmpty)
                            Text(
                              message.content,
                              style: Theme.of(context).textTheme.body1,
                            ),
                          if (message.images.isNotEmpty)
                            _imagesList(message),
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

  Widget _imagesList(Message message){
    return ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) => InkWell(
          onTap: () => _imagePressed(message,index),
          onLongPress: () => message.user.id == _currentUser.id ? _imageLongPressed(message,index) : null,
          child: Hero(
            tag: 'pk ${message.images[index].pk}',
            child: Image.network(
                message.images[index].imageURL),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(
          height: 10.0,
        ),
        itemCount: message.images.length);
  }

  void _messagePressed(Message message) {
    if(message.images.isEmpty){
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
  }

  void _imagePressed(Message message,int index){
    constants.goToPage(context, ImagePage(imageDTO: message.images[index],));
  }

  void _imageLongPressed(Message message,int index){
    showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: constants.backgroundColor,
            elevation: 0.0,
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  _deleteImage(message,index);
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

  Future<void> _deleteImage(Message message,int index) async{
    try {
      if(message.images.length == 1){
        await api.deleteMessage(id: message.id);
      }else{
        await api.deleteImage(imageId: message.images[index].pk);
      }
    } catch (e) {
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message, Colors.red);
    }
  }

  Future<void> _deleteMessage(int id) async {
    try {
      await api.deleteMessage(id: id);
    } catch (e) {
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message, Colors.red);
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
            icon: _isEditing ? Icon(Icons.close) : Icon(Icons.attach_file),
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

  Future<void> _attachFilePressed() async {
    if (_isEditing) {
      setState(() {
        _messageController.clear();
        _isEditing = false;
      });
    } else {
      final File image =
          await ImagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        try{
          final Message message =
          await api.sendMessage(p.basename(image.path), _chat.id);
          await api.sendImage(image, message.id);
        }on api.ApiException catch(e){
          constants.snackBar(_scaffoldContext, e.message,Colors.red);
        }
      }
    }
  }

  Future<void> _sendPressed() async {
    final String message = _messageController.text.trim();
    try {
      _messageController.clear();
      if (widget.isChatCreated != null) {
        _chat = await api.createDialog(username: _chat.users[0].username);
      }
      if (_isEditing) {
        if (message.isEmpty) {
          setState(() {
            _isEditing = false;
          });
          return;
        }
        await api.editMessage(id: _messageToEdit.id, message: message);
        setState(() {
          _isEditing = false;
        });
      } else {
        if (message.isNotEmpty) {
          await api.sendMessage(message, _chat.id);
        }
      }
    } catch (e) {
      if (e is api.ApiException) {
        final api.ApiException error = e;
        constants.snackBar(_scaffoldContext, error.message, Colors.red);
      } else {
        constants.snackBar(_scaffoldContext, e.toString(), Colors.red);
      }
      _messageController.text = message;
    }
  }
}
