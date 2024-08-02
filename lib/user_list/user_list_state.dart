part of 'user_list_bloc.dart';

@immutable
abstract class UserListState {
}

class UserListLoading extends UserListState {
  @override
  String toString() => 'UserListLoading';
}

class UserListLoaded extends UserListState {
  final List<User> users;

  UserListLoaded([this.users = const []]);

  @override
  String toString() => 'UserListLoaded { users = $users }';

}

class UserListNotLoaded extends UserListState {

  final String error;

  UserListNotLoaded(this.error);

  @override
  String toString() => 'UserListNotLoaded {Error: $error}';
}