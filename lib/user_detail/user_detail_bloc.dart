import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:otis/model/model.dart';

part 'user_detail_event.dart';

part 'user_detail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {

  final Repository repository;
  final User user;

  UserDetailBloc({@required this.repository, @required this.user}):
        super(UserDetailLoading());

  @override
  Stream<UserDetailState> mapEventToState(UserDetailEvent event) async* {
    if (event is LoadUserDetail) {
      yield* _mapLoadUserDetailToState();
    } else if (event is AddTreatment) {
      yield* _mapAddTreatmentToState(event);
    } else if (event is DeleteTreatment) {
      yield* _mapDeleteTreatmentToState(event);
    } else if (event is UpdateTreatment) {
      yield* _mapUpdateTreatmentToState(event);
    }
  }

  Stream<UserDetailState> _mapLoadUserDetailToState() async* {
    try {
      final List<Treatment> _treatments = await repository.loadTreatmentsOf(user);
      yield UserDetailLoaded(_treatments);
    } catch (error){
      yield UserDetailNotLoaded(error.toString());
    }
  }

  Stream<UserDetailState> _mapAddTreatmentToState(AddTreatment event) async* {
    if (state is UserDetailLoaded) {
      final treatments = (state as UserDetailLoaded).treatments;
      final updatedTreatments = [event.treatment, ...treatments];

      await repository.updateTreatments(user, updatedTreatments);
      yield UserDetailLoaded(updatedTreatments);
    }
  }

  Stream<UserDetailState> _mapDeleteTreatmentToState(DeleteTreatment event) async* {
    if (state is UserDetailLoaded) {
      final List<Treatment> updated =
      List.from((state as UserDetailLoaded).treatments)
        ..remove(event.treatment);

      //TODO delete Media
      repository.updateTreatments(user, updated);

      yield UserDetailLoaded(updated);
    }
  }

  Stream<UserDetailState> _mapUpdateTreatmentToState(UpdateTreatment event) async* {

  }
}
