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
  const LoginStateLoading();

  @override
  List<Object> get props => null;
}

class LoginStateSuccess extends LoginState {
  const LoginStateSuccess({this.response});

  final Response response;

  @override
  List<Object> get props => [response];
}

class RegisterStateSuccess extends LoginState {
  @override
  List<Object> get props => null;
}

class LoginStateError extends LoginState {
  const LoginStateError({this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
