part of 'user_detail_bloc.dart';

@immutable
abstract class UserDetailState {
}

class UserDetailLoading extends UserDetailState {
  @override
  String toString() => 'UserListLoading';
}

class UserDetailLoaded extends UserDetailState {
  final List<Treatment> treatments;

  UserDetailLoaded([this.treatments = const []])
      : assert(treatments != null);

  @override
  String toString() => 'UserListLoaded { users = $treatments }';
}

class UserDetailNotLoaded extends UserDetailState {
  final String error;

  UserDetailNotLoaded(this.error);

  @override
  String toString() => 'UserListNotLoaded {Error: $error}';
}
