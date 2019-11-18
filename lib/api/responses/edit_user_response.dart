import 'package:true_chat/api/responses/response.dart';

class EditUserResponse extends Response {
  EditUserResponse(bool isError, String message,
      {this.firstName, this.lastName, this.about})
      : super(isError, message);

  factory EditUserResponse.fromJson(Map<String, dynamic> json) {
    return EditUserResponse(
      false,
      'User edited successfully',
      firstName: json['first_name'],
      lastName: json['last_name'],
      about: json['about'],
    );
  }

  final String firstName;
  final String lastName;
  final String about;
}
