import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../bloc.dart';

class LoginPageControllerBloc extends Bloc<LoginPageControllerEvent, LoginTab> {
  @override
  LoginTab get initialState => LoginTab.signUp;

  @override
  Stream<LoginTab> mapEventToState(
    LoginPageControllerEvent event,
  ) async* {
    if (event is PageChange) {
      yield event.tab;
    }
  }
}
