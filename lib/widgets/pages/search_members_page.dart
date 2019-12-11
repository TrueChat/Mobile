import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/widgets/pages/user_page.dart';

class SearchMembersPage extends StatefulWidget {
  const SearchMembersPage({this.chat});

  final Chat chat;

  @override
  _SearchMembersPageState createState() => _SearchMembersPageState();
}

class _SearchMembersPageState extends State<SearchMembersPage> {
  List<User> _addUsersList = [];

  List<User> _addedUsers;

  BuildContext _scaffoldContext;

  bool _isLoading = false;

  final _searchController = TextEditingController();

  String _notFoundMessage = '';

  @override
  void initState() {
    super.initState();
    _addedUsers = widget.chat == null ? null : widget.chat.users;
    _addedUsers.removeAt(0);
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
          widget.chat == null ? 'Search users' : constants.addMembersPageTitle,
          style: Theme.of(context).textTheme.title.copyWith(
                color: constants.accentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: constants.appBarColor,
      ),
      body: Builder(builder: (context) {
        _scaffoldContext = context;
        return Stack(
          children: <Widget>[
            _body(),
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
      }),
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

  Widget _isFoundWidget() {
    return _addUsersList.isEmpty
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
  }

  Future<void> _onSearchStringChanged(String query) async {
    final String result = query.trim();
    if (result.isNotEmpty) {
      try {
        _addUsersList = await api.searchUser(query: query);
        if (widget.chat != null) {
          final List<User> toRemove = [];
          for (User u in _addUsersList) {
            if (_isUserInList(u, _addedUsers) ||
                widget.chat.creator.id == u.id) {
              toRemove.add(u);
            }
          }
          if(toRemove.isNotEmpty){
            _addUsersList.removeWhere( (e) => toRemove.contains(e));
          }
        }
        setState(() {
          if (_addUsersList.isEmpty) {
            _notFoundMessage = '$result not found';
          }
        });
      } on api.ApiException catch (e) {
        final api.ApiException error = e;
        setState(() {
          _notFoundMessage = error.message;
        });
      }
    } else {
      setState(() {
        _notFoundMessage = '';
      });
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
    final initText =
        '${user.firstName.isEmpty ? 'N' : user.firstName[0]}${user.lastName.isEmpty ? 'S' : user.lastName[0]}';
    return GestureDetector(
      onTap: () {
        if (widget.chat == null) {
          constants.goToPage(
              context,
              UserPage(
                username: user.username,
              ));
        }
      },

      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: constants.containerColor,
        child: Row(
          children: <Widget>[
            CircularProfileAvatar(
              user.images.isEmpty ? '' : user.images[0].imageURL,
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
                    '${user.firstName.isEmpty ? 'Name' : user.firstName} ${user.lastName.isEmpty ? 'Surname' : user.lastName}',
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
            if (widget.chat != null)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  onAddUserPressed(user);
                },
              ),
          ],
        ),
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
    } else {
      constants.snackBar(_scaffoldContext, '${user.username} already added');
    }
  }
}
