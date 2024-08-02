import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:otis/model/model.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';
}

class LoggedIn extends AuthenticationEvent {
  final String user;
  final String token;

  LoggedIn({@required this.user, @required this.token});

  @override
  List<Object> get props => [user, token];

  @override
  String toString() => 'LoggedIn { user: $user }';
}

class LoggedOut extends AuthenticationEvent {
  @override
  String toString() => 'LoggedOut';
}
