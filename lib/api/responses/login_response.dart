import 'package:true_chat/api/responses/response.dart';

class LoginResponse extends Response {
  String _accessToken;

  String get accessToken => _accessToken;

  LoginResponse(bool isError, String message, this._accessToken)
      : super(isError, message);
}
