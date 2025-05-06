import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//**For handling states of certain input fields**

//For Custom Univent Sidebar---------------------------------------
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState(isOpen: true, index: 0));

  void toggle() => emit(state.copyWith(isOpen: !state.isOpen));
  void open() => emit(state.copyWith(isOpen: true));
  void select(int index) => emit(state.copyWith(index: index));
}

class NavigationState {
  final bool isOpen;
  final int index;
  NavigationState({required this.isOpen, required this.index});

  NavigationState copyWith({bool? isOpen, int? index}) {
    return NavigationState(
      isOpen: isOpen ?? this.isOpen,
      index: index ?? this.index,
    );
  }
}
//------------------------------------------------------------------

//for custom dropdown button----------------------------------------
class DropDownCubit extends Cubit<dynamic> {
  DropDownCubit() : super(null);
  void selectItem(dynamic value) => emit(value);
}
//-----------------------------------------------------------------

//for the custom tag input field-----------------------------------
class TagInputCubit extends Cubit<List<dynamic>> {
  TagInputCubit({List<dynamic>? initialTags}) : super(initialTags ?? []);

  void addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !state.contains(trimmed)) {
      emit([...state, trimmed]);
    }
  }

  void removeTag(String tag) {
    emit(state.where((t) => t != tag).toList());
  }
}
//-----------------------------------------------------------------

//for datetime inputs----------------------------------------------
class DateRangeState {
  final DateTime? start;
  final DateTime? end;
  DateRangeState({this.start, this.end});

  DateRangeState copyWith({DateTime? start, DateTime? end}) {
    return DateRangeState(start: start ?? this.start, end: end ?? this.end);
  }
}

class DateTimeRangeCubit extends Cubit<DateRangeState> {
  DateTimeRangeCubit() : super(DateRangeState());

  void setStartDate(DateTime date) {
    final currentEnd = state.end;

    //clears end date if it is before your declared start date
    DateTime? newEnd =
        (currentEnd != null && date.isAfter(currentEnd)) ? null : currentEnd;
    emit(state.copyWith(start: date, end: newEnd));
  }

  void setEndDate(DateTime date) {
    final currentStart = state.start;
    if (currentStart != null && date.isBefore(currentStart)) return;
    emit(state.copyWith(end: date));
  }
}
//-----------------------------------------------------------------

//for image uploading----------------------------------------------
class ImagePickerCubit extends Cubit<PlatformFile?> {
  ImagePickerCubit() : super(null);
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

//hiding the state of visibility-----------------------------------
class ToggleVisibilityCubit extends Cubit<bool> {
  ToggleVisibilityCubit(super.currentToggle);
  void toggle() => emit(!state);
}
//-----------------------------------------------------------------