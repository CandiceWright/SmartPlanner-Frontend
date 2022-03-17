import 'package:flutter/material.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'monthly_calendar_page.dart';
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
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewEventPage(
                  updateEvents: _updateEvents,
                )));
  }

  void _goToMonthlyView() {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const MonthlyCalendarPage()));
  }

  void _updateEvents() {
    setState(() {});
  }

  List<Event> _getDataSource() {
    final List<Event> events = <Event>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    events.add(Event(
        id: 1,
        eventName: 'Conference',
        type: "Meeting",
        from: startTime,
        to: endTime,
        background: const Color(0xFFFF80b1),
        isAllDay: false));

    final DateTime startTime2 =
        DateTime(today.year, today.month, today.day, 13, 0, 0);
    final DateTime endTime2 = startTime2.add(const Duration(hours: 2));
    events.add(Event(
        id: 1,
        eventName: 'Conference',
        type: "Meeting",
        from: startTime2,
        to: endTime2,
        background: const Color(0xFFFF80b1),
        isAllDay: false));
    return events;
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
            // Text(
            //   DateFormat.yMMMd().format(DateTime.now()),
            //   style: Theme.of(context).textTheme.subtitle1,
            // ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'View this backlog item',
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
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),
      body: Container(
        child: SfCalendar(
          view: CalendarView.day,
          initialDisplayDate: DateTime.now(),
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
