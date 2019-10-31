import 'package:true_chat/api/responses/response.dart';

class LoginResponse extends Response {

  LoginResponse(bool isError, String message, this.accessToken)
      : super(isError, message);

  final String accessToken;
}
