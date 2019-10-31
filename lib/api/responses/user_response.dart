import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/api/responses/response.dart';

class UserResponse extends Response {
  UserResponse(bool isError, String message, this.user)
      : super(isError, message);

  final User user;
}
