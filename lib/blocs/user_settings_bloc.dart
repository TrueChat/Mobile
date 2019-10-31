import 'package:rxdart/rxdart.dart';
import 'package:true_chat/blocs/bloc_base.dart';

class UserSettingsBloc extends BlocBase {
  final BehaviorSubject<bool> _isLoading = BehaviorSubject<bool>.seeded(true);

  Observable<bool> get loadingStream => _isLoading.stream;

  void changeLoading(bool event) {
    _isLoading.add(event);
  }

  @override
  void dispose() {
    _isLoading.close();
  }
}


class UserSettingsEvent{

}

class UserSettingsState{

}
