//for datetime inputs----------------------------------------------
import 'package:flutter_bloc/flutter_bloc.dart';

class EventDateTimeRange {
  final DateTime? start;
  final DateTime? end;
  EventDateTimeRange({this.start, this.end});
}

class DateTimeRangeCubit extends Cubit<EventDateTimeRange?> {
  DateTimeRangeCubit({EventDateTimeRange? initDateTime}) : super(initDateTime);

  void setDate(EventDateTimeRange date) {
    if (date.start!.isAfter(date.end!)) {
      clear();
      return;
    }
    emit(date);
  }

  void clear() => emit(null);
  void updateStart(DateTime newStart) {
    final current = state;
    if (current != null && newStart.isAfter(current.end!)) return;
    emit(EventDateTimeRange(start: newStart, end: current?.end));
  }

  void updateEnd(DateTime newEnd) {
    final current = state;
    if (current != null && newEnd.isBefore(current.start!)) return;
    emit(EventDateTimeRange(start: current?.start, end: newEnd));
  }
}
//-----------------------------------------------------------------
