import 'package:equatable/equatable.dart';

abstract class UserSettingsState extends Equatable {
  const UserSettingsState();
}

class InitialUserSettingsState extends UserSettingsState {
  @override
  List<Object> get props => [];
}

class EditNameState extends UserSettingsState{
  final String name;

  EditNameState({this.name});

  @override
  List<Object> get props => [name];
}

class EditUsernameState extends UserSettingsState{
  final String username;

  EditUsernameState({this.username});

  @override
  List<Object> get props => [username];
}

class EditBioState extends UserSettingsState{
  final String bio;

  EditBioState({this.bio});

  @override
  List<Object> get props => [bio];
}
