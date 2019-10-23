import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'login_tab.dart';

abstract class LoginPageControllerEvent extends Equatable {
  const LoginPageControllerEvent();
}

class PageChange extends LoginPageControllerEvent {
  final LoginTab tab;

  @override
  List<Object> get props => [tab];

  PageChange({@required this.tab})
      : assert(tab != null);
}
