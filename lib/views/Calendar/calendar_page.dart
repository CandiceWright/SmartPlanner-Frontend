import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Calendar/no_tomorrow_plan_yet_age.dart';
import 'package:practice_planner/views/Calendar/notes_page.dart';
import 'package:practice_planner/views/Calendar/schedule_backlog_items_page.dart';
import 'package:practice_planner/views/Calendar/tomorrow_planning_page.dart';
import 'package:practice_planner/views/Calendar/tomorrow_schedule_page.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';

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
}

class _CalendarPageState extends State<CalendarPage> {
  //bool _value = false;
  //var backlog = PlannerService.sharedInstance.user.backlog;

  @override
  void initState() {
    super.initState();
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
    //this function needs to change to create new goal
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     settings: const RouteSettings(name: "/tomorrow"),
    //     builder: (context) => const TomorrowPlanningPage(),
    //   ),
    // );
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

  void deleteEvent(int idx) {
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
                  onPressed: () {
                    PlannerService.sharedInstance.user.allEvents.removeAt(idx);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Text('yes, delete')),
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
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (context) => const ScheduleBacklogItemsPage()));
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
                      deleteEvent(appointmentDetails.id);
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
            const Text("Today"),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.note_alt),
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
            icon: const Icon(Icons.next_week),
            tooltip: 'Tomorrow',
            onPressed: () {
              setState(() {
                if (PlannerService
                    .sharedInstance.user.didStartTomorrowPlanning) {
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
          view: CalendarView.day,
          onTap: calendarTapped,
          initialDisplayDate: DateTime.now(),
          dataSource:
              EventDataSource(PlannerService.sharedInstance.user.allEvents),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        //onPressed: _openNewCalendarItemPage, _openNewCalendarItemDialog
        onPressed: _openNewCalendarItemDialog,
        tooltip: 'Create new event.',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
