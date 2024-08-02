import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:otis/model/model.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {

  final Repository repository;

  UserListBloc({@required this.repository}):
        super(UserListLoading());

  @override
  Stream<UserListState> mapEventToState(UserListEvent event) async* {
    if (event is LoadUserList) {
      yield* _mapLoadUserListToState();
    } else if (event is AddUser) {
      yield* _mapAddUserToState(event);
    } else if (event is DeleteUser) {
      // do nothing for now..
    }
  }

  Stream<UserListState> _mapLoadUserListToState() async* {
    try {
      final List<User> _userList = await repository.fetchAllUsers();
      _userList.sort((a, b) => a.lastName.compareTo(b.lastName));
      yield UserListLoaded(_userList);
    } catch (error) {
      yield UserListNotLoaded(error.toString());
    }
  }

  Stream<UserListState> _mapAddUserToState(AddUser event) async* {
    if (state is UserListLoaded) {
      final List<User> updated =
          List.from((state as UserListLoaded).users)
            ..add(event.user)
            ..sort((a, b) => a.lastName.compareTo(b.lastName));
      yield UserListLoaded(updated);
    }
  }
}
