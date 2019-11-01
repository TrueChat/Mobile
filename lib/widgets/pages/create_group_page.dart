import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/widgets/custom_expansion_tile.dart' as custom;

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupSearchController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();

  final List<User> _addedUsers = [];
  final List<User> _usersToAdd = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          createGroupPageTitle,
          style: Theme.of(context).textTheme.title.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: appBarColor,
      ),
      body: _body(),
      backgroundColor: backgroundColor,
    );
  }

  @override
  void initState() {
    super.initState();
    _initTextControllers();
    for (int i = 0; i < 10; i++) {
      _addedUsers.add(User(
          firstName: 'Name', lastName: 'Surname', username: 'username $i'));
      _usersToAdd.add(User(
          firstName: 'Name',
          lastName: 'Surname',
          username: 'username ${20 - i}'));
    }
  }

  void _initTextControllers() {
    _groupNameController.text = 'New Cool Group';
    _groupDescriptionController.text = 'Dropdown description';
  }

  Widget _body() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Column(
              children: <Widget>[
                Container(
                  color: containerColor,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      CircularProfileAvatar(
                        'NC',
                        radius: 40.0,
                        initialsText: Text(
                          'NC',
                          style: TextStyle(fontSize: 40, color: Colors.white),
                        ),
                        backgroundColor: appBarColor,
                        borderColor: appBarColor,
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _groupNameController,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Container(
                  color: containerColor,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.body1,
                      ),
                      TextField(
                        controller: _groupDescriptionController,
                        style: Theme.of(context).textTheme.body1.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                custom.ExpansionTile(
                  headerBackgroundColor: appBarColor,
                  iconColor: Colors.white,
                  title: Text(
                    '${_addedUsers.length} added members',
                    style: Theme.of(context).textTheme.body1.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  expansionSpeed: Duration(milliseconds: 300),
                  children: <Widget>[
                    ListView.builder(
                      itemBuilder: (context, index) {
                        return _addedMembersItem(index);
                      },
                      itemCount: _addedUsers.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Container(
                  color: containerColor,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _groupSearchController,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.white,
                              ),
                          decoration: InputDecoration(hintText: 'Add people'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _searchPressed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0,),
                ListView.builder(
                  itemBuilder: (context, index) {
                    return _memberToAddItem(index);
                  },
                  itemCount: _usersToAdd.length,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                ),
                const SizedBox(
                  height: 58.0,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: appBarColor,
            child: ListTile(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: fontColor,
                  ),
                  Expanded(
                    child: Text(
                      'Create group',
                      style: Theme.of(context).textTheme.body1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              onTap: _createGroupPressed,
            ),
          ),
        ),
      ],
    );
  }

  String _initialText(int index) =>
      '${_addedUsers[index].firstName[0]}${_addedUsers[index].lastName[0]}'
          .toUpperCase();

  Widget _addedMembersItem(int index) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: containerColor,
      child: Row(
        children: <Widget>[
          CircularProfileAvatar(
            _initialText(index),
            radius: 30.0,
            initialsText: Text(
              _initialText(index),
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            backgroundColor: appBarColor,
            borderColor: appBarColor,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${_addedUsers[index].firstName} ${_addedUsers[index].lastName}',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  '@${_addedUsers[index].username}',
                  style: Theme.of(context).textTheme.body1,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () => _removeAddedPressed(index),
          ),
        ],
      ),
    );
  }

  Widget _memberToAddItem(int index) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: containerColor,
      child: Row(
        children: <Widget>[
          CircularProfileAvatar(
            _initialText(index),
            radius: 30.0,
            initialsText: Text(
              _initialText(index),
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            backgroundColor: appBarColor,
            borderColor: appBarColor,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${_usersToAdd[index].firstName} ${_usersToAdd[index].lastName}',
                  style: Theme.of(context).textTheme.body1.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  '@${_usersToAdd[index].username}',
                  style: Theme.of(context).textTheme.body1,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addUserPressed(index),
          ),
        ],
      ),
    );
  }

  void _removeAddedPressed(int index) {
    setState(() {
      _addedUsers.removeAt(index);
    });
  }

  void _addUserPressed(int index){
    setState(() {
      _addedUsers.add(_usersToAdd[index]);
      _usersToAdd.removeAt(index);
    });
  }

  void _searchPressed() {}

  void _createGroupPressed() {}
}
