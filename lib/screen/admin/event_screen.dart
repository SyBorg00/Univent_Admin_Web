import 'package:agawin_unievent_app/screen/admin/event_management.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventScreen extends StatelessWidget {
  final Map<String, dynamic> events;
  const EventScreen({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          width: size.width * .9,
          height: size.height * .9,
          child: Stack(
            children: [
              images(size, supabase),
              shader(size),
              contents(size, supabase),
              close(context),
              updateButton(context),
              removeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Positioned removeButton() {
    return Positioned(
      bottom: 50,
      right: 100,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 36, 36),
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete, size: 30, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Remove This Event",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }

  Positioned updateButton(BuildContext context) {
    return Positioned(
      bottom: 50,
      right: 475,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      EventManagement(currentEvent: events, isUpdateData: true),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 30, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Update This Event",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }

  Positioned close(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.close, color: Colors.white, size: 50),
        tooltip: "Close",
      ),
    );
  }

  Positioned contents(Size size, SupabaseClient supabase) {
    return Positioned(
      right: 30,
      top: 80,
      child: SizedBox(
        width: size.width * .6,
        height: size.height * .9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: title(supabase),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 40),
                child: Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, right: 40),
                child: Text(
                  events['description'],
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              dateInfo("Starts at: ", events['datetimestart']),
              dateInfo("Ends at: ", events['datetimeend']),
            ],
          ),
        ),
      ),
    );
  }

  Positioned shader(Size size) {
    return Positioned(
      right: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          width: size.width * .9,
          height: size.height * .9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 8, 8, 8),
                Color.fromARGB(255, 24, 24, 24),
                Color.fromARGB(220, 24, 24, 24),
                Colors.transparent,
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              stops: [0, 0.6, 0.8, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  ClipRRect images(Size size, SupabaseClient supabase) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        topLeft: Radius.circular(20),
      ),
      child: SizedBox(
        width: size.width * .6,
        height: size.height * .9,
        child: Image.network(
          fit: BoxFit.cover,
          supabase.storage.from('images').getPublicUrl(events['banner']),
        ),
      ),
    );
  }

  Row dateInfo(prefix, eventDate) {
    DateTime date = DateTime.parse(eventDate);
    int hour = date.hour <= 12 ? date.hour : 24 - date.hour;
    String stringMonth = convertMonth(date.month);
    String stringHour = concatenateZero(hour);
    String timePeriod = date.hour < 12 ? "AM" : "PM";
    String stringMin = concatenateZero(date.minute);
    String stringSec = concatenateZero(date.second);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_month, color: Colors.white),
        SizedBox(width: 20),
        Text(
          prefix,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          "$stringMonth ${date.day}, ${date.year} @ $stringHour:$stringMin:$stringSec $timePeriod",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  String convertMonth(int month) {
    String stringMonth;
    switch (month) {
      case 1:
        stringMonth = "January";
      case 2:
        stringMonth = "February";
      case 3:
        stringMonth = "March";
      case 4:
        stringMonth = "April";
      case 5:
        stringMonth = "May";
      case 6:
        stringMonth = "June";
      case 7:
        stringMonth = "July";
      case 8:
        stringMonth = "August";
      case 9:
        stringMonth = "September";
      case 10:
        stringMonth = "October";
      case 11:
        stringMonth = "November";
      case 12:
        stringMonth = "December";
      default:
        stringMonth = "--";
    }
    return stringMonth;
  }

  String concatenateZero(int num) {
    String result = num.toString();
    if (num < 10) {
      result = "0$num";
    }
    return result;
  }

  Column title(SupabaseClient supabase) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                supabase.storage
                    .from('images')
                    .getPublicUrl(events['organizations']['logo']),
              ),
            ),
            VerticalDivider(),
            Text(
              events['title'],
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          "Organizer: ${events['organizations']['name']}",
          textAlign: TextAlign.start,
          style: TextStyle(
            color: const Color.fromARGB(255, 155, 155, 155),
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}
