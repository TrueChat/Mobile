import 'dart:async';
import 'package:bloc/bloc.dart';
import '../bloc.dart';

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  @override
  UserSettingsState get initialState => UserLoadingState();

  @override
  Stream<UserSettingsState> mapEventToState(
    UserSettingsEvent event,
  ) async* {
    if(event is EditPressed){


    }else if(event is SubmitPressed){

    }
  }
}
