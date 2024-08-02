import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:otis/model/model.dart';
import 'package:otis/user_detail/user_detail_bloc.dart';
import 'dart:io';
import 'package:video_compress/video_compress.dart';

part 'add_treatment_event.dart';

part 'add_treatment_state.dart';

class AddTreatmentBloc extends Bloc<AddTreatmentEvent, AddTreatmentState> {
  final Repository repository;
  final UserDetailBloc userDetailBloc;

  AddTreatmentBloc(
      {@required this.userDetailBloc,
      @required this.repository}):
        assert(userDetailBloc != null),
        super(AddTreatmentInitial());

  @override
  Stream<AddTreatmentState> mapEventToState(AddTreatmentEvent event) async* {
    if (event is AddButtonPressed) yield* _addButtonPressed(event);
  }

  Stream<AddTreatmentState> _addButtonPressed(AddButtonPressed event) async* {
    yield AddTreatmentLoading();
    try {
      var _videoAttachment = Attachment.empty();
      var _reportAttachment = Attachment.empty();

      if (event.video != null) {
        yield VideoCompressionStarted();
        final _compressedVideo = await _compressVideo(event.video);
        yield VideoUploadStarted();
        _videoAttachment = await repository.uploadAttachment(_compressedVideo);
      }

      if (event.report != null) {
        yield ReportUploadStarted();
        _reportAttachment = await repository.uploadAttachment(event.report);
      }

      final newTreatment = Treatment(
          type: event.type,
          date: event.date,
          name: event.name,
          information: event.information,
          videos: [_videoAttachment],
          pdf: _reportAttachment);

      userDetailBloc.add(AddTreatment(treatment: newTreatment));

      yield AddTreatmentSuccess();
    } catch (error) {

      yield AddTreatmentFailed(error: error.toString());
    }
  }

  Future<File> _compressVideo(File video) async {
    final info = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );
    if (info == null)
        throw Exception('Could not compress video');
    return info.file;
  }
}
