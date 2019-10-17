import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginSubmitted extends LoginEvent {
  final String login;
  final String password;

  LoginSubmitted({this.login, this.password});

  @override
  List<Object> get props => [login, password];
}

class RegisterSubmitted extends LoginEvent{
  final String username;
  final String email;
  final String password;


  RegisterSubmitted({this.username, this.email, this.password});

  @override
  List<Object> get props => [username,email,password];

}
