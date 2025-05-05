import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventMiniCalendar extends StatelessWidget {
  final DateTime eventDate;
  const EventMiniCalendar({super.key, required this.eventDate});

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MM').format(eventDate);
    final day = DateFormat('d').format(eventDate);
    final shortenedMonth = monthShortened(month);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
      color: Colors.white,
      elevation: 20,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
        child: Column(
          children: [
            Text(
              shortenedMonth,
              style: TextStyle(
                fontSize: 12,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            Text(
              day,
              style: TextStyle(
                fontSize: 20,
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String monthShortened(month) {
    String result = '';
    switch (month) {
      case '01':
        result = 'JAN';
      case '02':
        result = 'FEB';
      case '03':
        result = 'MAR';
      case '04':
        result = 'APR';
      case '05':
        result = 'MAY';
      case '06':
        result = 'JUN';
      case '07':
        result = 'JUL';
      case '08':
        result = 'AUG';
      case '09':
        result = 'SEP';
      case '10':
        result = 'OCT';
      case '11':
        result = 'NOV';
      case '12':
        result = 'DEC';
    }
    return result;
  }
}
