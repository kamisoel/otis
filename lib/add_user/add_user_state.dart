part of 'add_user_bloc.dart';

@immutable
abstract class AddUserState {
}

class AddUserInitial extends AddUserState {
  @override
  String toString() => 'AddUserInitial';
}

class AddUserLoading extends AddUserState {
  @override
  String toString() => 'AddUserLoading';
}

class AddUserSuccess extends AddUserState {
  @override
  String toString() => 'AddUserSuccess';
}

class AddUserFailed extends AddUserState {

  final String error;

  AddUserFailed({this.error = ""});

  @override
  String toString() => 'AddUserFailed: $error';
}