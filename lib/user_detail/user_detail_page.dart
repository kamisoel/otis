import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otis/authentication/authentication.dart';
import 'package:otis/user_detail/user_detail_bloc.dart';
import 'package:otis/model/model.dart';
import 'treatment_card.dart';
import 'package:otis/add_treatment/add_treatment_bloc.dart';
import 'package:otis/add_treatment/add_treatment_page.dart';
import 'package:otis/localization.dart';

class UserDetailPage extends StatelessWidget {
  final User user;

  UserDetailPage({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('${user.lastName}, ${user.firstName}'),
        actions: <Widget>[
          if(userMode(context)) IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut()),
          )
          /*IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),*/
        ],
      ),
      body: BlocBuilder<UserDetailBloc, UserDetailState>(
          builder: (context, UserDetailState state) {
        if (state is UserDetailLoaded && state.treatments.isNotEmpty) {
          return _treatmentListView(context, state);
        } else if (state is UserDetailLoaded && state.treatments.isEmpty)
          return TreatmentCard.empty(context);
        else if (state is UserDetailLoading)
          return Center(child: CircularProgressIndicator());
        else // Not Loaded
          return Center(child: Text(AppLocalizations.of(context).error));
      }),
      floatingActionButton: (!userMode(context))
          ? FloatingActionButton.extended(
              onPressed: () => _addTreatmentButtonPressed(context),
              icon: Icon(Icons.plus_one),
              label: Text(AppLocalizations.of(context).treatment),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );

  Widget _treatmentListView(BuildContext context, UserDetailLoaded loaded) => ListView.builder(
      itemCount: loaded.treatments.length,
      itemBuilder: (context, i) => TreatmentCard(
            key: ValueKey(loaded.treatments[i]),
            treatment: loaded.treatments[i],
            userMode: userMode(context),
          ));

  void _addTreatmentButtonPressed(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => BlocProvider<AddTreatmentBloc>(
                  create: (_) => AddTreatmentBloc(
                    repository: RepositoryProvider.of<Repository>(context),
                    userDetailBloc: BlocProvider.of<UserDetailBloc>(context),
                  ),
                  child: AddTreatmentPage(user: user),
                )));
  }

  bool userMode(BuildContext context) {
    final _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    return !(_authBloc.state as Authenticated).loggedInUser.canEdit;
  }
}
