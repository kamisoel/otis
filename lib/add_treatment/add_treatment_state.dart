part of 'add_treatment_bloc.dart';

@immutable
abstract class AddTreatmentState {
}

class AddTreatmentInitial extends AddTreatmentState {
  @override
  String toString() => "AddTreatmentInitial";
}

class AddTreatmentLoading extends AddTreatmentState {
  @override
  String toString() => "AddTreatmentLoading";
}

class AddTreatmentSuccess extends AddTreatmentState {
  @override
  String toString() => "AddTreatmentSuccess";
}

class AddTreatmentFailed extends AddTreatmentState {

  final String error;

  AddTreatmentFailed({this.error});
  @override
  String toString() => "AddTreatmentFailed";
}

class VideoCompressionStarted extends AddTreatmentState {
  @override
  String toString() => "AddTreatmentStarted";
}

class VideoUploadStarted extends AddTreatmentState {
  @override
  String toString() => "AddTreatmentStarted";
}

class ReportUploadStarted extends AddTreatmentState {
  @override
  String toString() => "AddTreatmentStarted";
}