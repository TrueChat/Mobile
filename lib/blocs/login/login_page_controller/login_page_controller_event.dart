import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LoginPageControllerEvent extends Equatable {
  const LoginPageControllerEvent();
}

class PageChange extends LoginPageControllerEvent {
  final int currentPressedIndex;

  @override
  List<Object> get props => [currentPressedIndex];

  PageChange({@required this.currentPressedIndex})
      : assert(currentPressedIndex != null);
}
