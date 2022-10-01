import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/views/Calendar/calendar_page.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Calendar/notes_page.dart';
import 'package:practice_planner/views/Calendar/schedule_backlog_items_page.dart';
import 'package:practice_planner/views/Calendar/select_backlog_items_page.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../models/backlog_item.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:date_picker_timeline/date_picker_timeline.dart';

//part 'edit_event_page.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<TodayPage> createState() => _TodayPageState();
  static Event? selectedEvent;
  static late EventDataSource events;
  //EventDataSource(PlannerService.sharedInstance.user.allEvents);
}

class _TodayPageState extends State<TodayPage> {
  DateTime _selectedDate = DateTime.now();
  CalendarController calController = CalendarController();
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();
  final List<bool> _selectedPageView = <bool>[true, false];
  String selectedMode = "structured";
  List<BacklogMapRef> todaysTasks = [];

  @override
  void initState() {
    super.initState();
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

  void _goToFullCalendarView() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => CalendarPage(
                  updateEvents: _updateEvents,
                )));
  }

  _updateEvents() {
    setState(() {});
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _dateRangePickerController.selectedDate =
          viewChangedDetails.visibleDates[0];
      _dateRangePickerController.displayDate =
          viewChangedDetails.visibleDates[0];
    });
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      calController.displayDate = args.value;
    });
  }

  void updatePotentialCandidates(List<BacklogMapRef> selectedBacklogItems) {
    setState(() {
      todaysTasks.addAll(selectedBacklogItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // return Stack(
    //   children: [
    //     Image.asset(
    //       PlannerService.sharedInstance.user!.spaceImage,
    //       height: MediaQuery.of(context).size.height,
    //       width: MediaQuery.of(context).size.width,
    //       fit: BoxFit.cover,
    //     ),
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.transparent,

        title: const Text("Today", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    PlannerService.sharedInstance.user!.spaceImage,
                  ),
                  fit: BoxFit.fill)),
        ),

        automaticallyImplyLeading: false,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.calendar_month_rounded),
          //   tooltip: 'View full calendar',
          //   onPressed: () {
          //     _goToFullCalendarView();
          //   },
          // ),
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top -
            kBottomNavigationBarHeight,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        //Padding(
                        //padding: EdgeInsets.only(right: 8),
                        //child:
                        Text(
                          DateFormat.MMM().format(_selectedDate),
                          // _selectedDate.toString("MMMM"),
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize,
                          ),
                          // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                        ),
                        //),
                        Text(
                          " " + _selectedDate.day.toString(),
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  "Free Flowing Productivity",
                  // _selectedDate.toString("MMMM"),
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                  ),
                  // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/images/sunrise.png',
                    // width: 20,
                    // height: 20,
                  ),
                  title: LinearProgressIndicator(
                    value: ((DateTime.now().hour) + 1) / 24,
                    backgroundColor: Colors.grey.shade400,
                    color: Theme.of(context).primaryColor,
                  ),
                  trailing: Image.asset(
                    'assets/images/night.png',
                    // width: 20,
                    // height: 20,
                  ),
                ),
              ]),
            ),
            Expanded(
                child: Column(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("Show Today's Scheduled Events"),
                ),
                Container(
                  child: Column(children: [
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Maximum Effort will always result in getting the optimal amount of things done. So don't focus on how many things you get done while you're free flowing, focus on maximizing the amount of effort you put in.",
                        textAlign: TextAlign.center,
                      ),
                    )
                  ]),
                ),
                Card(
                  margin: EdgeInsets.all(5),
                  child: Column(children: [
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Tasks to Work on Today",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: List.generate(todaysTasks.length, (int index) {
                        return GestureDetector(
                            onLongPress: () {},
                            child: Card(
                              margin: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.grey.shade100,
                              elevation: 5,
                              child: ListTile(
                                leading: Icon(
                                  Icons.circle,
                                  color: PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[
                                          todaysTasks[index].categoryName]![
                                          todaysTasks[index].arrayIdx]
                                      .category
                                      .color,
                                ),
                                title: Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    PlannerService
                                        .sharedInstance
                                        .user!
                                        .backlogMap[
                                            todaysTasks[index].categoryName]![
                                            todaysTasks[index].arrayIdx]
                                        .description,
                                    // style: const TextStyle(
                                    //     // color: PlannerService.sharedInstance.user!
                                    //     //     .backlogMap[key]![i].category.color,
                                    //     color: Colors.black,
                                    //     fontSize: 16,
                                    //     fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                trailing: Checkbox(
                                  value: PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[
                                          todaysTasks[index].categoryName]![
                                          todaysTasks[index].arrayIdx]
                                      .isComplete,
                                  shape: const CircleBorder(),
                                  onChanged: (bool? value) {
                                    //print(value);
                                    setState(() {
                                      PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[
                                              todaysTasks[index].categoryName]![
                                              todaysTasks[index].arrayIdx]
                                          .isComplete = value;

                                      //_value = value!;
                                    });
                                  },
                                ),
                                // subtitle: Text(
                                //   "Complete by " +
                                //       DateFormat.yMMMd().format(PlannerService
                                //           .sharedInstance
                                //           .user!
                                //           .backlogMap[
                                //               todaysTasks[index].categoryName]![
                                //               todaysTasks[index].arrayIdx]
                                //           .completeBy!),
                                //   textAlign: TextAlign.center,
                                // ),
                              ),
                            ));
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          SelectBacklogItemsPage(
                                              date: DateTime.now(),
                                              updatePotentialCandidates:
                                                  updatePotentialCandidates)));
                            },
                            child: Text("Add Backlog Items")),
                        TextButton(
                            onPressed: () {}, child: Text("Create New Task"))
                      ],
                    )
                  ]),
                ),
                Card(
                  margin: EdgeInsets.all(10),
                  color: Colors.white,
                  elevation: 5,
                  child: Column(children: const [
                    Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        "Drag and Drop an item here to start free flowing.",
                        // style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                ),
                ElevatedButton(
                    onPressed: () {},
                    child: Text("Start Free Flow Productivity"))
              ],
            )),
          ],
        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
    //],
    //);
  }
}
