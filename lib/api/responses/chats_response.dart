import 'package:true_chat/api/models/chat.dart';

class ChatsResponse {
  ChatsResponse({this.count, this.next, this.previous, this.results});

  factory ChatsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dyn = json['results'];
    final List<Chat> results = dyn.map((dynamic i) => Chat.fromJson(i)).toList();

    return ChatsResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: results,
    );
  }

  final int count;
  final String next;
  final String previous;
  final List<Chat> results;
}
