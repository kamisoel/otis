import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otis/add_user/add_user_bloc.dart';
import 'package:otis/authentication/authentication.dart';
import 'package:otis/user_list/user_list.dart';
import 'package:otis/model/model.dart';
import 'package:otis/add_user/add_user_page.dart';
import 'package:otis/user_detail/user_detail_bloc.dart';
import 'package:otis/user_detail/user_detail_page.dart';
import 'package:azlistview/azlistview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:otis/localization.dart';


class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).userlistTitle),
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => BlocProvider.of<UserListBloc>(context).add(LoadUserList()),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _showExitDialog(context),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<UserListBloc>(context).add(LoadUserList());
        },
        child: BlocBuilder<UserListBloc, UserListState>(
            builder: (context, UserListState state) {
          if (state is UserListLoaded && state.users.isNotEmpty)
            return _userListView(context, state);
          else if (state is UserListLoaded && state.users.isEmpty)
            return Center(
              child: Text(AppLocalizations.of(context).noPatients),
            );
          else if (state is UserListLoading)
            return Center(child: CircularProgressIndicator());
          else // Not Loaded
            return Center(child: Text(AppLocalizations.of(context).error));
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserPage(context),
        icon: Icon(Icons.plus_one),
        label: Text(AppLocalizations.of(context).patient),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _userListView(BuildContext context, UserListLoaded loaded) {
    final _data = loaded.users.map((x) => UserSusBean(x)).toList();
    SuspensionUtil.sortListBySuspensionTag(_data);
    return AzListView(
      data: _data,
      itemCount: _data.length,
      itemBuilder: (context, index) => _buildListItem(context, _data[index]),

    );
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: 35,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text(
            '$susTag',
            textScaleFactor: 1.1,
          ),
          Expanded(
              child: Divider(
            height: .0,
            indent: 10.0,
          ))
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, UserSusBean model) {
    final susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        SizedBox(
          height: 55,
          child: _userTile(context, model.user),
        )
      ],
    );
  }

  Widget _userTile(BuildContext context, User user) => ListTile(
        dense: true,
        leading: Icon(Icons.person),
        title: Text('${user.lastName}, ${user.firstName}'),
        subtitle: Text(user.userName),
        //trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () => _showDetailPage(context, user),
      );

  void _showDetailPage(BuildContext context, User user) {
    //Navigator.of(context).push(MaterialPageRoute<UserDetailPage>(
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: BlocProvider<UserDetailBloc>(
              create: (_) => UserDetailBloc(
                repository: RepositoryProvider.of<Repository>(context),
                user: user,
              )..add(LoadUserDetail()),
              child: UserDetailPage(
                user: user,
              ),
            )));
  }

  void _showAddUserPage(BuildContext context) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AddUserBloc>(
              create: (_) => AddUserBloc(
                repository: RepositoryProvider.of<Repository>(context),
                userListBloc: BlocProvider.of<UserListBloc>(context),
              ),
            )
          ],
          child: AddUserPage(),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(AppLocalizations.of(context).logoutQuestion),
          actions: [
            TextButton(
                child: Text(AppLocalizations.of(context).logoutLabel),
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
                  Navigator.of(context).pop();
                },
            ),
            TextButton(
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () => Navigator.of(context).pop()),
          ],
        )
    );
  }
}

class UserSusBean extends ISuspensionBean {
  final User user;
  String _tag;
  String get tag => _tag;

  UserSusBean(this.user) {
    final letter = user.lastName.substring(0, 1).toUpperCase();
    _tag = (RegExp("[A-Z]").hasMatch(letter)) ? letter : '#';
  }

  @override
  String getSuspensionTag() => tag;
}
