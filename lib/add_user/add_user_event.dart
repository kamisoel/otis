part of 'add_user_bloc.dart';

@immutable
abstract class AddUserEvent extends Equatable {
  AddUserEvent([List props = const []]);
}

class AddButtonPressed extends AddUserEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  AddButtonPressed({
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [firstName, lastName, email, password];

  @override
  String toString() =>
      'AddButtonPressed { firstName: $firstName, lastName: $lastName, email: $email, password: $password }';
}