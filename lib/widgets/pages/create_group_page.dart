import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart' as constants;

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
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
          constants.createGroupPageTitle,
          style: Theme.of(context).textTheme.title.copyWith(
                color: constants.accentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: constants.appBarColor,
      ),
      body: _body(),
      backgroundColor: constants.backgroundColor,
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
                  color: constants.containerColor,
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
                        backgroundColor: constants.appBarColor,
                        borderColor: constants.appBarColor,
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
                  color: constants.containerColor,
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
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: constants.appBarColor,
            child: ListTile(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: constants.fontColor,
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

  void _createGroupPressed() {}
}
