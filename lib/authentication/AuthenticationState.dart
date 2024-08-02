import 'package:equatable/equatable.dart';
import 'package:otis/model/model.dart';

abstract class AuthenticationState {
}

class AuthenticationUninitialized extends AuthenticationState {
  @override
  String toString() => 'AuthenticationUninitialized';
}

class Authenticated extends AuthenticationState {
  final User loggedInUser;

  Authenticated(this.loggedInUser);

  @override
  String toString() => 'Authenticated';
}

class Unauthenticated extends AuthenticationState {
  @override
  String toString() => 'Unauthenticated';
}

class AuthenticationLoading extends AuthenticationState {
  @override
  String toString() => 'AuthenticationLoading';
}