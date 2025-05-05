import 'package:agawin_unievent_app/widgets/event_mini_calendar.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String? title; //title of the event card
  final String? tags; //hashtags baby
  final CircleAvatar? avatar;
  final Widget? banner;

  final DateTime eventDate;

  const EventCard({
    super.key,
    this.title,
    this.tags,
    this.avatar,
    this.banner,
    required this.eventDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.max,

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: AspectRatio(
              aspectRatio: 1.9,
              child: Stack(
                children: [
                  banner ?? Image.asset(''),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: EventMiniCalendar(eventDate: eventDate),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 15, top: 10),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  avatar ?? CircleAvatar(radius: 25, child: Icon(Icons.group)),
                  VerticalDivider(thickness: 2, width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          title ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(tags ?? "#Tags"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
