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
  DropDownCubit(super.initValue);
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

//hiding the state of visibility-----------------------------------
class ToggleButtonCubit extends Cubit<bool> {
  ToggleButtonCubit(bool? currentToggle) : super(currentToggle ?? true);
  void toggle() => emit(!state);
}
//-----------------------------------------------------------------