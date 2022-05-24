//library event_calendar;
//part 'edit_event_page.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Calendar/no_tomorrow_plan_yet_age.dart';
import 'package:practice_planner/views/Calendar/notes_page.dart';
import 'package:practice_planner/views/Calendar/schedule_backlog_items_page.dart';
import 'package:practice_planner/views/Calendar/tomorrow_planning_page.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';
import 'package:http/http.dart' as http;

//part 'edit_event_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<CalendarPage> createState() => _CalendarPageState();
  static Event? selectedEvent;
  static late EventDataSource events;
  //EventDataSource(PlannerService.sharedInstance.user.allEvents);
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    CalendarPage.events =
        EventDataSource(PlannerService.sharedInstance.user!.scheduledEvents);
    //print(PlannerService.sharedInstance.user.backlog);
  }

  void _openNewCalendarItemPage() {
    //this function needs to change to create new goal
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewEventPage(
                  updateEvents: _updateEvents,
                  fromPage: "full_calendar",
                )));
  }

  void _openTomorrowSchedulePage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const TomorrowPlanningPage();
      },
      settings: const RouteSettings(
        name: 'TomorrowPage',
      ),
    ));
    // Navigator.push(context,
    //     CupertinoPageRoute(builder: (context) => const TomorrowPlanningPage()));
  }

  void _openNoTomorrowPlanPage() {
    //this function needs to change to create new goal
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const NoTomorrowPlanYetPage()));
  }

  void openEditEventPage() {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditEventPage(
                  updateEvents: _updateEvents,
                  // dataSource: _events,
                  // selectedEvent: _selectedAppointment,
                )));
  }

  void _goToMonthlyView() {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const MonthlyCalendarPage()));
  }

  void _updateEvents() {
    setState(() {});
  }

  void deleteEvent() async {
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
                child: Text('yes, delete'),
                onPressed: () async {
                  if (CalendarPage.selectedEvent != null) {
                    //first send server request
                    var url = Uri.parse('http://localhost:7343/calendar/' +
                        CalendarPage.selectedEvent!.id.toString());
                    var response = await http.delete(
                      url,
                    );
                    print('Response status: ${response.statusCode}');
                    print('Response body: ${response.body}');

                    if (response.statusCode == 200) {
                      CalendarPage.events.appointments!.removeAt(CalendarPage
                          .events.appointments!
                          .indexOf(CalendarPage.selectedEvent));
                      CalendarPage.events.notifyListeners(
                          CalendarDataSourceAction.remove,
                          <Event>[]..add(CalendarPage.selectedEvent!));
                      PlannerService.sharedInstance.user!.scheduledEvents =
                          CalendarPage.events.appointments! as List<Event>;
                      // PlannerService.sharedInstance.user.allEvents
                      //     .removeAt(idx);
                      // PlannerService.sharedInstance.user.allEventsMap
                      //     .remove(idx);
                      CalendarPage.selectedEvent = null;
                      setState(() {});
                      Navigator.pop(context);
                    } else {
                      //500 error, show an alert

                    }
                  }
                },
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('cancel'))
            ],
          );
        });
  }

  void startPlanningFromBacklog() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: "BacklogScheduling"),
        builder: (context) => ScheduleBacklogItemsPage(
            updateTomorrowEvents: _updateEvents, fromPage: "today"),
      ),
    );
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
                        child: const Text(
                            "Add item from my life's backlog to today's schedule")),
                    ElevatedButton(
                        onPressed: _openNewCalendarItemPage,
                        child: const Text("Create new task/event")),
                  ]),
              actions: <Widget>[]);
        });
  }

  void unscheduleEvent() async {
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
                          'http://localhost:7343/backlog/unscheduletask');
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

                      }
                    }
                  },
                  child: const Text('yes, unschedule')),
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
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      print(details.appointments![0].toString());
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
      print(CalendarPage.selectedEvent!.id);

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
                      child: new Text('edit')),
                  TextButton(
                      onPressed: () {
                        deleteEvent();
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
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Stack(
      children: [
        Image.asset(
          "assets/images/login_screens_background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            backgroundColor: Colors.transparent,

            title: Column(
              children: [
                Text(
                  "Today",
                  // style: GoogleFonts.roboto(
                  //   textStyle: const TextStyle(
                  //     color: Colors.white,
                  //   ),
                  // ),
                  style: TextStyle(color: Colors.white),
                ),
                // Image.asset(
                //   "assets/images/pink_planit_today.png",
                // ),
              ],
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.note_alt,
                color: Colors.white,
              ),
              tooltip: 'View this backlog item',
              onPressed: () {
                //setState(() {});
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const NotesPage(
                              fromPage: "Today",
                            )));
              },
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: 'View full calendar',
                onPressed: () {
                  _goToMonthlyView();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.next_week,
                  color: Colors.white,
                ),
                tooltip: 'Tomorrow',
                onPressed: () {
                  setState(() {
                    if (PlannerService
                        .sharedInstance.user!.didStartTomorrowPlanning) {
                      _openTomorrowSchedulePage();
                    } else {
                      _openNoTomorrowPlanPage();
                    }
                  });
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
              headerStyle: CalendarHeaderStyle(
                textStyle: TextStyle(color: Colors.white),
                // textAlign: TextAlign.center,
              ),
              view: CalendarView.day,
              onTap: calendarTapped,
              initialDisplayDate: DateTime.now(),
              dataSource: CalendarPage.events,
              cellBorderColor: Colors.white,
              timeSlotViewSettings: TimeSlotViewSettings(
                  timeInterval: Duration(minutes: 30),
                  timeFormat: 'h:mm',
                  timeTextStyle: TextStyle(
                    color: Colors.white,
                  )),
              //EventDataSource(PlannerService.sharedInstance.user.allEvents),
            ),
          ),

          floatingActionButton: FloatingActionButton(
            //onPressed: _openNewCalendarItemPage, _openNewCalendarItemDialog
            onPressed: _openNewCalendarItemDialog,
            tooltip: 'Create new event.',
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ), // This trailing comma makes auto-formatting nicer for build methods.
        )
      ],
    );
  }
}
