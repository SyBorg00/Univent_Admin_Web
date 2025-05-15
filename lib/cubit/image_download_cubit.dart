import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageDownloadCubit extends Cubit<PlatformFile?> {
  final SupabaseClient supabase = Supabase.instance.client;
  ImageDownloadCubit() : super(null);

  Future<void> downloadImage(String filePath) async {
    try {
      final img = await supabase.storage.from('images').download(filePath);
      final initImg = PlatformFile(
        name: filePath,
        size: img.length,
        bytes: img,
      );
      emit(initImg);
    } catch (e) {
      emit(null);
    }
  }
}
