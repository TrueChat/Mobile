import 'package:equatable/equatable.dart';

abstract class UserSettingsEvent extends Equatable {
  const UserSettingsEvent();
}

class EditPressed extends UserSettingsEvent {
  final int id;
  final String data;

  EditPressed({this.id,this.data});

  @override
  List<Object> get props => [id,data];
}

class SubmitPressed extends UserSettingsEvent{
  final String name;
  final String username;
  final String bio;


  SubmitPressed({this.name, this.username, this.bio});

  @override
  List<Object> get props => [name,username,bio];

}
