import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/responses/create_chat_response.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/widgets/pages/edit_group_page.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();

  bool _isLoading = false;

  BuildContext _scaffoldContext;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      _scaffoldContext = context;
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
        body: Stack(
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
        ),
        backgroundColor: constants.backgroundColor,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _initTextControllers();
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
            child: Form(
              key: _formKey,
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
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Group name required';
                              }
                              return null;
                            },
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
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Group description required';
                            }
                            return null;
                          },
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

  Future<void> _createGroupPressed() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final CreateChatResponse response = await api.createChat(
            name: _groupNameController.text,
            description: _groupDescriptionController.text);
        final Chat chat = await api.getChat(id: response.id);
        constants.goToPage(context, EditGroupPage(chat: chat,));
        Navigator.of(context).pop();
//        Navigator.of(context).pushAndRemoveUntil<void>(
//            MaterialPageRoute(
//              builder: (context) => EditGroupPage(
//                chat: chat,
//              ),
//            ),
//            (Route<dynamic> route) => false);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        final api.ApiException error = e;
        constants.snackBar(_scaffoldContext, error.message);
      }
    }
  }
}
