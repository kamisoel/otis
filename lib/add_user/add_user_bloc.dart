import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:otis/model/model.dart';
import 'package:otis/user_list/user_list.dart';

part 'add_user_event.dart';

part 'add_user_state.dart';

class AddUserBloc extends Bloc<AddUserEvent, AddUserState> {
  final UserListBloc userListBloc;
  final Repository repository;

  AddUserBloc({@required this.userListBloc, @required this.repository}):
        assert(userListBloc != null),
        super(AddUserInitial());

  @override
  Stream<AddUserState> mapEventToState(AddUserEvent event) async* {
    if (event is AddButtonPressed) {
      yield AddUserLoading();

      try {
        final user = await repository.addUser(
            event.firstName,
            event.lastName,
            event.email,
            event.password
        );
        userListBloc.add(AddUser(user: user));

        yield AddUserSuccess();
      } catch (error) {
        yield AddUserFailed(error: error.toString());
      }
    }
  }
}
