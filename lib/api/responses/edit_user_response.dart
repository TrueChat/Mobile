import 'package:true_chat/api/responses/response.dart';

class EditUserResponse extends Response {
  EditUserResponse(bool isError, String message,
      {this.first_name, this.last_name, this.about, this.username})
      : super(isError, message);

  factory EditUserResponse.fromJson(Map<String, dynamic> json) {
    return EditUserResponse(
      false,
      'User edited successfully',
      first_name: json['first_name'],
      last_name: json['last_name'],
      about: json['about'],
      username: json['username'],
    );
  }

  final String first_name;
  final String last_name;
  final String about;
  final String username;
}
