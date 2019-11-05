import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart' as constants;

class AddMembersPage extends StatefulWidget {

  const AddMembersPage({@required this.chatId}) : assert(chatId != null);

  final int chatId;

  @override
  _AddMembersPageState createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {

  final _addUsersList = <User>[];

  final _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    for(int i = 0; i < 10; i++){
      _addUsersList.add(User(
        firstName: 'Name',
        lastName: 'Surname $i',
        username: 'username $i'
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          constants.addMembersPageTitle,
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
          ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(
              height: 8.0,
            ),
            itemBuilder: (context, index) {
              return _memberToAddItem(index);
            },
            itemCount: _addUsersList.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
          ),
        ],
      ),
    );
  }

  void _searchPressed(){

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
            icon:  Icon(Icons.add),
            onPressed: (){

            },
          ),
        ],
      ),
    );
  }
}
