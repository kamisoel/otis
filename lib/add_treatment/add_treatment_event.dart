part of 'add_treatment_bloc.dart';

@immutable
abstract class AddTreatmentEvent extends Equatable {
}

class AddButtonPressed extends AddTreatmentEvent {

  final User user;
  final TreatmentType type;
  final String information;
  final String date;
  final String name;
  final File video;
  final File report;

  AddButtonPressed({
    @required this.user,
    @required this.type,
    @required this.date,
    this.name,
    this.information,
    this.video,
    this.report,
  });

  @override
  List<Object> get props => [user, type, date];

  @override
  String toString() => 'AddTButtonPressed {$date - $type';
}

class AttachmentUploaded extends AddTreatmentEvent {
  final File attachment;

  AttachmentUploaded({@required this.attachment});

  @override
  List<Object> get props => [attachment];
}

