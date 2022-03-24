import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';

class TomorrowSchedulePage extends StatefulWidget {
  const TomorrowSchedulePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<TomorrowSchedulePage> createState() => _TomorrowSchedulePageState();
}

class _TomorrowSchedulePageState extends State<TomorrowSchedulePage> {
  //bool _value = false;
  //var backlog = PlannerService.sharedInstance.user.backlog;

  @override
  void initState() {
    super.initState();
    //print(PlannerService.sharedInstance.user.backlog);
  }

  void _openNewCalendarItemPage() {
    //this function needs to change to create new goal
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewEventPage(
                  updateEvents: _updateEvents,
                  fromPage: "tomorrow",
                )));
  }

  void openEditEventPage(int id) {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                EditEventPage(updateEvents: _updateEvents, id: id)));
  }

  void _goToMonthlyView() {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const MonthlyCalendarPage()));
  }

  void _updateEvents() {
    setState(() {});
  }

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Event appointmentDetails = details.appointments![0];
      var _subjectText = appointmentDetails.eventName;
      var _dateText = DateFormat('MMMM dd, yyyy')
          .format(appointmentDetails.start)
          .toString();
      var _startTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.start).toString();
      var _endTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.end).toString();
      var _timeDetails = '$_startTimeText - $_endTimeText';
      // if (appointmentDetails.isAllDay) {
      //   _timeDetails = 'All day';
      // } else {
      //   _timeDetails = '$_startTimeText - $_endTimeText';
      // }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Container(
                child: new Text(
                  '$_subjectText',
                  textAlign: TextAlign.center,
                ),
              ),
              content: Card(
                child: Container(
                  height: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_dateText',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      ),
                      Text(_timeDetails,
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15)),
                      Text(appointmentDetails.notes)
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      openEditEventPage(appointmentDetails.id);
                    },
                    child: new Text('edit')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text('delete')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text('close'))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Column(
          children: [
            const Text("Tomorrow"),
            // Text(
            //   DateFormat.yMMMd().format(DateTime.now()),
            //   style: Theme.of(context).textTheme.subtitle1,
            // ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'View full calendar',
            onPressed: () {
              _goToMonthlyView();
            },
          ),
          IconButton(
            icon: const Icon(Icons.note_alt),
            tooltip: 'View this backlog item',
            onPressed: () {
              setState(() {});
            },
          ),
          // TextButton(
          //   child: const Text("Tomorrow"),
          //   onPressed: () => {},
          // ),
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),
      body: Container(
        child: SfCalendar(
          view: CalendarView.day,
          onTap: calendarTapped,
          initialDisplayDate: DateTime(DateTime.now().year,
              DateTime.now().month, DateTime.now().day + 1),
          dataSource:
              EventDataSource(PlannerService.sharedInstance.user.allEvents),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openNewCalendarItemPage,
        tooltip: 'Create new event.',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}