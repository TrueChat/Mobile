import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LoginPageControllerState extends Equatable {
  const LoginPageControllerState();
}

class PageState extends LoginPageControllerState {
  final int currentPressedIndex;

  PageState({@required this.currentPressedIndex})
      : assert(currentPressedIndex != null);

  @override
  List<Object> get props => [currentPressedIndex];
}