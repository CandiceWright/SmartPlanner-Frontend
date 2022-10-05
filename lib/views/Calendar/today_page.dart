import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/models/draggable_task_info.dart';
import 'package:practice_planner/views/Calendar/calendar_page.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Calendar/notes_page.dart';
import 'package:practice_planner/views/Calendar/schedule_backlog_items_page.dart';
import 'package:practice_planner/views/Calendar/select_backlog_items_page.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../models/backlog_item.dart';
import '../Backlog/edit_task_page.dart';
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

  @override
  void initState() {
    // if (PlannerService.sharedInstance.user!.scheduledBacklogItemsMap
    //     .containsKey(thisDay)) {
    //   todaysTasks = PlannerService
    //       .sharedInstance.user!.scheduledBacklogItemsMap[thisDay]!;
    // }

    super.initState();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        final minutesLeft = freeFlowSessionDuration.inMinutes + 1;
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
      return Text(
        '$hours hrs : $minutes mins',
        style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
      );
    } else if (freeFlowSessionEnded) {
      return Text(
        "Session Completed!",
        style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
      );
    }
    return Container();
    //return TextButton(onPressed: () {}, child: Text("Set Session Timer"));
  }

  void taskCompleted() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: Text(
            //   ,
            //   textAlign: TextAlign.center,
            // ),
            content: Text(
                "I've complete this task and ready to start a new task. Mark it as complete!"),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  //update the tasks status to complete
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
                    currentTaskSet = false;
                  });

                  Navigator.of(context).pop();
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
            // title: Text(
            //   ,
            //   textAlign: TextAlign.center,
            // ),
            content: Text(
                "I've started this task and will continue working on it later. I'm ready to start another task."),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  setState(() {
                    PlannerService
                        .sharedInstance
                        .user!
                        .backlogMap[currentTask!.categoryName]![
                            currentTask!.arrayIdx]
                        .status = "incomplete";
                    //add this task back to today's task
                    todaysTasks.add(currentTask!);
                    currentTask = null;
                    currentTaskSet = false;
                  });
                  Navigator.of(context).pop();
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
          // title: Text(
          //   ,
          //   textAlign: TextAlign.center,
          // ),
          content: Text(
              "I haven't started this task yet. I will work on it later. I want to work on another task right now."),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
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
                  currentTaskSet = false;
                });
                Navigator.of(context).pop();
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
                'assets/images/night.png',
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
                    child: Text('Tasks'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Scheduled'),
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
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  // "As long as you give maximum effort while you're free flowing, you'll always get the optimal number of things done."
                  "Maximum effort will always result in the optimal number of things getting done. So, don't focus on how many things you get done while you're free flowing, focus on maximizing the effort you put in.",
                  textAlign: TextAlign.center,
                ),
              ),
              timerWidget(),
              freeFlowSessionStarted
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          if (!currentTaskSet) {
                            String twoDigits(int n) =>
                                n.toString().padLeft(2, '0');
                            final minutes = twoDigits(freeFlowSessionDuration
                                .inMinutes
                                .remainder(60));
                            final hours = twoDigits(
                                freeFlowSessionDuration.inHours.remainder(60));

                            //Show an alert that says "Congrats!" You completed x hours and y minutes of free flowing
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Congrats!"),
                                  content: Text(
                                      "You completed $hours hours and $minutes minutes of free flowing!"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Ok, Great!'),
                                      onPressed: () {
                                        setState(() {
                                          freeFlowSessionStarted = false;
                                          freeFlowSessionEnded = true;
                                          freeFlowSessionDuration = Duration();
                                          timer!.cancel();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          } else {
                            //show alert telling user that they must close out current task first by updating its status in the free flow box.
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
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
                        },
                        child: Text("End Free Flow Session"),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        // Stack(
        //   children: [
        //     SafeArea(
        //       child:
        // Column(
        //   children: [
        //Expanded(
        //child:
        //Stack(children: [],),
        //was Container
        Expanded(
          //height: 150,
          //was a column

          child: todaysTasks.length == 0
              ? Container(
                  alignment: Alignment.center,
                  child: Text("No Tasks Yet. Add tasks below."),
                )
              : ListView(
                  children: List.generate(todaysTasks.length, (int index) {
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
                                        .backlogMap[
                                            todaysTasks[index].categoryName]![
                                            todaysTasks[index].arrayIdx]
                                        .status ==
                                    "notStarted"
                                ? Colors.grey.shade100
                                : (PlannerService
                                            .sharedInstance
                                            .user!
                                            .backlogMap[todaysTasks[index]
                                                    .categoryName]![
                                                todaysTasks[index].arrayIdx]
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
                            ),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[
                                              todaysTasks[index].categoryName]![
                                              todaysTasks[index].arrayIdx]
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
                                                            todaysTasks[index]
                                                                .categoryName]![
                                                            todaysTasks[index]
                                                                .arrayIdx]
                                                        .completeBy!),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(PlannerService
                                              .sharedInstance
                                              .user!
                                              .backlogMap[todaysTasks[index]
                                                      .categoryName]![
                                                  todaysTasks[index].arrayIdx]
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
                        data: DraggableTaskInfo(todaysTasks[index], index),
                        feedback: Material(
                          borderRadius: BorderRadius.circular(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: PlannerService
                                  .sharedInstance
                                  .user!
                                  .backlogMap[todaysTasks[index].categoryName]![
                                      todaysTasks[index].arrayIdx]
                                  .category
                                  .color,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[
                                          todaysTasks[index].categoryName]![
                                          todaysTasks[index].arrayIdx]
                                      .description,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        )

                        // feedback: Material(

                        //   child: Card(
                        //     margin: EdgeInsets.all(15),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(15),
                        //     ),
                        //     color: Colors.grey.shade100,
                        //     elevation: 5,
                        //     child: ListTile(
                        //       leading: Icon(
                        //         Icons.circle,
                        //         color: PlannerService
                        //             .sharedInstance
                        //             .user!
                        //             .backlogMap[todaysTasks[index].categoryName]![
                        //                 todaysTasks[index].arrayIdx]
                        //             .category
                        //             .color,
                        //       ),
                        //       title: Padding(
                        //         padding: EdgeInsets.only(bottom: 5),
                        //         child: Text(
                        //           PlannerService
                        //               .sharedInstance
                        //               .user!
                        //               .backlogMap[todaysTasks[index].categoryName]![
                        //                   todaysTasks[index].arrayIdx]
                        //               .description,
                        //           maxLines: 2,
                        //           textAlign: TextAlign.center,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        );
                  }),
                ),
        ),
        //),
        Container(
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
                                      .backlogMap[currentTask!.categoryName]![
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
                                      title: Text(
                                        PlannerService
                                            .sharedInstance
                                            .user!
                                            .backlogMap[
                                                currentTask!.categoryName]![
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
                                                .backlogMap[
                                                    currentTask!.categoryName]![
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
                                  Icons.square,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  taskStarted();
                                },
                                //"I started it. I will work on this more later."
                                icon: Icon(
                                  Icons.square,
                                  color: Colors.yellow,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  taskNotStarted();
                                },
                                //"I haven't started. I want to choose another task."
                                icon: Icon(
                                  Icons.square,
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
                                "Drag and Drop a task to start free flowing.",
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
                      onAccept: (DraggableTaskInfo data) {
                        print("accepted task");
                        setState(() {
                          taskAccepted = true;
                          dragTargetContainerColor = Colors.white;
                          currentTask = data.bmr;
                          currentTaskSet = true;
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
                        //taskAccepted = false;
                      },
                    ),
              currentTaskSet && !freeFlowSessionStarted
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            freeFlowSessionStarted = true;
                            startTimer();
                          });
                        },
                        child: Text("Start Free Flow Productivity"),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),

        //],
        //),
        //     ),
        //   ],
        // ),
        //],
        //),
        //),
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
                'assets/images/night.png',
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
                    child: Text('Tasks'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Scheduled'),
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

          child:
              !PlannerService.sharedInstance.user!.scheduledBacklogItemsMap
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                });
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
                                        .backlogMap[PlannerService.sharedInstance.user!.scheduledBacklogItemsMap[thisDay]![index].categoryName]![
                                            PlannerService
                                                .sharedInstance
                                                .user!
                                                .scheduledBacklogItemsMap[
                                                    thisDay]![index]
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
                                                        thisDay]![index]
                                                    .categoryName]![
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
                                    .backlogMap[PlannerService
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
                                            .scheduledBacklogItemsMap[thisDay]![
                                                index]
                                            .categoryName]![
                                        PlannerService
                                            .sharedInstance
                                            .user!
                                            .scheduledBacklogItemsMap[thisDay]![
                                                index]
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
                                                    thisDay]![index]
                                                .categoryName]![
                                            PlannerService
                                                .sharedInstance
                                                .user!
                                                .scheduledBacklogItemsMap[
                                                    thisDay]![index]
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
                              date: thisDay,
                              updatePotentialCandidates:
                                  updatePotentialCandidates)));
                },
                child: Text("Add Backlog Items")),
            TextButton(onPressed: () {}, child: Text("Create New Task"))
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
          ? buildTasksView()
          : selectedMode == 1
              ? Container()
              : buildFreeFlowView(),

      //),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
    //],
    //);
  }
}
