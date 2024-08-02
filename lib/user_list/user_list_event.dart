part of 'user_list_bloc.dart';

@immutable
abstract class UserListEvent extends Equatable {
}

class LoadUserList extends UserListEvent {
  @override
  List<Object> get props => [];
  @override
  String toString() => 'LoadUserList';
}

class AddUser extends UserListEvent {
  final User user;

  AddUser({@required this.user});

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'AddUser';
}

class DeleteUser extends UserListEvent {
  final User user;

  DeleteUser({@required this.user});

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'DeleteUser';
}
