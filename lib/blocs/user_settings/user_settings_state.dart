import 'package:equatable/equatable.dart';

abstract class UserSettingsState extends Equatable {
  const UserSettingsState();
}

class UserLoadingState extends UserSettingsState {
  @override
  List<Object> get props => [];
}

class UserLoadedState extends UserSettingsState {

  bool isNamePressed ;
  bool isUsernamePressed ;
  bool isBioPressed ;

  String currentName;
  String currentUsername;
  String currentBio;

  @override
  List<Object> get props => [
        isNamePressed,
        isUsernamePressed,
        isBioPressed,
        currentName,
        currentUsername,
        currentBio
      ];
}

class UserNotLoadedState extends UserSettingsState {
  @override
  List<Object> get props => [];
}
