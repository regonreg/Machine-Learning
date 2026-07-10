import 'package:flutter/material.dart';
import '../../models/user_model.dart';

@immutable
abstract class AuthState {
  final UserModel? currentUser;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.currentUser,
    this.errorMessage,
    this.isLoading = false,
  });
}

class AuthInitial extends AuthState {
  const AuthInitial() : super();
}

class AuthLoading extends AuthState {
  const AuthLoading() : super(isLoading: true);
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user) : super(currentUser: user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({String? errorMessage}) : super(errorMessage: errorMessage);
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message) : super(errorMessage: message);
}
