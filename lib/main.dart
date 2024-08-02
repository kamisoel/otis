import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:otis/model/model.dart';
import 'package:otis/authentication/authentication.dart';
import 'package:otis/user_detail/user_detail.dart';
import 'package:otis/user_list/user_list.dart';
import 'package:otis/login/login.dart';

import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:otis/localization.dart';

void main() {
  if(Foundation.kDebugMode) {
    Bloc.observer = AppObserver();
  }

  final repository = Repository(
    wp: WordpressApi(baseUrl: "otis-guendel.de"),
    fileStore: FileStore(),
  );

  runApp(
    RepositoryProvider(
      create: (_) => repository,
      child: BlocProvider<AuthenticationBloc>(
        create: (_) {
          return AuthenticationBloc(repository: repository)..add(AppStarted());
        },
        child: OtisApp(),
      ),
    )
  );
}

class OtisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OTIS",
      theme: ThemeData(
        primaryColor: Colors.lightGreen,
        accentColor: Colors.lightGreenAccent,
        buttonColor: Colors.lightGreen,
        brightness: Brightness.dark,
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('de', 'DE'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final user = state.loggedInUser;

            if (user.canEdit) {
              return BlocProvider<UserListBloc>(
                create: (context) =>
                UserListBloc(repository: RepositoryProvider.of<Repository>(context))
                  ..add(LoadUserList()),
                child: UserListPage(),
              );
            } else {
              return BlocProvider<UserDetailBloc>(
                create: (_) => UserDetailBloc(
                  repository: RepositoryProvider.of<Repository>(context),
                  user: user,
                )..add(LoadUserDetail()),
                child: UserDetailPage(user: user,),
              );
            }
          }

          if (state is Unauthenticated)
            return LoginPage();

          if (state is AuthenticationLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SplashScreen();
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Center(
          child:Image.asset("assets/otis.png")
      ),
    );
  }
}

class AppObserver extends BlocObserver {
  @override
  void onEvent(BlocBase bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}