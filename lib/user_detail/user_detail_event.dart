part of 'user_detail_bloc.dart';

@immutable
abstract class UserDetailEvent extends Equatable {
}

class LoadUserDetail extends UserDetailEvent {
  @override
  List<Object> get props => [];
  @override
  String toString() => 'LoadUserDetail';
}

class AddTreatment extends UserDetailEvent {
  final Treatment treatment;

  AddTreatment({@required this.treatment});

  @override
  List<Object> get props => [treatment];

  @override
  String toString() => 'AddTreatment';
}

class DeleteTreatment extends UserDetailEvent {
  final Treatment treatment;

  DeleteTreatment({@required this.treatment});

  @override
  List<Object> get props => [treatment];

  @override
  String toString() => 'DeleteTreatment';
}

class UpdateTreatment extends UserDetailEvent {
  final Treatment treatment;

  UpdateTreatment({@required this.treatment});

  @override
  List<Object> get props => [treatment];

  @override
  String toString() => 'UpdateTreatment';
}
