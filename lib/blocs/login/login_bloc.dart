import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:true_chat/api/api.dart';
import 'package:true_chat/api/responses/response.dart';
import 'package:true_chat/helpers/constants.dart';
import '../bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  @override
  LoginState get initialState => LoginStateInitial();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginSubmitted) {
      yield LoginStateLoading();
      String email, username;
      if (emailRegExp.hasMatch(event.login)) {
        email = event.login;
      } else {
        username = event.login;
      }
      Response loginResponse;
      if (username == null) {
        loginResponse = await Api.login(email: email, password: event.password);
      } else {
        loginResponse =
            await Api.login(username: username, password: event.password);
      }

      if (loginResponse != null) {
        if (loginResponse.isError) {
          yield LoginStateError(message: loginResponse.message);
        } else {
          yield LoginStateSuccess(response: loginResponse);
        }
      } else {
        yield LoginStateError(message: smthWentWrong);
      }
    } else if (event is RegisterSubmitted) {
      yield LoginStateLoading();
      Response registerResponse = await Api.registration(
          email: event.email,
          username: event.username,
          password: event.password);

      if (registerResponse != null) {
        if (registerResponse.isError) {
          yield LoginStateError(message: registerResponse.message);
        } else {
          yield LoginStateSuccess(response: registerResponse);
        }
      } else {
        yield LoginStateError(message: smthWentWrong);
      }
    }
  }
}