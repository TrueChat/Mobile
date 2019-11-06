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

  Chat copyWith(
      {int id,
      String name,
      String description,
      User creator,
      List<User> users,
      bool isDialog,
      String dateCreated}) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creator: creator ?? this.creator,
      users: users ?? this.users,
      isDialog: isDialog ?? this.isDialog,
      dateCreated: dateCreated ?? this.dateCreated
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
