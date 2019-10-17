import 'dart:async';
import 'package:bloc/bloc.dart';
import '../bloc.dart';

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  @override
  UserSettingsState get initialState => InitialUserSettingsState();

  @override
  Stream<UserSettingsState> mapEventToState(
    UserSettingsEvent event,
  ) async* {
    if(event is EditPressed){
      switch(event.id){
        case 0:
          yield EditNameState(name: event.data);
          break;

        case 1:
          yield EditUsernameState(username: event.data);
          break;

        case 2:
          yield EditBioState(bio: event.data);
          break;
      }

    }else if(event is SubmitPressed){

    }
  }
}
