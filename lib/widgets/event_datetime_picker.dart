import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

//constructors
class EventDateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime) onStartChanged;
  final void Function(DateTime) onEndChanged;
  final TextEditingController startDateController;
  final TextEditingController endDateController;

  const EventDateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.startDateController,
    required this.endDateController,
  });

  //selecting date and time
  Future<void> _selectDateTime(
    BuildContext context,
    DateTime? initDate,
    void Function(DateTime) onPicked,
    TextEditingController controller,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initDate ?? DateTime.now()),
      ); //if i don't have this i might need to use stateful widget which i don't like

      if (pickedTime == null) return;

      final combined = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      onPicked(combined);
      controller.text = DateFormat.yMMMd().add_jm().format(combined);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        startDateField(context),
        SizedBox(width: 50),
        endDateField(context),
      ],
    );
  }

  Expanded endDateField(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap:
            () => _selectDateTime(
              context,
              startDate,
              onEndChanged,
              endDateController,
            ),
        child: AbsorbPointer(
          child: TextFormField(
            readOnly: true,
            controller: endDateController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: "End Date",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return "End Date required";
              if (startDate != null &&
                  endDate != null &&
                  endDate!.isBefore(startDate!)) {
                return "End date must be before start date";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Expanded startDateField(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap:
            () => _selectDateTime(
              context,
              startDate,
              onStartChanged,
              startDateController,
            ),
        child: AbsorbPointer(
          child: TextFormField(
            readOnly: true,
            controller: startDateController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: "Start Date",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator:
                (val) =>
                    (val == null || val.isEmpty) ? "Start Date Required" : null,
          ),
        ),
      ),
    );
  }
}
