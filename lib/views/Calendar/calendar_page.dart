//library event_calendar;
//part 'edit_event_page.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Calendar/new_free_flow_event.dart';
import 'package:practice_planner/views/Calendar/notes_page.dart';
import 'package:practice_planner/views/Calendar/schedule_backlog_items_page.dart';
import 'package:practice_planner/views/Calendar/select_backlog_items_page.dart';
import 'package:practice_planner/views/Calendar/today_schedule_page.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../models/backlog_map_ref.dart';
import '../Backlog/edit_task_page.dart';
import '../Backlog/new_task_page.dart';
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

class CalendarPage extends StatefulWidget {
  //final Function updateEvents;
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
  //DateTime _selectedDate = DateTime.now();
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  CalendarController calController = CalendarController();
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();
  Event? selectedEvent;
  EventDataSource events =
      EventDataSource(PlannerService.sharedInstance.user!.scheduledEvents);
  final List<bool> _selectedPageView = <bool>[true, false];
  List<BacklogMapRef> todaysTasks = PlannerService
          .sharedInstance.user!.scheduledBacklogItemsMap
          .containsKey(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day))
      ? List.from(PlannerService.sharedInstance.user!.scheduledBacklogItemsMap[
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)]!)
      : [];
  // DateTime thisDay =
  //     DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int selectedMode = 0;

  @override
  void initState() {
    super.initState();
    // CalendarPage.events =
    //     EventDataSource(PlannerService.sharedInstance.user!.scheduledEvents);
    //calController.displayDate = DateTime.now();
    _dateRangePickerController.selectedDate = _selectedDate;
  }

  void updatePotentialCandidates() {
    print("I am in update potential candidates");
    print(_selectedDate.toString());
    setState(() {
      //todaysTasks.addAll(selectedBacklogItems);
      // DateTime selectedDay =
      //     DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      todaysTasks = List.from(PlannerService
          .sharedInstance.user!.scheduledBacklogItemsMap[_selectedDate]!);
    });
  }

  void _openNewCalendarItemPage() {
    //this function needs to change to create new goal
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewEventPage(
                  selectedDate: _selectedDate,
                  updateEvents: _updateEvents,
                  fromPage: "daily_calendar",
                )));
  }

  void _openNewFreeFlowSessionPage() {
    //this function needs to change to create new goal
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewFreeFlowEventPage(
                  selectedDate: _selectedDate,
                  updateEvents: _updateEvents,
                  fromPage: "daily_calendar",
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
                  selectedEvent: selectedEvent,
                )));
  }

  void _goToMonthlyView() {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const MonthlyCalendarPage()));
  }

  void _updateEvents() {
    setState(() {
      events =
          EventDataSource(PlannerService.sharedInstance.user!.scheduledEvents);
      selectedEvent = null;
    });
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
                  if (selectedEvent != null) {
                    //first send server request
                    var url = Uri.parse(
                        PlannerService.sharedInstance.serverUrl +
                            '/calendar/' +
                            selectedEvent!.id.toString());
                    var response = await http.delete(
                      url,
                    );
                    //print('Response status: ${response.statusCode}');
                    //print('Response body: ${response.body}');

                    if (response.statusCode == 200) {
                      events.appointments!.removeAt(
                          events.appointments!.indexOf(selectedEvent));
                      events.notifyListeners(CalendarDataSourceAction.remove,
                          <Event>[]..add(selectedEvent!));
                      PlannerService.sharedInstance.user!.scheduledEvents =
                          events.appointments! as List<Event>;
                      // PlannerService.sharedInstance.user.allEvents
                      //     .removeAt(idx);
                      // PlannerService.sharedInstance.user.allEventsMap
                      //     .remove(idx);
                      selectedEvent = null;
                      setState(() {});
                      Navigator.pop(context);
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
          updateTomorrowEvents: _updateEvents,
          fromPage: DateFormat.yMMMd()
              .format(_dateRangePickerController.selectedDate!),
          calendarDate: _dateRangePickerController.selectedDate!,
        ),
      ),
    );
  }

  void _openNewCalendarItemDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text(
                "Add to Schedule",
                textAlign: TextAlign.center,
              ),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _openNewCalendarItemPage,
                    child: Text("New Event"),
                  ),
                  TextButton(
                    onPressed: startPlanningFromBacklog,
                    child: Text("Backlog Item"),
                  ),
                  TextButton(
                    onPressed: _openNewFreeFlowSessionPage,
                    child: Text("Free Flow Session"),
                  )
                ],
              ),
              actions: const <Widget>[]);
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
                    if (selectedEvent != null) {
                      var body = {
                        'eventId': selectedEvent!.id,
                        'taskId': selectedEvent!.taskIdRef
                      };
                      String bodyF = jsonEncode(body);
                      //print(bodyF);

                      var url = Uri.parse(
                          PlannerService.sharedInstance.serverUrl +
                              '/calendar/unscheduletask');
                      var response = await http.post(url,
                          headers: {"Content-Type": "application/json"},
                          body: bodyF);
                      //print('Response status: ${response.statusCode}');
                      //print('Response body: ${response.body}');

                      if (response.statusCode == 200) {
                        //delete event & unschedule backlog item
                        //if (CalendarPage.selectedEvent != null) {
                        events.appointments!.removeAt(
                            events.appointments!.indexOf(selectedEvent));
                        events.notifyListeners(CalendarDataSourceAction.remove,
                            <Event>[selectedEvent!]);

                        var backlogItemRef = selectedEvent!.backlogMapRef;

                        setState(() {
                          PlannerService.sharedInstance.user!.scheduledEvents =
                              events.appointments! as List<Event>;
                          PlannerService
                              .sharedInstance
                              .user!
                              .backlogMap[backlogItemRef!.categoryName]![
                                  backlogItemRef.arrayIdx]
                              .calendarItemRef = null;
                          selectedEvent = null;
                        });
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
      //print(details.appointments![0].toString());
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
      selectedEvent = appointmentDetails;
      //TodaySchedulePage.selectedEvent = appointmentDetails;

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

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _dateRangePickerController.selectedDate =
          viewChangedDetails.visibleDates[0];
      _dateRangePickerController.displayDate =
          viewChangedDetails.visibleDates[0];
    });
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    //print(_dateRangePickerController.selectedDate.toString());
    print("I am in date selection changed");
    print(args.value);
    // setState(() {
    //   //_selectedDate = _dateRangePickerController.selectedDate!;
    //   // _selectedDate =
    //   //     DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    //   _dateRangePickerController.selectedDate = args.value;
    //   _selectedDate =
    //       DateTime(args.value.year, args.value.month, args.value.day);

    //   //todaysTasks.addAll(selectedBacklogItems);
    //   todaysTasks = List.from(PlannerService
    //       .sharedInstance.user!.scheduledBacklogItemsMap[_selectedDate]!);
    // });
    setState(() {
      _selectedDate = _dateRangePickerController.selectedDate!;
    });
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        calController.displayDate = args.value;
      });
    });
  }

  openEditBacklogItemPage(int idx, String category) {
    //print(PlannerService.sharedInstance.user!.backlogMap[category]![idx]);
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditTaskPage(
                  updateBacklog: _updateBacklog,
                  id: idx,
                  category: category,
                )));
  }

  void _updateBacklog() {
    setState(() {});
  }

  Widget buildScheduleView() {
    return Column(
      children: [
        //was Expanded
        Container(
          //color: Colors.white,
          child: Column(children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child:
                            // Text(
                            //   DateFormat.MMM()
                            //       .format(_dateRangePickerController.selectedDate!),
                            Text(
                          DateFormat.MMM().format(_selectedDate),
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .fontSize),
                          // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                        ),
                      ),
                      Text(
                        _selectedDate.year.toString(),
                        // _dateRangePickerController.selectedDate!.year
                        //     .toString(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize),
                        // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                      )
                    ]),
                  ),
                ],
              ),
            ),
            Container(
              height: 100,
              child: SfDateRangePicker(
                backgroundColor: Colors.white,
                headerHeight: 0,
                controller: _dateRangePickerController,
                //showNavigationArrow: true,
                allowViewNavigation: false,
                monthViewSettings:
                    DateRangePickerMonthViewSettings(numberOfWeeksInView: 1),
                onSelectionChanged: selectionChanged,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ToggleButtons(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Tasks'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Schedule'),
                  ),
                ],
                direction: Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedPageView.length; i++) {
                      _selectedPageView[i] = i == index;
                    }
                    selectedMode = index;
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Theme.of(context).primaryColor,
                selectedColor: Colors.white,
                fillColor: Theme.of(context).primaryColor.withAlpha(100),
                color: Theme.of(context).primaryColor,
                isSelected: _selectedPageView,
              ),
            ),
          ]),
        ),
        Expanded(
          child: SfCalendar(
            headerHeight: 0,
            viewHeaderHeight: 0,
            //showDatePickerButton: true,
            controller: calController,
            onViewChanged: viewChanged,

            //cellBorderColor: Colors.transparent,
            view: CalendarView.day,
            onTap: calendarTapped,

            initialDisplayDate: DateTime.now(),
            dataSource: events,
            timeSlotViewSettings: const TimeSlotViewSettings(
              //timeInterval: Duration(hours: 1),
              timeIntervalHeight: 120,
              //timeIntervalHeight: -1,
            ),
            allowAppointmentResize: true,
            appointmentBuilder:
                (BuildContext context, CalendarAppointmentDetails details) {
              final Event meeting = details.appointments.first;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                //margin: EdgeInsets.all(8),
                width: details.bounds.width,
                height: details.bounds.height,
                // color: meeting.category.color,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: PlannerService
                                    .sharedInstance.user!.profileImage ==
                                "assets/images/profile_pic_icon.png"
                            ? FittedBox(
                                fit: BoxFit.contain,
                                child: Card(
                                  child: CircleAvatar(
                                    // // backgroundImage: AssetImage(
                                    //     PlannerService.sharedInstance.user!.profileImage),
                                    backgroundImage: AssetImage(PlannerService
                                        .sharedInstance.user!.profileImage),
                                    //radius: 30,
                                  ),
                                  shape: CircleBorder(
                                    //borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                      width: 5,
                                      color: meeting.type == "freeflow"
                                          ? Colors.transparent
                                          : meeting
                                              .category!.color, //<-- SEE HERE
                                    ),
                                  ),
                                )
                                // CircleAvatar(
                                //   // // backgroundImage: AssetImage(
                                //   //     PlannerService.sharedInstance.user!.profileImage),
                                //   backgroundImage: AssetImage(PlannerService
                                //       .sharedInstance.user!.profileImage),
                                //   //radius: 30,
                                // ),
                                )
                            : FittedBox(
                                fit: BoxFit.contain,
                                // child: ClipOval(
                                //   child: Image.network(
                                //       PlannerService
                                //           .sharedInstance.user!.profileImage,
                                //       fit: BoxFit.fill),
                                // ),
                                child: Card(
                                  child: CircleAvatar(
                                    // // backgroundImage: AssetImage(
                                    //     PlannerService.sharedInstance.user!.profileImage),
                                    backgroundImage: NetworkImage(PlannerService
                                        .sharedInstance.user!.profileImage),
                                    //radius: 30,
                                  ),
                                  shape: CircleBorder(
                                    //borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                      width: 5,
                                      color: meeting.type == "freeflow"
                                          ? Colors.transparent
                                          : meeting
                                              .category!.color, //<-- SEE HERE
                                    ),
                                  ),
                                ),
                                // CircleAvatar(
                                //   // // backgroundImage: AssetImage(
                                //   //     PlannerService.sharedInstance.user!.profileImage),
                                //   backgroundImage: NetworkImage(PlannerService
                                //       .sharedInstance.user!.profileImage),
                                //   //radius: 30,
                                // ),
                              ),
                      ),
                      Expanded(
                        // child: FittedBox(
                        //   fit: BoxFit.contain,
                        child: SingleChildScrollView(
                          //was a list view
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Expanded(
                              // FittedBox(
                              //   fit: BoxFit.contain,
                              //child:
                              Text(
                                DateFormat('h:mm').format(meeting.start) +
                                    " - " +
                                    DateFormat('h:mm').format(meeting.end),
                                // DateFormat.Hm().format(meeting.start.toLocal()) +
                                //     " - " +
                                //     DateFormat.Hm().format(meeting.end.toLocal()),
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.left,
                              ),
                              //),
                              FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  meeting.description,
                                  style: const TextStyle(
                                      //color: Colors.white,
                                      // fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expanded(
                      //   child: Checkbox(
                      //     side: const BorderSide(color: Colors.grey),
                      //     //value: meeting.isAccomplished,
                      //     value: events
                      //         .appointments![
                      //             events.appointments!.indexOf(meeting)]
                      //         .isAccomplished,
                      //     shape: const CircleBorder(),
                      //     onChanged: (bool? value) async {
                      //       //print(value);
                      //       //setState(() async {
                      //       //update on server and then update locally
                      //       //meeting.isAccomplished = value;
                      //       int id = meeting.id!;
                      //       var body = {
                      //         'eventId': id,
                      //         'eventStatus': value,
                      //       };
                      //       String bodyF = jsonEncode(body);
                      //       //print(bodyF);

                      //       var url = Uri.parse(
                      //           PlannerService.sharedInstance.serverUrl +
                      //               '/user/calendar/event/status');
                      //       var response = await http.patch(url,
                      //           headers: {"Content-Type": "application/json"},
                      //           body: bodyF);
                      //       //print('Response status: ${response.statusCode}');
                      //       //print('Response body: ${response.body}');

                      //       if (response.statusCode == 200) {
                      //         setState(() {
                      //           events
                      //               .appointments![
                      //                   events.appointments!.indexOf(meeting)]
                      //               .isAccomplished = value;
                      //           PlannerService
                      //                   .sharedInstance.user!.scheduledEvents =
                      //               events.appointments! as List<Event>;
                      //           //widget.updateEvents();
                      //         });
                      //       } else {
                      //         //500 error, show an alert
                      //         showDialog(
                      //             context: context,
                      //             builder: (context) {
                      //               return AlertDialog(
                      //                 title: Text(
                      //                     'Oops! Looks like something went wrong. Please try again.'),
                      //                 actions: <Widget>[
                      //                   TextButton(
                      //                     child: Text('OK'),
                      //                     onPressed: () {
                      //                       Navigator.of(context).pop();
                      //                     },
                      //                   )
                      //                 ],
                      //               );
                      //             });
                      //       }

                      //       //PlannerService.sharedInstance.user.f
                      //       //});
                      //     },
                      //   ),
                      // )
                    ],
                  ),
                ),
              );
            },
            //EventDataSource(PlannerService.sharedInstance.user.allEvents),
          ),
        ),
      ],
    );
  }

  Widget buildTasksView() {
    return Column(
      children: [
        //was Expanded
        Container(
          //color: Colors.white,
          child: Column(children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child:
                            // Text(
                            //   DateFormat.MMM()
                            //       .format(_dateRangePickerController.selectedDate!),
                            Text(
                          DateFormat.MMM().format(_selectedDate),
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .fontSize),
                          // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                        ),
                      ),
                      Text(
                        _selectedDate.year.toString(),
                        // _dateRangePickerController.selectedDate!.year
                        //     .toString(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize),
                        // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                      )
                    ]),
                  ),
                ],
              ),
            ),
            Container(
              height: 100,
              child: SfDateRangePicker(
                backgroundColor: Colors.white,
                headerHeight: 0,
                controller: _dateRangePickerController,
                //showNavigationArrow: true,
                allowViewNavigation: false,
                monthViewSettings:
                    DateRangePickerMonthViewSettings(numberOfWeeksInView: 1),
                onSelectionChanged: selectionChanged,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ToggleButtons(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Tasks'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Schedule'),
                  ),
                ],
                direction: Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedPageView.length; i++) {
                      _selectedPageView[i] = i == index;
                    }
                    selectedMode = index;
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Theme.of(context).primaryColor,
                selectedColor: Colors.white,
                fillColor: Theme.of(context).primaryColor.withAlpha(100),
                color: Theme.of(context).primaryColor,
                isSelected: _selectedPageView,
              ),
            ),
          ]),
        ),
        Expanded(
          //height: 150,
          //was a column

          child: !PlannerService.sharedInstance.user!.scheduledBacklogItemsMap
                      .containsKey(_selectedDate) ||
                  PlannerService.sharedInstance.user!
                      .scheduledBacklogItemsMap[_selectedDate]!.isEmpty
              //child: todaysTasks.length == 0
              ? Container(
                  alignment: Alignment.center,
                  child: Text("No Tasks Yet. Add tasks below."),
                )
              : ListView(
                  children: List.generate(
                      PlannerService
                          .sharedInstance
                          .user!
                          .scheduledBacklogItemsMap[_selectedDate]!
                          .length, (int index) {
                    return GestureDetector(
                      onTap: () {
                        //show dialog
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  _selectedDate]![index]
                                              .categoryName]![
                                          PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  _selectedDate]![index]
                                              .arrayIdx]
                                      .description,
                                  textAlign: TextAlign.center,
                                ),

                                content:
                                    //Card(
                                    //child: Container(
                                    //child: Column(
                                    Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Complete by " +
                                            DateFormat.yMMMd().format(PlannerService
                                                .sharedInstance
                                                .user!
                                                .backlogMap[
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            _selectedDate]![
                                                            index]
                                                        .categoryName]![
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            _selectedDate]![
                                                            index]
                                                        .arrayIdx]
                                                .completeBy!),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      _selectedDate]![index]
                                                  .categoryName]![
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      _selectedDate]![index]
                                                  .arrayIdx]
                                          .notes),
                                    ),
                                  ],
                                ),
                                //),
                                //),
                                actions: <Widget>[
                                  TextButton(
                                    child: new Text('edit'),
                                    onPressed: () {
                                      openEditBacklogItemPage(
                                          PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  _selectedDate]![index]
                                              .arrayIdx,
                                          PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  _selectedDate]![index]
                                              .categoryName);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('remove'),
                                    onPressed: () async {
                                      print("I am running remove from");

                                      //first check of the item is scheduled on calendar, if so, show a dialog
                                      if (PlannerService
                                              .sharedInstance
                                              .user!
                                              .backlogMap[PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .scheduledBacklogItemsMap[
                                                          _selectedDate]![index]
                                                      .categoryName]![
                                                  PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .scheduledBacklogItemsMap[
                                                          _selectedDate]![index]
                                                      .arrayIdx]
                                              .calendarItemRef !=
                                          null) {
                                        //this would be null if not on calendar
                                        Navigator.of(context).pop();
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "This item is scheduled on your calendar. Unschedule it on your calendar first. Then you will be able to remove from task list."),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('Ok'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  )
                                                ],
                                              );
                                            });
                                      } else {
//unschedule on server, just remove scheduled date from backlog id
                                        var body = {
                                          'taskId': PlannerService
                                              .sharedInstance
                                              .user!
                                              .backlogMap[PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .scheduledBacklogItemsMap[
                                                          _selectedDate]![index]
                                                      .categoryName]![
                                                  PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .scheduledBacklogItemsMap[
                                                          _selectedDate]![index]
                                                      .arrayIdx]
                                              .id
                                        };
                                        String bodyF = jsonEncode(body);
                                        //print(bodyF);

                                        var url = Uri.parse(PlannerService
                                                .sharedInstance.serverUrl +
                                            '/backlog/unscheduletask');
                                        var response = await http.post(url,
                                            headers: {
                                              "Content-Type": "application/json"
                                            },
                                            body: bodyF);
                                        //print('Response status: ${response.statusCode}');
                                        //print('Response body: ${response.body}');

                                        if (response.statusCode == 200) {
                                          print("unscheduling successful");
                                          //setState(() {});
                                          setState(() {
                                            PlannerService
                                                .sharedInstance
                                                .user!
                                                .backlogMap[
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            _selectedDate]![
                                                            index]
                                                        .categoryName]![
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            _selectedDate]![
                                                            index]
                                                        .arrayIdx]
                                                .scheduledDate = null;

                                            PlannerService
                                                .sharedInstance
                                                .user!
                                                .scheduledBacklogItemsMap[
                                                    _selectedDate]!
                                                .removeAt(index);

                                            todaysTasks = List.from(PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .scheduledBacklogItemsMap[
                                                _selectedDate]!);
                                          });
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
                                                        Navigator.of(context)
                                                            .pop();
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
                                      child: new Text('close'))
                                ],
                              );
                            });
                      },
                      child: Card(
                        margin: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: PlannerService
                                    .sharedInstance
                                    .user!
                                    .backlogMap[PlannerService.sharedInstance.user!.scheduledBacklogItemsMap[_selectedDate]![index].categoryName]![
                                        PlannerService
                                            .sharedInstance
                                            .user!
                                            .scheduledBacklogItemsMap[
                                                _selectedDate]![index]
                                            .arrayIdx]
                                    .status ==
                                "notStarted"
                            ? Colors.grey.shade100
                            : (PlannerService
                                        .sharedInstance
                                        .user!
                                        .backlogMap[PlannerService
                                                .sharedInstance
                                                .user!
                                                .scheduledBacklogItemsMap[
                                                    _selectedDate]![index]
                                                .categoryName]![
                                            PlannerService
                                                .sharedInstance
                                                .user!
                                                .scheduledBacklogItemsMap[_selectedDate]![index]
                                                .arrayIdx]
                                        .status ==
                                    "complete"
                                ? Colors.green.shade200
                                : Colors.yellow.shade200),
                        elevation: 5,
                        child: ListTile(
                          leading: Icon(
                            Icons.circle,
                            color: PlannerService
                                .sharedInstance
                                .user!
                                .backlogMap[PlannerService
                                        .sharedInstance
                                        .user!
                                        .scheduledBacklogItemsMap[
                                            _selectedDate]![index]
                                        .categoryName]![
                                    PlannerService
                                        .sharedInstance
                                        .user!
                                        .scheduledBacklogItemsMap[
                                            _selectedDate]![index]
                                        .arrayIdx]
                                .category
                                .color,
                          ),
                          title: Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              PlannerService
                                  .sharedInstance
                                  .user!
                                  .backlogMap[PlannerService
                                          .sharedInstance
                                          .user!
                                          .scheduledBacklogItemsMap[
                                              _selectedDate]![index]
                                          .categoryName]![
                                      PlannerService
                                          .sharedInstance
                                          .user!
                                          .scheduledBacklogItemsMap[
                                              _selectedDate]![index]
                                          .arrayIdx]
                                  .description,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          trailing: Checkbox(
                            value: PlannerService
                                .sharedInstance
                                .user!
                                .backlogMap[PlannerService
                                        .sharedInstance
                                        .user!
                                        .scheduledBacklogItemsMap[
                                            _selectedDate]![index]
                                        .categoryName]![
                                    PlannerService
                                        .sharedInstance
                                        .user!
                                        .scheduledBacklogItemsMap[
                                            _selectedDate]![index]
                                        .arrayIdx]
                                .isComplete,
                            shape: const CircleBorder(),
                            onChanged: (bool? value) {
                              //print(value);
                              setState(() {
                                PlannerService
                                    .sharedInstance
                                    .user!
                                    .backlogMap[PlannerService
                                            .sharedInstance
                                            .user!
                                            .scheduledBacklogItemsMap[
                                                _selectedDate]![index]
                                            .categoryName]![
                                        PlannerService
                                            .sharedInstance
                                            .user!
                                            .scheduledBacklogItemsMap[
                                                _selectedDate]![index]
                                            .arrayIdx]
                                    .isComplete = value;

                                //_value = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => SelectBacklogItemsPage(
                              date: _selectedDate,
                              updatePotentialCandidates:
                                  updatePotentialCandidates)));
                },
                child: Text("Add Backlog Items")),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => NewTaskPage(
                                updateBacklog: updatePotentialCandidates,
                                selectdDate: _selectedDate,
                              )));
                },
                child: Text("Create New Task"))
          ],
        ),
      ],
    );
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
      //backgroundColor: Colors.transparent,
      backgroundColor: Colors.white,

      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.transparent,
        title: const Text("Daily", style: TextStyle(color: Colors.white)),

        automaticallyImplyLeading: false,
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
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'View full calendar',
            onPressed: () {
              _goToMonthlyView();
            },
          ),
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),

      body: selectedMode == 0 ? buildTasksView() : buildScheduleView(),

      floatingActionButton: selectedMode == 1
          ? FloatingActionButton(
              //onPressed: _openNewCalendarItemPage, _openNewCalendarItemDialog
              onPressed: _openNewCalendarItemDialog,
              tooltip: 'Create new event.',
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : Container(), // This trailing comma makes auto-formatting nicer for build methods.
    );
    //],
    //);
  }
}
