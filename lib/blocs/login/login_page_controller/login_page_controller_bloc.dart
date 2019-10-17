import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../bloc.dart';

class LoginPageControllerBloc extends Bloc<LoginPageControllerEvent, LoginPageControllerState> {
  @override
  LoginPageControllerState get initialState => PageState(currentPressedIndex: 0);

  @override
  Stream<LoginPageControllerState> mapEventToState(
    LoginPageControllerEvent event,
  ) async* {
    if (event is PageChange) {
      yield event.currentPressedIndex != 0
          ? PageState(currentPressedIndex: 1)
          : PageState(currentPressedIndex: 0);
    }
  }
}
