import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'authentication.dart';
import 'package:otis/model/model.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final Repository repository;

  AuthenticationBloc({@required this.repository}):
        assert(repository != null),
        super(AuthenticationUninitialized());

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,
      ) async* {
    if (event is AppStarted) {
      final _hasValidToken = await repository.hasValidToken();

      if (_hasValidToken) {
        yield Authenticated(await repository.getLastUser());
      } else {
        if(await repository.hasToken()) // not valid anymore
          await repository.deleteToken();
        yield Unauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await repository.persistToken(event.token);
      final _user = await repository.fetchUser(event.user);
      yield Authenticated(_user);
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await repository.deleteToken();
      yield Unauthenticated();
    }
  }


}
