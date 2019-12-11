import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/edit_group_response.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/widgets/pages/chat_statistics_page.dart';
import 'package:true_chat/widgets/pages/search_members_page.dart';
import 'package:true_chat/widgets/custom_popup_menu.dart' as custom_popup;
import 'package:true_chat/widgets/pages/user_page.dart';
import 'package:true_chat/storage/storage_manager.dart' as storage_manager;
import 'package:true_chat/api/api.dart' as api;

class EditChatPage extends StatefulWidget {
  const EditChatPage({@required this.chat}) : assert(chat != null);

  final Chat chat;

  @override
  _EditChatPageState createState() => _EditChatPageState();
}

class _EditChatPageState extends State<EditChatPage> {
  final _chatNameController = TextEditingController();
  final _chatDescriptionController = TextEditingController();

  bool _isYourChat = false;

  List<User> _groupMembers;

  bool _isLoading = false;

  Chat _changedChat;

  User _currentUser;

  BuildContext _scaffoldContext;

  String _initText = '';

  @override
  void initState() {
    super.initState();
    _chatNameController.text = widget.chat.name;
    _chatDescriptionController.text = widget.chat.description;
    _groupMembers = widget.chat.users;
  }

  Future<bool> _checkYourChat() async {
    _currentUser = await storage_manager.getUser();
    return _currentUser.id == widget.chat.creator.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _changedChat);
          },
        ),
        title: Text(
          constants.editGroupPageTitle,
          style: Theme.of(context).textTheme.title.copyWith(
                color: constants.accentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () => constants.goToPage(
              context,
              ChatStatisticsPage(
                chatId: widget.chat.id,
              ),
            ),
          ),
        ],
        backgroundColor: constants.appBarColor,
      ),
      body: Builder(builder: (context) {
        _scaffoldContext = context;
        return _body();
      }),
      backgroundColor: constants.backgroundColor,
    );
  }

  Future<void> _onChatAvatarTapped() async {
    final File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    try {
      if (image != null) {
        final Chat chat = await api.uploadChatAvatar(image, widget.chat.id);
        setState(() {
          _changedChat = chat;
        });
      }
    } on api.ApiException catch (e) {
      constants.snackBar(_scaffoldContext, e.message, Colors.red);
    }
  }

  Widget _body() {
    return FutureBuilder<bool>(
        future: _checkYourChat(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _isYourChat = snapshot.data;
            final List<String> chatName = widget.chat.name.split(' ');
            if (chatName.length == 2) {
              _initText = '${chatName[0][0]}${chatName[1][0]}';
            } else {
              _initText = '${chatName[0][0]}';
            }
            return Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: constants.containerColor,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(10.0).copyWith(left: 20.0),
                            child: Row(
                              children: <Widget>[
                                CircularProfileAvatar(
                                  _changedChat == null
                                      ? widget.chat.images.isEmpty
                                          ? ''
                                          : widget.chat.images[0].imageURL
                                      : _changedChat.images.isEmpty
                                          ? ''
                                          : _changedChat.images[0].imageURL,
                                  cacheImage: true,
                                  radius: 40.0,
                                  onTap: () => _isYourChat ? _onChatAvatarTapped() : null,
                                  initialsText: Text(
                                    _initText.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 40, color: Colors.white),
                                  ),
                                  backgroundColor: constants.appBarColor,
                                  borderColor: constants.appBarColor,
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                _chatTitle(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Container(
                          color: constants.containerColor,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'Description',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              _chatDescription(),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Container(
                          color: constants.containerColor,
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${widget.chat.users != null ? widget.chat.users.length : 0} members',
                                  style: Theme.of(context).textTheme.body1,
                                ),
                              ),
                              if (!_isYourChat)
                                GestureDetector(
                                  child: Text(
                                    'Leave',
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                          color: Colors.red,
                                        ),
                                  ),
                                  onTap: () {
                                    _leaveGroupPressed();
                                  },
                                ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              GestureDetector(
                                child: Text(
                                  'Add',
                                  style: Theme.of(context).textTheme.body1,
                                ),
                                onTap: _onAddMembersPressed,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        ListView.separated(
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 8.0,
                          ),
                          itemBuilder: (context, index) {
                            return _memberItem(index);
                          },
                          itemCount: _groupMembers.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                        ),
                        if (_isYourChat)
                          const SizedBox(
                            height: 80.0,
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isYourChat)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: RawMaterialButton(
                        onPressed: _submitPressed,
                        child: Icon(
                          Icons.done,
                          color: Theme.of(context).backgroundColor,
                          size: 60.0,
                        ),
                        shape: CircleBorder(),
                        elevation: 2.0,
                        fillColor: constants.accentColor,
                        padding: const EdgeInsets.all(5.0),
                      ),
                    ),
                  ),
                if (_isLoading)
                  Container(
                    color: Theme.of(context).backgroundColor.withOpacity(0.9),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).accentColor),
                      ),
                    ),
                  ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Future<void> _leaveGroupPressed() async {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            backgroundColor: constants.backgroundColor,
            title: Container(
              color: constants.containerColor,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Are you sure?',
                style: Theme.of(context).textTheme.title,
                textAlign: TextAlign.center,
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: constants.containerColor,
                      child: Text(
                        'Yes',
                        style: Theme.of(context).textTheme.body1,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _leaveGroup();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: constants.containerColor,
                      child: Text(
                        'No',
                        style: Theme.of(context).textTheme.body1,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _leaveGroup() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await api.leaveGroup(groupId: widget.chat.id);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message, Colors.red);
    }
  }

  Future<void> _submitPressed() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final EditGroupResponse response = await api.editChat(
          id: widget.chat.id,
          name: _chatNameController.text,
          description: _chatDescriptionController.text);
      _changedChat = widget.chat
          .copyWith(name: response.name, description: response.description);
      setState(() {
        _isLoading = false;
      });
      constants.snackBar(_scaffoldContext, 'Group edited successfully');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message);
    }
  }

  final InputDecoration _textFieldDecoration = InputDecoration(
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: constants.accentColor, width: 2.0)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: constants.accentColor, width: 2.0)));

  Widget _chatTitle() => _isYourChat
      ? Expanded(
          child: TextField(
            controller: _chatNameController,
            style:
                Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
            decoration: _textFieldDecoration,
            maxLines: 2,
            minLines: 1,
            onChanged: (query) {
              final List<String> queryList = query.split(' ');
              setState(() {
                if (queryList.length == 2) {
                  _initText = '${queryList[0][0]}${queryList[1][0]}';
                } else {
                  _initText = '${queryList[0][0]}';
                }
              });
            },
          ),
        )
      : Flexible(
          child: Text(
            widget.chat.name,
            maxLines: 3,
            style:
                Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
          ),
        );

  Widget _chatDescription() => _isYourChat
      ? TextField(
          controller: _chatDescriptionController,
          style: Theme.of(context).textTheme.body1.copyWith(
                color: Colors.white,
              ),
          minLines: 1,
          maxLines: 4,
        )
      : Text(
          widget.chat.description,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
        );

  Widget _memberItem(int index) {
    final user = _groupMembers[index];
    String initText;
    if (user.firstName.isNotEmpty && user.lastName.isNotEmpty) {
      initText = '${user.firstName[0]}${user.lastName[0]}'.toString();
    } else {
      initText = 'NS';
    }

    final String name =
        '${user.firstName.isEmpty ? 'Name' : user.firstName} ${user.lastName.isEmpty ? 'Surname' : user.lastName}';
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: constants.containerColor,
      child: GestureDetector(
        onTap: () {
          constants.goToPage(
            context,
            UserPage(
              username: _groupMembers[index].username,
            ),
          );
        },
        child: Row(
          children: <Widget>[
            CircularProfileAvatar(
              user == null  || user.images.isEmpty ? '' : user.images[0].imageURL,
              radius: 30.0,
              initialsText: Text(
                initText,
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
              backgroundColor: constants.appBarColor,
              borderColor: constants.appBarColor,
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: Theme.of(context).textTheme.body1.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ),
            _popupMenuButton(index),
          ],
        ),
      ),
    );
  }

  Widget _popupMenuButton(int index) {
    final User user = _groupMembers[index];
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: constants.containerColor,
      ),
      child: custom_popup.PopupMenuButton<int>(
        icon: Icon(
          Icons.more_vert,
          color: constants.fontColor,
        ),
        itemBuilder: (context) => <custom_popup.PopupMenuEntry<int>>[
          custom_popup.PopupMenuItem(
            value: 0,
            child: Center(
              child: Text(
                'Profile',
                style: Theme.of(context).textTheme.body1,
              ),
            ),
          ),
          if (_isYourChat && user.id != _currentUser.id)
            custom_popup.PopupMenuItem(
              value: 1,
              child: Center(
                child: Text(
                  'Kick',
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
            ),
          if (_isYourChat && user.id != _currentUser.id)
            custom_popup.PopupMenuItem(
              value: 2,
              child: Center(
                child: Text(
                  'Ban',
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
            ),
        ],
        padding: EdgeInsets.zero,
        onSelected: (value) {
          switch (value) {
            case 0:
              constants.goToPage(
                context,
                UserPage(
                  username: _groupMembers[index].username,
                ),
              );
              break;

            case 1:
              showDialog<void>(
                  context: context,
                  builder: (context) {
                    return areYouSureDialog(() => _kickMember(index));
                  });
              break;

            case 2:
              showDialog<void>(
                  context: context,
                  builder: (context) {
                    return areYouSureDialog(() => _banMember(index));
                  });
              break;
          }
        },
      ),
    );
  }

  Future<void> _kickMember(int index) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await api.kickMember(
          chatId: widget.chat.id, username: _groupMembers[index].username);
      setState(() {
        _groupMembers.removeAt(index);
        _isLoading = false;
      });
      constants.snackBar(_scaffoldContext, 'User kicked successfully');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message);
    }
  }

  Future<void> _banMember(int index) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await api.banMember(
          chatId: widget.chat.id, username: _groupMembers[index].username);
      setState(() {
        _groupMembers.removeAt(index);
        _isLoading = false;
      });
      constants.snackBar(_scaffoldContext, 'User banned successfully');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final api.ApiException error = e;
      constants.snackBar(_scaffoldContext, error.message);
    }
  }

  AlertDialog areYouSureDialog(Function confirmFunction) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: constants.backgroundColor,
      title: Container(
        color: constants.containerColor,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Are you sure?',
          style: Theme.of(context).textTheme.title,
          textAlign: TextAlign.center,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                color: constants.containerColor,
                child: Text(
                  'Yes',
                  style: Theme.of(context).textTheme.body1,
                ),
                onPressed: () {
                  confirmFunction();
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: RaisedButton(
                color: constants.containerColor,
                child: Text(
                  'No',
                  style: Theme.of(context).textTheme.body1,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _onAddMembersPressed() async {
    final List<User> result = await Navigator.push(
      context,
      MaterialPageRoute<List<User>>(
        builder: (context) => SearchMembersPage(
          chat: widget.chat,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _groupMembers = result;
        _groupMembers.insert(0, widget.chat.creator);
      });
    }
  }
}
