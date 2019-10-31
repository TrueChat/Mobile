import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:true_chat/api/api.dart' as api;
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
      try {
        yield const LoginStateLoading();
        String email, username;
        if (emailRegExp.hasMatch(event.login)) {
          email = event.login;
        } else {
          username = event.login;
        }
        Response loginResponse;
        if (username == null) {
          loginResponse =
              await api.login(email: email, password: event.password);
        } else {
          loginResponse =
              await api.login(username: username, password: event.password);
        }

        if (loginResponse != null) {
          if (loginResponse.isError) {
            yield LoginStateError(message: loginResponse.message);
          } else {
            await api.getCurrentUser();
            yield LoginStateSuccess(response: loginResponse);
          }
        } else {
          yield LoginStateError(message: smthWentWrong);
        }
      } on SocketException {
        yield LoginStateError(message: noConnectionMessage);
      }
    } else if (event is RegisterSubmitted) {
      try {
        yield const LoginStateLoading();
        final Response registerResponse = await api.registration(
            email: event.email,
            username: event.username,
            password: event.password);

        if (registerResponse != null) {
          if (registerResponse.isError) {
            yield LoginStateError(message: registerResponse.message);
          } else {
            yield RegisterStateSuccess();
          }
        } else {
          yield LoginStateError(message: smthWentWrong);
        }
      } on SocketException {
        yield LoginStateError(message: noConnectionMessage);
      }
    }
  }
}
