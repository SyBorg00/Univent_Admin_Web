import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//this bloc is responsible for handling all events in the main page, like updating creating etc.

//EVENTS---------------------------------------------------
abstract class ProjectEvent {}

class LoadProject extends ProjectEvent {
  final String tableName;
  final String query;
  final String? foreignKeyColumn;
  final String? foreignKeyValue;
  LoadProject({
    required this.tableName,
    required this.query,
    this.foreignKeyColumn,
    this.foreignKeyValue,
  });
}

class CreateData extends ProjectEvent {
  final String tableName;
  final Map<String, dynamic> data;
  CreateData({required this.tableName, required this.data});
}

class UpdateData extends ProjectEvent {
  final String tableName;
  final String primarykey;
  final String uid;
  final Map<String, dynamic> updatedData;
  UpdateData({
    required this.tableName,
    required this.primarykey,
    required this.uid,
    required this.updatedData,
  });
}

class DeleteData extends ProjectEvent {}
//---------------------------------------------------------

//STATES---------------------------------------------------
abstract class ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final dynamic data;
  ProjectLoaded(this.data);
}

//for create, update, or delete states
class ProjectSuccess extends ProjectState {}

class ImageDownloaded extends ProjectState {
  final PlatformFile? initialImage;
  ImageDownloaded(this.initialImage);
}

//handling errors
class ProjectError extends ProjectState {
  final String message;
  ProjectError(this.message);
}
//---------------------------------------------------------

//BLOC-----------------------------------------------------
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final SupabaseClient supabase = Supabase.instance.client;
  ProjectBloc() : super(ProjectLoading()) {
    on<LoadProject>(_onLoadProject);
    on<CreateData>(_onCreateData);
    on<UpdateData>(_onUpdateData);
  }

  Future<void> _onLoadProject(
    LoadProject event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final query = supabase.from(event.tableName).select(event.query);
      if (event.foreignKeyColumn != null && event.foreignKeyValue != null) {
        final response =
            await query
                .eq(event.foreignKeyColumn!, event.foreignKeyValue!)
                .single();
        final Map<String, dynamic> ev = Map<String, dynamic>.from(response);

        emit(ProjectLoaded(ev));
      } else {
        final response = await query;
        final List<Map<String, dynamic>> ev = List<Map<String, dynamic>>.from(
          response,
        );
        emit(ProjectLoaded(ev));
      }
    } catch (e) {
      emit(ProjectError("Failed to load data"));
    }
  }

  Future<void> _onCreateData(
    CreateData event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      await supabase.from(event.tableName).insert(event.data);
      emit(ProjectSuccess());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onUpdateData(
    UpdateData event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await supabase
          .from(event.tableName)
          .update(event.updatedData)
          .eq(event.primarykey, event.uid);
      emit(ProjectSuccess());
    } catch (e) {
      emit(ProjectError("Failed to update data"));
    }
  }
}

//---------------------------------------------------------
