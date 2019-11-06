import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/api/api.dart' as api;

class AddMembersPage extends StatefulWidget {
  const AddMembersPage({@required this.chat}) : assert(chat != null);

  final Chat chat;

  @override
  _AddMembersPageState createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  List<User> _addUsersList = [];

  List<User> _addedUsers;

  BuildContext _scaffoldContext;

  bool _isLoading = false;

  final _searchController = TextEditingController();

  String _notFoundMessage = 'Nobody found(';

  @override
  void initState() {
    super.initState();
    _addedUsers = widget.chat.users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _addedUsers),
        ),
        title: Text(
          constants.addMembersPageTitle,
          style: Theme.of(context).textTheme.title.copyWith(
            color: constants.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: constants.appBarColor,
      ),
      body: Builder(
        builder: (context) {
          _scaffoldContext = context;
          return Stack(
            children: <Widget>[
              _body(),
              if (_isLoading)
                Container(
                  color: Theme.of(context)
                      .backgroundColor
                      .withOpacity(0.9),
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
      ),
      backgroundColor: constants.backgroundColor,
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            color: constants.containerColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: Theme.of(context).textTheme.body1.copyWith(
                          color: Colors.white,
                        ),
                    decoration: InputDecoration(hintText: 'Add people'),
                    onChanged: _onSearchStringChanged,
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {
                      await _onSearchStringChanged(_searchController.text);
                    }),
              ],
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          _isFoundWidget(),
        ],
      ),
    );
  }

  Widget _isFoundWidget() => _addUsersList.isEmpty
      ? Text(
          _notFoundMessage,
          style: Theme.of(context).textTheme.title,
        )
      : ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
            height: 8.0,
          ),
          itemBuilder: (context, index) {
            return _memberToAddItem(index);
          },
          itemCount: _addUsersList.length,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
        );

  Future<void> _onSearchStringChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _notFoundMessage = 'Nobody found(';
      });
    } else {
      try {
        _addUsersList = await api.searchUser(query: query);
        for (User u in _addUsersList) {
          if (_isUserInList(u, _addedUsers) || widget.chat.creator.id == u.id) {
            _addUsersList.remove(u);
          }
        }
        setState(() {
          if (_addUsersList.isEmpty) {
            _notFoundMessage = '$query not found';
          }
        });
      } catch (e) {
        final api.ApiException error = e;
        setState(() {
          _notFoundMessage = error.message;
        });
      }
    }
  }

  int indexOfUser(User user, List<User> users) {
    int i = 0;
    while (i < users.length) {
      final User u = users[i];
      if (user.id == u.id) {
        return i;
      }
      i++;
    }
    return -1;
  }

  bool _isUserInList(User user, List<User> users) {
    for (User u in users) {
      if (u.id == user.id) {
        return true;
      }
    }
    return false;
  }

  Widget _memberToAddItem(int index) {
    final user = _addUsersList[index];
    final initText = '${user.firstName[0]}${user.lastName[0]}'.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: constants.containerColor,
      child: Row(
        children: <Widget>[
          CircularProfileAvatar(
            initText,
            radius: 30.0,
            initialsText: Text(
              initText,
              style: TextStyle(fontSize: 30, color: Colors.white),
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
                  '${user.firstName} ${user.lastName}',
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
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              onAddUserPressed(user);
            },
          ),
        ],
      ),
    );
  }

  Future<void> onAddUserPressed(User user) async {
    if (!_isUserInList(user, _addedUsers)) {
      setState(() {
        _isLoading = true;
      });
      try {
        final Chat chat = await api.addUserToChat(
            chatId: widget.chat.id, username: user.username);
        setState(() {
          _addedUsers = chat.users;
          _isLoading = false;
        });
        constants.snackBar(
            _scaffoldContext, '${user.username} added successfully');
      } catch (e) {
        final api.ApiException error = e;
        constants.snackBar(_scaffoldContext, error.message);
      }
    }else{
      constants.snackBar(_scaffoldContext, '${user.username} already added');
    }
  }
}
