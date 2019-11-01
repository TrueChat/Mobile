import 'package:true_chat/api/models/user.dart';

class Chat {
  Chat(
      {this.id,
      this.name,
      this.description,
      this.creator,
      this.users,
      this.isDialog,
      this.dateCreated});

  factory Chat.fromJson(Map<String, dynamic> json) {
    final List<dynamic> usersList = json['users'];

    return Chat(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      creator: User.fromJson(json['creator']),
      users: usersList.map((dynamic i) => User.fromJson(i)).toList(),
      isDialog: json['is_dialog'],
      dateCreated: json['date_created'],
    );
  }

  final int id;
  final String name;
  final String description;
  final User creator;
  final List<User> users;
  final bool isDialog;
  final String dateCreated;
}
