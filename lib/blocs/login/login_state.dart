import 'package:equatable/equatable.dart';
import 'package:true_chat/api/responses/response.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginStateInitial extends LoginState {
  @override
  List<Object> get props => null;
}

class LoginStateLoading extends LoginState {
  LoginStateLoading();

  @override
  List<Object> get props => null;
}

class LoginStateSuccess extends LoginState {
  final Response response;

  LoginStateSuccess({this.response});

  @override
  List<Object> get props => [response];
}

class LoginStateError extends LoginState {
  final String message;

  LoginStateError({this.message});

  @override
  List<Object> get props => [message];
}
