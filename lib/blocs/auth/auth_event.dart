import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}

class ClearErrorRequested extends AuthEvent {}

class CheckAuthRequested extends AuthEvent {}
