import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Calendar/schedule_backlog_items_page.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'calendar_page.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';
import 'notes_page.dart';
import 'package:http/http.dart' as http;

class TomorrowPlanningPage extends StatefulWidget {
  const TomorrowPlanningPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<TomorrowPlanningPage> createState() => _TomorrowPlanningPageState();
}

class _TomorrowPlanningPageState extends State<TomorrowPlanningPage> {
  //bool _value = false;
  //var backlog = PlannerService.sharedInstance.user.backlog;

  @override
  void initState() {
    super.initState();
    //print(PlannerService.sharedInstance.user.backlog);
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
          children: const [
            Text(
              "Tomorrow",
              style: TextStyle(color: Colors.white),
            ),
            // Text(
            //   DateFormat.yMMMd().format(DateTime.now()),
            //   style: Theme.of(context).textTheme.subtitle1,
            // ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    PlannerService.sharedInstance.user!.spaceImage,
                  ),
                  fit: BoxFit.fill)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt),
            tooltip: 'View this backlog item',
            onPressed: () {
              //setState(() {});
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => const NotesPage(
                            fromPage: "Tomorrow",
                          )));
            },
          ),
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
          dataSource: CalendarPage.events,

          //EventDataSource(PlannerService.sharedInstance.user.allEvents),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewCalendarItemDialog,
        tooltip: 'Create new event.',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void unscheduleEvent() {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              child: const Text(
                "Are you sure you want to unschedule this backlog item?",
                textAlign: TextAlign.center,
              ),
            ),
            content: const Text(
                "This will not delete the backlog item, it will just be removed from your calendar."),
            actions: <Widget>[
              TextButton(
                child: const Text('yes, unschedule'),
                onPressed: () async {
                  //make call to server to unschedule task.
                  if (CalendarPage.selectedEvent != null) {
                    var body = {
                      'eventId': CalendarPage.selectedEvent!.id,
                      'taskId': CalendarPage.selectedEvent!.taskIdRef
                    };
                    String bodyF = jsonEncode(body);
                    print(bodyF);

                    var url = Uri.parse(
                        'http://192.168.1.4:7343/backlog/unscheduletask');
                    var response = await http.post(url,
                        headers: {"Content-Type": "application/json"},
                        body: bodyF);
                    print('Response status: ${response.statusCode}');
                    print('Response body: ${response.body}');

                    if (response.statusCode == 200) {
                      //delete event & unschedule backlog item
                      //if (CalendarPage.selectedEvent != null) {
                      CalendarPage.events.appointments!.removeAt(CalendarPage
                          .events.appointments!
                          .indexOf(CalendarPage.selectedEvent));
                      CalendarPage.events.notifyListeners(
                          CalendarDataSourceAction.remove,
                          <Event>[]..add(CalendarPage.selectedEvent!));
                      PlannerService.sharedInstance.user!.scheduledEvents =
                          CalendarPage.events.appointments! as List<Event>;

                      var backlogItemRef =
                          CalendarPage.selectedEvent!.backlogMapRef;

                      PlannerService
                          .sharedInstance
                          .user!
                          .backlogMap[backlogItemRef!.categoryName]![
                              backlogItemRef.arrayIdx]
                          .scheduledDate = null;
                      CalendarPage.selectedEvent = null;
                      setState(() {});
                      Navigator.pop(context);
                      //}
                    } else {
                      //500 error, show an alert
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  'Oops! Looks like something went wrong. Please try again.'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }
                  }
                },
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('cancel'))
            ],
          );
        });
  }

  void deleteEvent() {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              child: const Text(
                "Are you sure you want to delete?",
                textAlign: TextAlign.center,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('yes, delete'),
                onPressed: () {
                  if (CalendarPage.selectedEvent != null) {
                    CalendarPage.events.appointments!.removeAt(CalendarPage
                        .events.appointments!
                        .indexOf(CalendarPage.selectedEvent));
                    CalendarPage.events.notifyListeners(
                        CalendarDataSourceAction.remove,
                        <Event>[]..add(CalendarPage.selectedEvent!));
                    PlannerService.sharedInstance.user!.scheduledEvents =
                        CalendarPage.events.appointments! as List<Event>;
                    CalendarPage.selectedEvent = null;
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('cancel'))
            ],
          );
        });
  }

  void calendarTapped(CalendarTapDetails details) {
    print("printing appoinment id for tomorrow calendar");
    print(details.appointments);
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Event appointmentDetails = details.appointments![0];
      var _subjectText = appointmentDetails.description;
      var _dateText = DateFormat('MMMM dd, yyyy')
          .format(appointmentDetails.start)
          .toString();
      var _startTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.start).toString();
      var _endTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.end).toString();
      var _timeDetails = '$_startTimeText - $_endTimeText';
      CalendarPage.selectedEvent = appointmentDetails;

      // if (appointmentDetails.isAllDay) {
      //   _timeDetails = 'All day';
      // } else {
      //   _timeDetails = '$_startTimeText - $_endTimeText';
      // }
      if (appointmentDetails.backlogMapRef != null) {
        //is a backlog item
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
                    child: const Text('unschedule'),
                    onPressed: () {
                      unscheduleEvent();
                      // Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('close'))
                ],
              );
            });
      } else {
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
                        openEditEventPage();
                      },
                      child: const Text('edit')),
                  TextButton(
                      onPressed: () {
                        deleteEvent();
                      },
                      child: const Text('delete')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('close'))
                ],
              );
            });
      }
    }
  }

  void _openNewCalendarItemDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: startPlanningFromBacklog,
                        child:
                            const Text("Schedule item from my life's backlog")),
                    ElevatedButton(
                        onPressed: openNewEventPage,
                        child: const Text("Create new task/event")),
                  ]),
              actions: <Widget>[]);
        });
  }

  void openNewEventPage() {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewEventPage(
                  updateEvents: _updateEvents,
                  fromPage: "tomorrow",
                )));
  }

  void _updateEvents() {
    setState(() {});
  }

  void planTomorrow() {}

  void startPlanningFromBacklog() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: "BacklogScheduling"),
        builder: (context) => ScheduleBacklogItemsPage(
          updateTomorrowEvents: _updateEvents,
          fromPage: "tomorrow",
        ),
      ),
    );
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (context) => const ScheduleBacklogItemsPage()));
  }

  void openEditEventPage() {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditEventPage(
                  updateEvents: _updateEvents,
                )));
  }
}
