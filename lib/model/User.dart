import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class User extends Equatable {
  final int id;
  final String userName;
  final String firstName;
  final String lastName;

  String get slug => userName.replaceAll("\.", "");
  bool get canEdit => userName == 'therapeut';

  User({this.id = -1, @required this.userName, this.firstName, this.lastName});

  User.fromJson(Map<String, dynamic> json):
    id = json['id'],
    userName = json['name'],
    firstName = (json['meta']['first_name'] as List)[0],
    lastName = (json['meta']['last_name'] as List)[0];

  @override
  List<Object> get props => [id, userName, firstName, lastName];

  @override
  String toString() => "User( id=$id, userName=$userName)";

}
