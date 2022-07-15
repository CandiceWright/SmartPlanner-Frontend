import 'package:flutter/material.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/event_data_source.dart';
import 'new_event_page.dart';

class MonthlyCalendarPage extends StatefulWidget {
  const MonthlyCalendarPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MonthlyCalendarPage> createState() => _MonthlyCalendarPageState();
}

class _MonthlyCalendarPageState extends State<MonthlyCalendarPage> {
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
                  fromPage: "monthly_calendar",
                )));
  }

  void _updateEvents() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // List<Widget> backlogListView = buildBacklogListView();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Column(
          children: const [
            Text(
              "Calendar",
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

        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),
      body: Container(
        child: SfCalendar(
          view: CalendarView.month,
          dataSource: EventDataSource(
              PlannerService.sharedInstance.user!.scheduledEvents),
          viewNavigationMode: ViewNavigationMode.snap,
          monthViewSettings: MonthViewSettings(showAgenda: true),
          timeSlotViewSettings: const TimeSlotViewSettings(
              minimumAppointmentDuration: Duration(minutes: 60)),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openNewCalendarItemPage,
        tooltip: 'Create new task.',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
