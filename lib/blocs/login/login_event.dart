import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({this.login, this.password});

  final String login;
  final String password;

  @override
  List<Object> get props => [login, password];
}

class RegisterSubmitted extends LoginEvent {
  const RegisterSubmitted({this.username, this.email, this.password});

  final String username;
  final String email;
  final String password;

  @override
  List<Object> get props => [username, email, password];
}
