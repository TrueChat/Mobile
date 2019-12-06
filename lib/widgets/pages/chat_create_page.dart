import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/responses/create_chat_response.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/api/api.dart' as api;
import 'package:true_chat/widgets/pages/chat_edit_page.dart';

class CreateChatPage extends StatefulWidget {
  @override
  _CreateChatPageState createState() => _CreateChatPageState();
}

class _CreateChatPageState extends State<CreateChatPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  BuildContext _scaffoldContext;

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
      body: Builder(builder: (context){
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
                            decoration: InputDecoration(
                              hintText: 'New Cool Group'
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
                          decoration: InputDecoration(
                              hintText: 'Group description'
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
              onTap: () => _createGroupPressed(),
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
        Navigator.of(context).pop();
        constants.goToPage(context, EditChatPage(chat: chat,));
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
