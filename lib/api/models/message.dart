import 'dart:io';

import 'package:true_chat/api/models/user.dart';

class Message {
  const Message(
      {this.id, this.user, this.content, this.chat, this.dateCreated,this.images});

  factory Message.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imagesDyn = json['images'];
    return Message(
      id: json['id'],
      user: User.fromJson(json['user']),
      content: json['content'],
      chat: MessageChat.fromJson(json['chat']),
      dateCreated: json['date_created'],
      images: imagesDyn.map((dynamic el) => ImageDTO.fromJson(el)).toList()
    );
  }

  final int id;
  final User user;
  final String content;
  final MessageChat chat;
  final String dateCreated;
  final List<ImageDTO> images;
}

class ImageDTO{
  const ImageDTO({this.pk, this.name, this.imageURL});

  factory ImageDTO.fromJson(Map<String,dynamic> json){
    return ImageDTO(
      pk: json['pk'],
      name: json['name'],
      imageURL: json['imageURL']
    );
  }

  final int pk;
  final String name;
  final String imageURL;

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
