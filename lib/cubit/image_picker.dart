import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//for image uploading----------------------------------------------
class ImagePickerCubit extends Cubit<PlatformFile?> {
  ImagePickerCubit() : super(null);
  final SupabaseClient supabase = Supabase.instance.client;
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'gif', 'webp'],
      withData: true,
      allowMultiple: false,
    );
    if (result != null && result.files.single.bytes != null) {
      emit(result.files.single);
    }
  }

  void clearImage() => emit(null);
}



//-----------------------------------------------------------------