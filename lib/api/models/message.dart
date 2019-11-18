import 'package:true_chat/api/models/user.dart';

class Message {
  const Message(
      {this.id, this.user, this.content, this.chat, this.dateCreated});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      user: User.fromJson(json['user']),
      content: json['content'],
      chat: MessageChat.fromJson(json['chat']),
      dateCreated: json['date_created'],
    );
  }

  final int id;
  final User user;
  final String content;
  final MessageChat chat;
  final String dateCreated;
}

class MessageChat {
  const MessageChat({this.id, this.name, this.description});

  factory MessageChat.fromJson(Map<String, dynamic> json) {
    return MessageChat(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  final int id;
  final String name;
  final String description;
}
