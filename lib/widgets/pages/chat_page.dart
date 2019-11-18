import 'package:flutter/material.dart';
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/helpers/constants.dart' as constants;
import 'package:true_chat/widgets/pages/edit_group_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({this.chat});

  final Chat chat;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isLoading = false;

  final TextEditingController _messageController = TextEditingController();

  String _chatName() {
    if (widget.chat.isDialog) {
      return '${widget.chat.name} - dialog';
    }
    return widget.chat.name;
  }

  Chat _chat;

  @override
  void initState() {
    super.initState();
    _chat = widget.chat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _chat),
        ),
        title: Text(
          _chatName(),
          style: TextStyle(
              fontSize: 28.0,
              color: constants.accentColor,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: constants.appBarColor,
        actions: <Widget>[
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
      body: _body(),
      backgroundColor: constants.backgroundColor,
    );
  }

  Widget _body() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _chatBody(),
        ),
        _sendBar(),
      ],
    );
  }

  Widget _chatBody() {
    return _isLoading
        ? const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(),
            ),
          );
  }

  Widget _sendBar() {
    return Container(
      color: constants.appBarColor,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _attachFilePressed,
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
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessagePressed,
          ),
        ],
      ),
    );
  }

  void _attachFilePressed() {}

  void _sendMessagePressed() {}
}
