import 'dart:async';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/models/draggable_task_info.dart';
import 'package:practice_planner/views/Calendar/calendar_page.dart';
import 'package:practice_planner/views/Calendar/edit_free_flow_event.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Calendar/notes_page.dart';
import 'package:practice_planner/views/Calendar/schedule_backlog_items_page.dart';
import 'package:practice_planner/views/Calendar/select_backlog_items_page.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../models/backlog_item.dart';
import '../Backlog/edit_task_page.dart';
import '../Backlog/new_task_page.dart';
import '../Subscription/subscription_page.dart';
import '../Subscription/subscription_page_no_free_trial.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:date_picker_timeline/date_picker_timeline.dart';

import 'new_free_flow_event.dart';

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
  final List<bool> _selectedPageView = <bool>[true, false, false];
  //String selectedMode = "structured";
  List<BacklogMapRef> todaysTasks = PlannerService
          .sharedInstance.user!.scheduledBacklogItemsMap
          .containsKey(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day))
      ? List.from(PlannerService.sharedInstance.user!.scheduledBacklogItemsMap[
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)]!)
      : [];
  //List<BacklogMapRef> todaysTasks = [];
  BacklogMapRef? currentTask;
  bool currentTaskSet = false;
  bool taskAccepted = false;
  Color dragTargetContainerColor = Colors.white;
  int selectedMode = 0;
  //Duration freeFlowSessionDuration = Duration(hours: 2, minutes: 30);
  Duration freeFlowSessionDuration = Duration();
  DateTime thisDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Timer? timer;
  bool freeFlowSessionStarted = false;
  bool freeFlowSessionEnded = false;
  bool freeFlowSessionNeedsToBeEnded = false;
  int sessionHours = 0;
  int sessionMins = 0;
  Event? selectedEvent;
  EventDataSource events =
      EventDataSource(PlannerService.sharedInstance.user!.scheduledEvents);

  @override
  void initState() {
    super.initState();
    if (PlannerService.sharedInstance.user!.currentFreeFlowSessionEnds !=
        null) {
      if (DateTime.now().isBefore(
          PlannerService.sharedInstance.user!.currentFreeFlowSessionEnds!)) {
        print("free flow session in progress");
        //still ongoing
        //a session that hasn't been ended
        freeFlowSessionStarted = true;
        freeFlowSessionDuration = PlannerService
            .sharedInstance.user!.currentFreeFlowSessionEnds!
            .difference(DateTime.now());

        if (PlannerService.sharedInstance.user!.currentTaskWorkingOn != null) {
          currentTaskSet = true;
          currentTask =
              PlannerService.sharedInstance.user!.currentTaskWorkingOn!;
          //need to remove this task from todays tasks
          todaysTasks.remove(currentTask);
        }
        startTimer();
      } else {
        print("free flow session ended");
        freeFlowSessionDuration = PlannerService
            .sharedInstance.user!.currentFreeFlowSessionEnds!
            .difference(DateTime.now());
        freeFlowSessionNeedsToBeEnded = true;
        //endFreeFlowSession();
        //session ended

      }
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  endFreeFlowSession() {
    if (!currentTaskSet) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes =
          twoDigits(freeFlowSessionDuration.inMinutes.remainder(60));
      final hours = twoDigits(freeFlowSessionDuration.inHours.remainder(60));
      if (freeFlowSessionDuration.inMinutes <= 0) {
        //Show an alert that says "Congrats!" You completed x hours and y minutes of free flowing
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Congrats!"),
              alignment: Alignment.center,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: const Text("Your free flow seession is complete. "),
              actions: <Widget>[
                TextButton(
                  child: Text('Done!'),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      freeFlowSessionStarted = false;
                      freeFlowSessionEnded = true;
                      freeFlowSessionDuration = Duration();
                      PlannerService.sharedInstance.user!
                          .currentFreeFlowSessionEnds = null;
                      timer!.cancel();
                    });
                    var body = {
                      'userId': PlannerService.sharedInstance.user!.id,
                      'action': "end",
                    };
                    String bodyF = jsonEncode(body);
                    //print(bodyF);

                    var url = Uri.parse(
                        PlannerService.sharedInstance.serverUrl +
                            '/user/freeflow');
                    var response = await http.patch(url,
                        headers: {"Content-Type": "application/json"},
                        body: bodyF);
                    //print('Response status: ${response.statusCode}');
                    //print('Response body: ${response.body}');

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop();
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
                  },
                )
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("There's still time..."),
              alignment: Alignment.center,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: const Text(
                  "Are you sure you want to end your free flow session early?"),
              actions: <Widget>[
                TextButton(
                  child: Text('Yes'),
                  onPressed: () async {
                    setState(() {
                      freeFlowSessionStarted = false;
                      freeFlowSessionEnded = true;
                      freeFlowSessionDuration = Duration();
                      PlannerService.sharedInstance.user!
                          .currentFreeFlowSessionEnds = null;
                      timer!.cancel();
                    });
                    var body = {
                      'userId': PlannerService.sharedInstance.user!.id,
                      'action': "end",
                    };
                    String bodyF = jsonEncode(body);
                    //print(bodyF);

                    var url = Uri.parse(
                        PlannerService.sharedInstance.serverUrl +
                            '/user/freeflow');
                    var response = await http.patch(url,
                        headers: {"Content-Type": "application/json"},
                        body: bodyF);
                    //print('Response status: ${response.statusCode}');
                    //print('Response body: ${response.body}');

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop();
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
                  },
                ),
                TextButton(
                  child: const Text("No, I'll continue."),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      }
    } else {
      //show alert telling user that they must close out current task first by updating its status in the free flow box.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Text(
                "Before ending this free flow session, close out your current task by updating its status in the free flow box."),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        final minutesLeft = freeFlowSessionDuration.inMinutes - 1;
        // if (minutesLeft <= 0) {
        //   //call a functionn to notify free flow session has ended
        //   freeFlowSessionEnded = true;
        // } else {
        freeFlowSessionDuration = Duration(minutes: minutesLeft);
        //}
      });
    });
  }

  void _openNewCalendarItemPage() {
    //this function needs to change to create new goal
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewEventPage(
                  selectedDate: thisDay,
                  updateEvents: _updateEvents,
                  fromPage: "full_calendar",
                )));
  }

  void _openNewFreeFlowSessionPage() {
    //this function needs to change to create new goal
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewFreeFlowEventPage(
                  selectedDate: thisDay,
                  updateEvents: _updateEvents,
                  fromPage: "daily_calendar",
                )));
  }

  void openEditEventPage() {
    Navigator.pop(context);
    if (selectedEvent!.type == "freeflow") {
      print("ready to edit free flow eventt");
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => EditFreeFlowEventPage(
                    updateEvents: _updateEvents,
                    // dataSource: _events,
                    selectedEvent: selectedEvent, fromPage: 'calendar',
                  )));
    } else {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => EditEventPage(
                    updateEvents: _updateEvents,
                    // dataSource: _events,
                    selectedEvent: selectedEvent,
                  )));
    }
  }

  // void _goToFullCalendarView() {
  //   Navigator.push(
  //       context,
  //       CupertinoPageRoute(
  //           builder: (context) => CalendarPage(
  //                 updateEvents: _updateEvents,
  //               )));
  // }

  _updateEvents() {
    setState(() {
      events =
          EventDataSource(PlannerService.sharedInstance.user!.scheduledEvents);
      selectedEvent = null;
    });
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

  void updatePotentialCandidates() {
    setState(() {
      //todaysTasks.addAll(selectedBacklogItems);
      todaysTasks = List.from(PlannerService
          .sharedInstance.user!.scheduledBacklogItemsMap[thisDay]!);
    });
  }

  Widget timerWidget() {
    print("I am building timer widget");
    if (freeFlowSessionStarted) {
      print("I am trying to update countdown");
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes =
          twoDigits(freeFlowSessionDuration.inMinutes.remainder(60));
      final hours = twoDigits(freeFlowSessionDuration.inHours.remainder(60));
      return Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          '$hours hrs : $minutes mins',
          style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
        ),
      );
    }
    // else if (freeFlowSessionEnded) {
    //   return Text(
    //     "Session Completed!",
    //     style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
    //   );
    // }
    else {
      if (!freeFlowSessionNeedsToBeEnded) {
//show timer details to set duration
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: EdgeInsets.all(20),
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "For how long?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberPicker(
                  value: sessionHours,
                  minValue: 0,
                  maxValue: 10,
                  step: 1,
                  itemHeight: 50,
                  onChanged: (value) => setState(() => sessionHours = value),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "hrs ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                NumberPicker(
                  value: sessionMins,
                  minValue: 0,
                  maxValue: 45,
                  step: 15,
                  itemHeight: 50,
                  onChanged: (value) => setState(() => sessionMins = value),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "mins",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ]),
        );
      } else {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: EdgeInsets.all(20),
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Congrats!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: const Text("Your free flow seession is complete. "),
            ),
            ElevatedButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                setState(() {
                  freeFlowSessionStarted = false;
                  freeFlowSessionEnded = true;
                  freeFlowSessionNeedsToBeEnded = false;
                  freeFlowSessionDuration = Duration();
                  if (timer != null) {
                    timer!.cancel();
                  }
                });
                var body = {
                  'userId': PlannerService.sharedInstance.user!.id,
                  'action': "end",
                };
                String bodyF = jsonEncode(body);
                //print(bodyF);

                var url = Uri.parse(
                    PlannerService.sharedInstance.serverUrl + '/user/freeflow');
                var response = await http.patch(url,
                    headers: {"Content-Type": "application/json"}, body: bodyF);
                //print('Response status: ${response.statusCode}');
                //print('Response body: ${response.body}');

                if (response.statusCode == 200) {
                  //Navigator.of(context).pop();
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
              },
              child: Text("Done"),
            )
          ]),
        );
      }
    }
    //return Container();
    //return TextButton(onPressed: () {}, child: Text("Set Session Timer"));
  }

  void taskCompleted() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Status",
              textAlign: TextAlign.center,
            ),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Text(
                "I've complete this task and ready to start a new task. Mark it as complete!"),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  //update the tasks status to complete

                  //make call to server
                  var body = {
                    'taskId': PlannerService
                        .sharedInstance
                        .user!
                        .backlogMap[currentTask!.categoryName]![
                            currentTask!.arrayIdx]
                        .id,
                    'status': "complete"
                  };
                  String bodyF = jsonEncode(body);
                  //print(bodyF);

                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/backlog/status');
                  var response = await http.patch(url,
                      headers: {"Content-Type": "application/json"},
                      body: bodyF);
                  //print('Response status: ${response.statusCode}');
                  //print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    print("I am removing current task on db");
                    //update on server
                    var body = {
                      'userId': PlannerService.sharedInstance.user!.id,
                      'action': "updatetask",
                      'currentTask': -1
                    };
                    String bodyF = jsonEncode(body);
                    //print(bodyF);

                    var url = Uri.parse(
                        PlannerService.sharedInstance.serverUrl +
                            '/user/freeflow');
                    var response = await http.patch(url,
                        headers: {"Content-Type": "application/json"},
                        body: bodyF);
                    //print('Response status: ${response.statusCode}');
                    //print('Response body: ${response.body}');

                    if (response.statusCode == 200) {
                      setState(() {
                        PlannerService
                            .sharedInstance
                            .user!
                            .backlogMap[currentTask!.categoryName]![
                                currentTask!.arrayIdx]
                            .status = "complete";

                        //add this task back to today's task
                        todaysTasks.add(currentTask!);
                        currentTask = null;
                        //update this in db
                        PlannerService
                            .sharedInstance.user!.currentTaskWorkingOn = null;
                        currentTaskSet = false;
                      });
                      Navigator.of(context).pop();
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
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void taskStarted() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Status",
              textAlign: TextAlign.center,
            ),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Text(
                "I've started this task and will continue working on it later. I'm ready to start another task."),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  //make call to server
                  var body = {
                    'taskId': PlannerService
                        .sharedInstance
                        .user!
                        .backlogMap[currentTask!.categoryName]![
                            currentTask!.arrayIdx]
                        .id,
                    'status': "started"
                  };
                  String bodyF = jsonEncode(body);
                  //print(bodyF);

                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/backlog/status');
                  var response = await http.patch(url,
                      headers: {"Content-Type": "application/json"},
                      body: bodyF);
                  //print('Response status: ${response.statusCode}');
                  //print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    print("I am removing current task on db");
                    //update on server
                    var body = {
                      'userId': PlannerService.sharedInstance.user!.id,
                      'action': "updatetask",
                      'currentTask': -1
                    };
                    String bodyF = jsonEncode(body);
                    //print(bodyF);

                    var url = Uri.parse(
                        PlannerService.sharedInstance.serverUrl +
                            '/user/freeflow');
                    var response = await http.patch(url,
                        headers: {"Content-Type": "application/json"},
                        body: bodyF);
                    //print('Response status: ${response.statusCode}');
                    //print('Response body: ${response.body}');

                    if (response.statusCode == 200) {
                      setState(() {
                        PlannerService
                            .sharedInstance
                            .user!
                            .backlogMap[currentTask!.categoryName]![
                                currentTask!.arrayIdx]
                            .status = "started";
                        //add this task back to today's task
                        todaysTasks.add(currentTask!);
                        currentTask = null;
                        //update this in db
                        PlannerService
                            .sharedInstance.user!.currentTaskWorkingOn = null;
                        currentTaskSet = false;
                      });
                      Navigator.of(context).pop();
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
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void taskNotStarted() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Status",
            textAlign: TextAlign.center,
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Text(
              "I haven't started this task yet. I will work on it later. I want to work on another task right now."),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                //make call to server
                var body = {
                  'taskId': PlannerService
                      .sharedInstance
                      .user!
                      .backlogMap[currentTask!.categoryName]![
                          currentTask!.arrayIdx]
                      .id,
                  'status': "notStarted"
                };
                String bodyF = jsonEncode(body);
                //print(bodyF);

                var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                    '/backlog/status');
                var response = await http.patch(url,
                    headers: {"Content-Type": "application/json"}, body: bodyF);
                //print('Response status: ${response.statusCode}');
                //print('Response body: ${response.body}');

                if (response.statusCode == 200) {
                  print("I am removing current task on db");
                  //update on server
                  var body = {
                    'userId': PlannerService.sharedInstance.user!.id,
                    'action': "updatetask",
                    'currentTask': -1
                  };
                  String bodyF = jsonEncode(body);
                  //print(bodyF);

                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/user/freeflow');
                  var response = await http.patch(url,
                      headers: {"Content-Type": "application/json"},
                      body: bodyF);
                  //print('Response status: ${response.statusCode}');
                  //print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    setState(() {
                      PlannerService
                          .sharedInstance
                          .user!
                          .backlogMap[currentTask!.categoryName]![
                              currentTask!.arrayIdx]
                          .status = "notStarted";
                      //add this task back to today's task
                      todaysTasks.add(currentTask!);
                      currentTask = null;
                      //update this in db
                      PlannerService.sharedInstance.user!.currentTaskWorkingOn =
                          null;
                      currentTaskSet = false;
                    });
                    Navigator.of(context).pop();
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
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget buildFreeFlowView() {
    return Column(
      children: [
        //was Expanded
        Container(
          //color: Colors.white,
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
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                      ),
                      // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                    ),
                    //),
                    Text(
                      " " + _selectedDate.day.toString(),
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
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
                'assets/images/night2.png',
                // width: 20,
                // height: 20,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ToggleButtons(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Schedule'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Tasks'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Free Flow'),
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
        //Container(
        // child: Column(
        //   children: [

        Container(
          child: Column(
            children: [
              Text(
                "Free Flowing Productivity",
                // _selectedDate.toString("MMMM"),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                ),
                // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
              ),
              !freeFlowSessionStarted
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        // "As long as you give maximum effort while you're free flowing, you'll always get the optimal number of things done."
                        // "Maximum effort will always result in the optimal number of things getting done. So, don't focus on how many things you get done while you're free flowing, focus on maximizing the effort you put in.",
                        "Maximum effort will always optimize the number of things you get done. So, don't focus on the number of things you do while you're free flowing, focus on maximizing the effort you put in.",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
              timerWidget(),
              freeFlowSessionStarted
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        child: Text("End Free Flow Session"),
                        onPressed: () async {
                          endFreeFlowSession();
                        },
                      ),
                    )
                  : Container(),
            ],
          ),
        ),

        freeFlowSessionStarted
            ? Container(
                child: Column(
                  children: [
                    currentTaskSet
                        ? Card(
                            margin: EdgeInsets.all(10),
                            //color: Colors.white,
                            elevation: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text("Currently working on..."),
                                ),
                                GestureDetector(
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    // shape: RoundedRectangleBorder(
                                    //   borderRadius: BorderRadius.circular(),
                                    // ),
                                    color: PlannerService
                                        .sharedInstance
                                        .user!
                                        .backlogMap[currentTask!.categoryName]![
                                            currentTask!.arrayIdx]
                                        .category
                                        .color,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        PlannerService
                                            .sharedInstance
                                            .user!
                                            .backlogMap[
                                                currentTask!.categoryName]![
                                                currentTask!.arrayIdx]
                                            .description,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0))),
                                            title: Text(
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .backlogMap[currentTask!
                                                          .categoryName]![
                                                      currentTask!.arrayIdx]
                                                  .description,
                                              textAlign: TextAlign.center,
                                            ),

                                            content:
                                                //Card(
                                                //child: Container(
                                                //child: Column(
                                                Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Text(
                                                    "Complete by " +
                                                        DateFormat.yMMMd().format(
                                                            PlannerService
                                                                .sharedInstance
                                                                .user!
                                                                .backlogMap[
                                                                    currentTask!
                                                                        .categoryName]![
                                                                    currentTask!
                                                                        .arrayIdx]
                                                                .completeBy!),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Text(PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .backlogMap[currentTask!
                                                              .categoryName]![
                                                          currentTask!.arrayIdx]
                                                      .notes),
                                                ),
                                              ],
                                            ),
                                            //),
                                            //),
                                            actions: <Widget>[
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: new Text('close'))
                                            ],
                                          );
                                        });
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        taskCompleted();
                                      },
                                      icon: Icon(
                                        Icons.flag_circle,
                                        color: Colors.green,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        taskStarted();
                                      },
                                      //"I started it. I will work on this more later."
                                      icon: Icon(
                                        Icons.incomplete_circle_rounded,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        taskNotStarted();
                                      },
                                      //"I haven't started. I want to choose another task."
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        : DragTarget<DraggableTaskInfo>(
                            builder: (context, candidateItems, rejectedItems) {
                              print("if statement executing in builer");
                              return Card(
                                margin: EdgeInsets.all(10),
                                color: dragTargetContainerColor,
                                elevation: 5,
                                child: Column(children: const [
                                  Padding(
                                    padding: EdgeInsets.all(25),
                                    child: Text(
                                      "Drag and Drop a task to work on.",
                                      // style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ]),
                              );
                            },
                            onLeave: (data) {
                              dragTargetContainerColor = Colors.white;
                              setState(() {});
                            },
                            onWillAccept: (data) {
                              dragTargetContainerColor = Colors.green;
                              setState(() {});
                              return true;
                            },
                            onAccept: (DraggableTaskInfo data) async {
                              print("accepted task");
                              HapticFeedback.mediumImpact();
                              setState(() {
                                taskAccepted = true;
                                dragTargetContainerColor = Colors.white;
                                //store id of current task in db
                                currentTask = data.bmr;
                                currentTaskSet = true;
                                PlannerService.sharedInstance.user!
                                    .currentTaskWorkingOn = currentTask;
                                print(
                                    "printing size of scheduled tasks before removal and after");
                                print(PlannerService
                                    .sharedInstance
                                    .user!
                                    .scheduledBacklogItemsMap[DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day)]!
                                    .length);
                                todaysTasks.removeAt(data.index);
                                print(PlannerService
                                    .sharedInstance
                                    .user!
                                    .scheduledBacklogItemsMap[DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day)]!
                                    .length);
                              });
                              //update on server
                              var body = {
                                'userId':
                                    PlannerService.sharedInstance.user!.id,
                                'action': "updatetask",
                                'currentTask': PlannerService
                                    .sharedInstance
                                    .user!
                                    .backlogMap[data.bmr.categoryName]![
                                        data.bmr.arrayIdx]
                                    .id
                              };
                              String bodyF = jsonEncode(body);
                              //print(bodyF);

                              var url = Uri.parse(
                                  PlannerService.sharedInstance.serverUrl +
                                      '/user/freeflow');
                              var response = await http.patch(url,
                                  headers: {"Content-Type": "application/json"},
                                  body: bodyF);
                              //print('Response status: ${response.statusCode}');
                              //print('Response body: ${response.body}');

                              if (response.statusCode == 200) {
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
                            },
                          ),
                  ],
                ),
              )
            : Container(),

        freeFlowSessionStarted
            ? Expanded(
                child: todaysTasks.length == 0
                    ? Container(
                        alignment: Alignment.center,
                        child: Text("No Tasks to work on."),
                      )
                    : ListView(
                        children:
                            List.generate(todaysTasks.length, (int index) {
                          if (PlannerService
                                  .sharedInstance
                                  .user!
                                  .backlogMap[todaysTasks[index].categoryName]![
                                      todaysTasks[index].arrayIdx]
                                  .status !=
                              "complete") {
                            return LongPressDraggable<DraggableTaskInfo>(
                                onDragStarted: () {
                                  print("drag started");
                                },
                                childWhenDragging: Container(),
                                child: GestureDetector(
                                  child: Card(
                                    margin: EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: PlannerService
                                                .sharedInstance
                                                .user!
                                                .backlogMap[todaysTasks[index]
                                                        .categoryName]![
                                                    todaysTasks[index].arrayIdx]
                                                .status ==
                                            "notStarted"
                                        ? Colors.grey.shade100
                                        : (PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .backlogMap[
                                                        todaysTasks[index]
                                                            .categoryName]![
                                                        todaysTasks[index]
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
                                            .backlogMap[todaysTasks[index]
                                                    .categoryName]![
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
                                              .backlogMap[todaysTasks[index]
                                                      .categoryName]![
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
                                    ),
                                  ),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0))),
                                            title: Text(
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .backlogMap[todaysTasks[index]
                                                          .categoryName]![
                                                      todaysTasks[index]
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Text(
                                                    "Complete by " +
                                                        DateFormat.yMMMd().format(
                                                            PlannerService
                                                                .sharedInstance
                                                                .user!
                                                                .backlogMap[
                                                                    todaysTasks[
                                                                            index]
                                                                        .categoryName]![
                                                                    todaysTasks[
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
                                                      .backlogMap[
                                                          todaysTasks[index]
                                                              .categoryName]![
                                                          todaysTasks[index]
                                                              .arrayIdx]
                                                      .notes),
                                                ),
                                              ],
                                            ),
                                            //),
                                            //),
                                            actions: <Widget>[
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: new Text('close'))
                                            ],
                                          );
                                        });
                                  },
                                ),
                                data: DraggableTaskInfo(
                                    todaysTasks[index], index),
                                feedback: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      color: PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[
                                              todaysTasks[index].categoryName]![
                                              todaysTasks[index].arrayIdx]
                                          .category
                                          .color,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          PlannerService
                                              .sharedInstance
                                              .user!
                                              .backlogMap[todaysTasks[index]
                                                      .categoryName]![
                                                  todaysTasks[index].arrayIdx]
                                              .description,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                          }
                          return Container();
                        }),
                      ),
              )
            : Container(),
        //),

        !freeFlowSessionStarted && !freeFlowSessionNeedsToBeEnded
            ? Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: ElevatedButton(
                  onPressed: () async {
                    if (PlannerService.sharedInstance.user!.isPremiumUser!) {
                      if (sessionHours == 0 && sessionMins == 0) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                title: Text(
                                    "The session timer hasn't been set yet. Set the timer before starting."),
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
                      } else {
                        setState(() {
                          freeFlowSessionStarted = true;
                          freeFlowSessionDuration = Duration(
                              hours: sessionHours, minutes: sessionMins);
                          //store this in db
                          PlannerService.sharedInstance.user!
                                  .currentFreeFlowSessionEnds =
                              DateTime.now().add(freeFlowSessionDuration);
                          startTimer();
                        });
                        HapticFeedback.mediumImpact();
                        //call server to start
                        //make call to server

                        var body = {
                          'userId': PlannerService.sharedInstance.user!.id,
                          'action': "start",
                          'end': (DateTime.now().add(freeFlowSessionDuration))
                              .toString(),
                        };
                        String bodyF = jsonEncode(body);
                        //print(bodyF);

                        var url = Uri.parse(
                            PlannerService.sharedInstance.serverUrl +
                                '/user/freeflow');
                        var response = await http.patch(url,
                            headers: {"Content-Type": "application/json"},
                            body: bodyF);
                        //print('Response status: ${response.statusCode}');
                        //print('Response body: ${response.body}');

                        if (response.statusCode == 200) {
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
                    } else {
                      if (PlannerService.sharedInstance.user!.receipt == "") {
                        //should geet free trial
                        List<ProductDetails> productDetails =
                            await PlannerService.subscriptionProvider
                                .fetchSubscriptions();

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return SubscriptionPage(
                                fromPage: 'inapp', products: productDetails);
                          },
                        ));
                      } else {
                        List<ProductDetails> productDetails =
                            await PlannerService.subscriptionProvider
                                .fetchSubscriptions();

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return SubscriptionPageNoTrial(
                                fromPage: 'inapp', products: productDetails);
                          },
                        ));
                      }
                    }
                  },
                  child: Text("Start Free Flow Productivity"),
                ),
              )
            : Container(),
      ],
    );
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

  Widget buildTasksView() {
    return Column(
      children: [
        //was Expanded
        Container(
          //color: Colors.white,
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
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                      ),
                      // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                    ),
                    //),
                    Text(
                      " " + _selectedDate.day.toString(),
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
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
                'assets/images/night2.png',
                // width: 20,
                // height: 20,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ToggleButtons(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Schedule'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Tasks'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Free Flow'),
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
                      .containsKey(thisDay) ||
                  PlannerService.sharedInstance.user!
                      .scheduledBacklogItemsMap[thisDay]!.isEmpty
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
                          .scheduledBacklogItemsMap[thisDay]!
                          .length, (int index) {
                    return GestureDetector(
                      onTap: () {
                        //show dialog
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                title: Text(
                                  PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  thisDay]![index]
                                              .categoryName]![
                                          PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  thisDay]![index]
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
                                                .backlogMap[PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            thisDay]![index]
                                                        .categoryName]![
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            thisDay]![index]
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
                                                      thisDay]![index]
                                                  .categoryName]![
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
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
                                                  thisDay]![index]
                                              .arrayIdx,
                                          PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  thisDay]![index]
                                              .categoryName);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('remove from today'),
                                    onPressed: () async {
                                      print("I am running remove from");

                                      //first check if item is currently being worked on
                                      if (PlannerService.sharedInstance.user!
                                                  .scheduledBacklogItemsMap[
                                              thisDay]![index] ==
                                          PlannerService.sharedInstance.user!
                                              .currentTaskWorkingOn) {
                                        //this is the current task
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              alignment: Alignment.center,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20.0))),
                                              content: const Text(
                                                  "This item can't be removed because it is currently being worked on in free flow session. Change current free flow task first. "),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Ok'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        //first check if the item is scheduled on calendar, if so, show a dialog
                                        if (PlannerService
                                                .sharedInstance
                                                .user!
                                                .backlogMap[PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            thisDay]![index]
                                                        .categoryName]![
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            thisDay]![index]
                                                        .arrayIdx]
                                                .calendarItemRef !=
                                            null) {
                                          //this would be null if not on calendar
                                          Navigator.of(context).pop();
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  alignment: Alignment.center,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      20.0))),
                                                  content: Text(
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
                                                            thisDay]![index]
                                                        .categoryName]![
                                                    PlannerService
                                                        .sharedInstance
                                                        .user!
                                                        .scheduledBacklogItemsMap[
                                                            thisDay]![index]
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
                                                "Content-Type":
                                                    "application/json"
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
                                                  .backlogMap[PlannerService
                                                          .sharedInstance
                                                          .user!
                                                          .scheduledBacklogItemsMap[
                                                              thisDay]![index]
                                                          .categoryName]![
                                                      PlannerService
                                                          .sharedInstance
                                                          .user!
                                                          .scheduledBacklogItemsMap[
                                                              thisDay]![index]
                                                          .arrayIdx]
                                                  .scheduledDate = null;

                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]!
                                                  .removeAt(index);

                                              todaysTasks = List.from(PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .scheduledBacklogItemsMap[
                                                  thisDay]!);
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
                                              },
                                            );
                                          }
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
                                    .backlogMap[
                                        PlannerService.sharedInstance.user!
                                            .scheduledBacklogItemsMap[thisDay]![index].categoryName]![
                                        PlannerService
                                            .sharedInstance
                                            .user!
                                            .scheduledBacklogItemsMap[thisDay]![
                                                index]
                                            .arrayIdx]
                                    .status ==
                                "notStarted"
                            ? Colors.grey.shade100
                            : (PlannerService
                                        .sharedInstance
                                        .user!
                                        .backlogMap[
                                            PlannerService.sharedInstance.user!
                                                .scheduledBacklogItemsMap[thisDay]![index].categoryName]![
                                            PlannerService
                                                .sharedInstance
                                                .user!
                                                .scheduledBacklogItemsMap[thisDay]![index]
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
                                .backlogMap[
                                    PlannerService
                                        .sharedInstance
                                        .user!
                                        .scheduledBacklogItemsMap[thisDay]![
                                            index]
                                        .categoryName]![
                                    PlannerService
                                        .sharedInstance
                                        .user!
                                        .scheduledBacklogItemsMap[thisDay]![
                                            index]
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
                                  .backlogMap[
                                      PlannerService
                                          .sharedInstance
                                          .user!
                                          .scheduledBacklogItemsMap[thisDay]![
                                              index]
                                          .categoryName]![
                                      PlannerService
                                          .sharedInstance
                                          .user!
                                          .scheduledBacklogItemsMap[thisDay]![
                                              index]
                                          .arrayIdx]
                                  .description,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          trailing: PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  thisDay]![index]
                                              .categoryName]![
                                          PlannerService
                                              .sharedInstance
                                              .user!
                                              .scheduledBacklogItemsMap[
                                                  thisDay]![index]
                                              .arrayIdx]
                                      .status ==
                                  "complete"
                              ? Icon(
                                  Icons.check_rounded,
                                  color: Theme.of(context).primaryColor,
                                )
                              : Checkbox(
                                  value: PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
                                                  .categoryName]![
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
                                                  .arrayIdx]
                                          .status ==
                                      "complete",
                                  shape: const CircleBorder(),
                                  onChanged: (bool? value) async {
                                    HapticFeedback.mediumImpact();
                                    setState(() {
                                      PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
                                                  .categoryName]![
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
                                                  .arrayIdx]
                                          .isComplete = value;
                                      PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
                                                  .categoryName]![
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
                                                  .arrayIdx]
                                          .status = "complete";
                                    });
                                    //make call to server
                                    var body = {
                                      'taskId': PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
                                                  .categoryName]![
                                              PlannerService
                                                  .sharedInstance
                                                  .user!
                                                  .scheduledBacklogItemsMap[
                                                      thisDay]![index]
                                                  .arrayIdx]
                                          .id,
                                      'status': "complete"
                                    };
                                    String bodyF = jsonEncode(body);
                                    //print(bodyF);

                                    var url = Uri.parse(PlannerService
                                            .sharedInstance.serverUrl +
                                        '/backlog/status');
                                    var response = await http.patch(url,
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                        body: bodyF);
                                    //print('Response status: ${response.statusCode}');
                                    //print('Response body: ${response.body}');

                                    if (response.statusCode == 200) {
                                      // setState(() {
                                      //   PlannerService
                                      //       .sharedInstance
                                      //       .user!
                                      //       .backlogMap[PlannerService
                                      //               .sharedInstance
                                      //               .user!
                                      //               .scheduledBacklogItemsMap[
                                      //                   thisDay]![index]
                                      //               .categoryName]![
                                      //           PlannerService
                                      //               .sharedInstance
                                      //               .user!
                                      //               .scheduledBacklogItemsMap[
                                      //                   thisDay]![index]
                                      //               .arrayIdx]
                                      //       .isComplete = value;
                                      //   PlannerService
                                      //       .sharedInstance
                                      //       .user!
                                      //       .backlogMap[PlannerService
                                      //               .sharedInstance
                                      //               .user!
                                      //               .scheduledBacklogItemsMap[
                                      //                   thisDay]![index]
                                      //               .categoryName]![
                                      //           PlannerService
                                      //               .sharedInstance
                                      //               .user!
                                      //               .scheduledBacklogItemsMap[
                                      //                   thisDay]![index]
                                      //               .arrayIdx]
                                      //       .status = "complete";
                                      // });
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
                onPressed: () async {
                  if (PlannerService.sharedInstance.user!.isPremiumUser!) {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => SelectBacklogItemsPage(
                                date: thisDay,
                                updatePotentialCandidates:
                                    updatePotentialCandidates)));
                  } else {
                    if (PlannerService.sharedInstance.user!.receipt == "") {
                      //should geet free trial
                      List<ProductDetails> productDetails = await PlannerService
                          .subscriptionProvider
                          .fetchSubscriptions();

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return SubscriptionPage(
                              fromPage: 'inapp', products: productDetails);
                        },
                      ));
                    } else {
                      List<ProductDetails> productDetails = await PlannerService
                          .subscriptionProvider
                          .fetchSubscriptions();

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return SubscriptionPageNoTrial(
                              fromPage: 'inapp', products: productDetails);
                        },
                      ));
                    }
                  }
                },
                child: Text("Add Backlog Items")),
            TextButton(
              onPressed: () async {
                if (PlannerService.sharedInstance.user!.isPremiumUser!) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => NewTaskPage(
                                updateBacklog: updatePotentialCandidates,
                                selectdDate: thisDay,
                              )));
                } else {
                  if (PlannerService.sharedInstance.user!.receipt == "") {
                    //should geet free trial
                    List<ProductDetails> productDetails = await PlannerService
                        .subscriptionProvider
                        .fetchSubscriptions();

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return SubscriptionPage(
                            fromPage: 'inapp', products: productDetails);
                      },
                    ));
                  } else {
                    List<ProductDetails> productDetails = await PlannerService
                        .subscriptionProvider
                        .fetchSubscriptions();

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return SubscriptionPageNoTrial(
                            fromPage: 'inapp', products: productDetails);
                      },
                    ));
                  }
                }
              },
              child: Text("Create New Task"),
            )
          ],
        ),
      ],
    );
  }

  void deleteEvent() async {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
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

  void unscheduleEvent() async {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
      //print("this is the")
      //details.targetElement.index;
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
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
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

  Widget buildScheduleView() {
    return Column(
      children: [
        //was Expanded
        Container(
          //color: Colors.white,
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
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                      ),
                      // fontSize: Theme.of(context).textTheme.subtitle2!.fontSize),
                    ),
                    //),
                    Text(
                      " " + _selectedDate.day.toString(),
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
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
                'assets/images/night2.png',
                // width: 20,
                // height: 20,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ToggleButtons(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Schedule'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Tasks'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Free Flow'),
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

        // Expanded(
        //   child: Column(
        //     children: [

        Expanded(
          child: SfCalendar(
            headerHeight: 0,
            viewHeaderHeight: 0,
            //showDatePickerButton: true,
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
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.contain,
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
                              ),
                      ),
                      Expanded(
                          // child: FittedBox(
                          //   fit: BoxFit.contain,
                          child: SingleChildScrollView(
                        //was a list view
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              textAlign: TextAlign.center,
                            ),
                            //),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                meeting.description,
                                style: const TextStyle(
                                    //color: Colors.white,
                                    // fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            //),
                            //Expanded(

                            //),
                          ],
                        ),
                      )

                          //),
                          ),
                      Expanded(
                        child: meeting.type == "freeflow"
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    freeFlowSessionStarted = true;
                                    //duration = end time - startiment
                                    freeFlowSessionDuration =
                                        meeting.end.difference(DateTime.now());
                                  });
                                  if (freeFlowSessionDuration.isNegative) {
                                    //session is complete
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Text(
                                              'Looks like this session has ended! Create a new free flow session or start an impromptu session by pressing the free flow tab.',
                                              textAlign: TextAlign.center,
                                            ),
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
                                  } else {
                                    setState(() {
                                      // freeFlowSessionDuration = Duration(
                                      //     hours: sessionHours,
                                      //     minutes: sessionMins);
                                      //store this in db
                                      PlannerService.sharedInstance.user!
                                              .currentFreeFlowSessionEnds =
                                          meeting.end;
                                      //flip to free flow tab and start timer
                                      for (int i = 0;
                                          i < _selectedPageView.length;
                                          i++) {
                                        _selectedPageView[i] = i == 2;
                                      }
                                      selectedMode = 2;
                                    });
                                    startTimer();
                                    HapticFeedback.mediumImpact();
                                  }
                                },
                                child: Text("Start"),
                              )
                            : Checkbox(
                                side: const BorderSide(color: Colors.grey),
                                //value: meeting.isAccomplished,
                                value: events
                                    .appointments![
                                        events.appointments!.indexOf(meeting)]
                                    .isAccomplished,
                                shape: const CircleBorder(),
                                onChanged: (bool? value) async {
                                  setState(() {
                                    events
                                        .appointments![events.appointments!
                                            .indexOf(meeting)]
                                        .isAccomplished = value;
                                    PlannerService.sharedInstance.user!
                                            .scheduledEvents =
                                        events.appointments! as List<Event>;
                                    //widget.updateEvents();
                                  });
                                  HapticFeedback.mediumImpact();
                                  //make server call
                                  int id = meeting.id!;
                                  var body = {
                                    'eventId': id,
                                    'eventStatus': value,
                                  };
                                  String bodyF = jsonEncode(body);
                                  //print(bodyF);

                                  var url = Uri.parse(
                                      PlannerService.sharedInstance.serverUrl +
                                          '/user/calendar/event/status');
                                  var response = await http.patch(url,
                                      headers: {
                                        "Content-Type": "application/json"
                                      },
                                      body: bodyF);
                                  //print('Response status: ${response.statusCode}');
                                  //print('Response body: ${response.body}');

                                  if (response.statusCode == 200) {
                                    // setState(() {
                                    //   events
                                    //       .appointments![events.appointments!
                                    //           .indexOf(meeting)]
                                    //       .isAccomplished = value;
                                    //   PlannerService.sharedInstance.user!
                                    //           .scheduledEvents =
                                    //       events.appointments! as List<Event>;
                                    //   //widget.updateEvents();
                                    // });
                                    // HapticFeedback.mediumImpact();
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

                                  //PlannerService.sharedInstance.user.f
                                  //});
                                },
                              ),
                      )
                    ],
                  ),
                ),
              );
            },
            //EventDataSource(PlannerService.sharedInstance.user.allEvents),
          ),
        ),
        //     ],
        //   ),
        // ),
      ],
    );
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
          calendarDate: thisDay,
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
                    onPressed: () async {
                      if (PlannerService.sharedInstance.user!.isPremiumUser!) {
                        startPlanningFromBacklog();
                      } else {
                        if (PlannerService.sharedInstance.user!.receipt == "") {
                          //should geet free trial
                          List<ProductDetails> productDetails =
                              await PlannerService.subscriptionProvider
                                  .fetchSubscriptions();

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return SubscriptionPage(
                                  fromPage: 'inapp', products: productDetails);
                            },
                          ));
                        } else {
                          List<ProductDetails> productDetails =
                              await PlannerService.subscriptionProvider
                                  .fetchSubscriptions();

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return SubscriptionPageNoTrial(
                                  fromPage: 'inapp', products: productDetails);
                            },
                          ));
                        }
                      }
                    },
                    child: Text("Backlog Item"),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (PlannerService.sharedInstance.user!.isPremiumUser!) {
                        _openNewFreeFlowSessionPage();
                      } else {
                        if (PlannerService.sharedInstance.user!.receipt == "") {
                          //should geet free trial
                          List<ProductDetails> productDetails =
                              await PlannerService.subscriptionProvider
                                  .fetchSubscriptions();

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return SubscriptionPage(
                                  fromPage: 'inapp', products: productDetails);
                            },
                          ));
                        } else {
                          List<ProductDetails> productDetails =
                              await PlannerService.subscriptionProvider
                                  .fetchSubscriptions();

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return SubscriptionPageNoTrial(
                                  fromPage: 'inapp', products: productDetails);
                            },
                          ));
                        }
                      }
                    },
                    child: Text("Free Flow Session"),
                  )
                ],
              ),
              actions: const <Widget>[]);
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

      body: selectedMode == 0
          ? buildScheduleView()
          : selectedMode == 1
              ? buildTasksView()
              : buildFreeFlowView(),

      floatingActionButton: selectedMode == 0
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
          : Container(),

      //),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
    //],
    //);
  }
}
