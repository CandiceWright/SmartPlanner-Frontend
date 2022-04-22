// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/models/event_data_source.dart';
import 'package:practice_planner/models/habit.dart';
import 'package:practice_planner/views/Calendar/calendar_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '/views/Goals/goals_page.dart';
import '/services/planner_service.dart';
import '../Profile/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _HomePageState extends State<HomePage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  //var todayTasks = PlannerService.sharedInstance.user.todayTasks;
  var newHabitTextController = TextEditingController();
  var editHabitTxtController = TextEditingController();
  bool editHabitBtnDisabled = false;
  bool saveHabitBtnDisabled = true;

  var daysMap = {
    1: "Mon",
    2: "Tues",
    3: "Wed",
    4: "Thurs",
    5: "Friday",
    6: "Saturday",
    7: "Sunday"
  };

  @override
  void initState() {
    super.initState();
    //print(PlannerService.sharedInstance.user.backlog);
    newHabitTextController.addListener(setSaveHabitBtnState);
    editHabitTxtController.addListener(setEditHabitBtnState);
  }

  void openProfileView() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ProfilePage(
                  updateEvents: _updateEvents,
                )));
  }

  void _updateEvents() {
    setState(() {});
  }

  List<Widget> buildTodayTaskListView() {
    print("building today tasks widget");
    List<Widget> todayTasksWidgets = [];
    for (int i = 0;
        i < PlannerService.sharedInstance.user.todayTasks.length;
        i++) {
      Widget taskWidget = CheckboxListTile(
        title:
            Text(PlannerService.sharedInstance.user.todayTasks[i].description),
        value: PlannerService.sharedInstance.user.todayTasks[i].isComplete,
        selected: PlannerService.sharedInstance.user.todayTasks[i].isComplete,
        onChanged: (bool? value) {
          print(value);
          setState(() {
            PlannerService.sharedInstance.user.todayTasks[i].isComplete = value;
            PlannerService.sharedInstance.user.todayTasks[i].isComplete = value;
          });
        },
        secondary: IconButton(
          icon: const Icon(Icons.visibility_outlined),
          tooltip: 'View this backlog item',
          onPressed: () {
            setState(() {});
          },
        ),
        controlAffinity: ListTileControlAffinity.leading,
      );
      todayTasksWidgets.add(taskWidget);
    }
    return todayTasksWidgets;
  }

  List<TableRow> buildHabitsView() {
    List<TableRow> tableRows = [];
    TableRow headerRow = TableRow(children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.fill,
        child: Container(
            // child: Text(
            //   "Habits",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     //color: Theme.of(context).colorScheme.primary,
            //     color: Colors.black,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            //margin: EdgeInsets.only(left: 10, right: 10),
            ),
      ),
      TableCell(
          child: Container(child: Text("S", textAlign: TextAlign.center))),
      TableCell(child: Text("M", textAlign: TextAlign.center)),
      TableCell(child: Text("T", textAlign: TextAlign.center)),
      TableCell(child: Text("W", textAlign: TextAlign.center)),
      TableCell(child: Text("TH", textAlign: TextAlign.center)),
      TableCell(child: Text("F", textAlign: TextAlign.center)),
      TableCell(child: Text("S", textAlign: TextAlign.center)),
    ]);

    tableRows.add(headerRow);
    print("printing size of habits size");
    print(PlannerService.sharedInstance.user.habits.length);

    for (int i = 0; i < PlannerService.sharedInstance.user.habits.length; i++) {
      //print("printing habit tracker map at Sunday");
      //print(PlannerService.sharedInstance.user.habits[i].habitTrackerMap["Sunday"]);
      TableRow tableRow = TableRow(children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            child: TextButton(
              child: Text(
                PlannerService.sharedInstance.user.habits[i].description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                //showHabitDialog(i);
              },
            ),
            margin: EdgeInsets.only(left: 10, right: 10),
          ),
        ),
        TableCell(
          child: Container(
            child: Checkbox(
              shape: CircleBorder(),
              value: PlannerService
                  .sharedInstance.user.habits[i].habitTrackerMap["Sunday"]!,
              onChanged: (bool? value) {
                print(value);
                setState(() {
                  PlannerService.sharedInstance.user.habits[i]
                      .habitTrackerMap["Sunday"] = value!;
                });
              },
            ),
          ),
        ),
        TableCell(
          child: Container(
            child: Checkbox(
              shape: CircleBorder(),
              value: PlannerService
                  .sharedInstance.user.habits[i].habitTrackerMap["Mon"]!,
              onChanged: (bool? value) {
                print(value);
                setState(() {
                  PlannerService.sharedInstance.user.habits[i]
                      .habitTrackerMap["Mon"] = value!;
                });
              },
            ),
          ),
        ),
        TableCell(
          child: Container(
            child: Checkbox(
              shape: CircleBorder(),
              value: PlannerService
                  .sharedInstance.user.habits[i].habitTrackerMap["Tues"]!,
              onChanged: (bool? value) {
                print(value);
                setState(() {
                  PlannerService.sharedInstance.user.habits[i]
                      .habitTrackerMap["Tues"] = value!;
                });
              },
            ),
          ),
        ),
        TableCell(
          child: Container(
            child: Checkbox(
              shape: CircleBorder(),
              value: PlannerService
                  .sharedInstance.user.habits[i].habitTrackerMap["Wed"]!,
              onChanged: (bool? value) {
                print(value);
                setState(() {
                  PlannerService.sharedInstance.user.habits[i]
                      .habitTrackerMap["Wed"] = value!;
                });
              },
            ),
          ),
        ),
        TableCell(
          child: Container(
            child: Checkbox(
              shape: CircleBorder(),
              value: PlannerService
                  .sharedInstance.user.habits[i].habitTrackerMap["Thurs"]!,
              onChanged: (bool? value) {
                print(value);
                setState(() {
                  PlannerService.sharedInstance.user.habits[i]
                      .habitTrackerMap["Thurs"] = value!;
                });
              },
            ),
          ),
        ),
        TableCell(
          child: Container(
            child: Checkbox(
              shape: CircleBorder(),
              value: PlannerService
                  .sharedInstance.user.habits[i].habitTrackerMap["Friday"]!,
              onChanged: (bool? value) {
                print(value);
                setState(() {
                  PlannerService.sharedInstance.user.habits[i]
                      .habitTrackerMap["Friday"] = value!;
                });
              },
            ),
          ),
        ),
        TableCell(
          child: Container(
            child: Checkbox(
              shape: CircleBorder(),
              value: PlannerService
                  .sharedInstance.user.habits[i].habitTrackerMap["Saturday"]!,
              onChanged: (bool? value) {
                print(value);
                setState(() {
                  PlannerService.sharedInstance.user.habits[i]
                      .habitTrackerMap["Saturday"] = value!;
                });
              },
            ),
          ),
        ),
      ]);
      tableRows.add(tableRow);
    }

    return tableRows;
  }

  @override
  Widget build(BuildContext context) {
    //MaterialApp is a flutter class which has a constructor
    //List<Widget> todayTasksView = buildTodayTaskListView();
    //List<TableRow> habitTableRows = buildHabitsView();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Image.asset(
              PlannerService.sharedInstance.user.profileImage,
              // height: 40,
              // width: 40,
            ),
            tooltip: 'Menu',
            onPressed: () {
              // handle the press
              openProfileView();
            },
          ),
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
        automaticallyImplyLeading: false,
        //title: const Text('Home Page'),
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //       image: DecorationImage(
        //           image: AssetImage(
        //             "assets/images/login_screens_background.png",
        //           ),
        //           fit: BoxFit.fill)),
        // ),
        // title: Text(
        //   "My PLANIT",
        //   style: TextStyle(color: Colors.white),
        // ),
        // centerTitle: true,

        title: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login_screens_background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              children: [
                Container(
                  // child: Text("hi"),
                  child: Column(
                    children: [
                      Text(
                        daysMap[DateTime.now().weekday]!,
                      ),
                      Text(
                        DateTime.now().day.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  color: Colors.white,
                  //margin: EdgeInsets.all(20),
                  // margin: EdgeInsets.only(top: 10),
                  // margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(5),
                ),
                // Container(
                //   child: Column(
                //     children: [],
                //   ),
                // ),
                const Text(
                  "PLANIT of CANDY",
                  style: TextStyle(
                    
                      fontStyle: FontStyle.italic, color: Colors.white),
                  // textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          margin: EdgeInsets.all(15),
        ),
      ),
      body: Container(
        //child: Expanded(
        child: ListView(
          children: [
            // Image.asset(
            //   "assets/images/pink_planit.png",
            //   height: 100,
            //   width: 100,
            // ),
            Container(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "This Week's Habits...",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    child: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                      },
                      children: [
                            TableRow(children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.fill,
                                child: Container(
                                    // child: Text(
                                    //   "Habits",
                                    //   textAlign: TextAlign.center,
                                    //   style: TextStyle(
                                    //     //color: Theme.of(context).colorScheme.primary,
                                    //     color: Colors.black,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    // ),
                                    //margin: EdgeInsets.only(left: 10, right: 10),
                                    ),
                              ),
                              TableCell(
                                  child: Container(
                                      child: const Text("S",
                                          textAlign: TextAlign.center))),
                              TableCell(
                                  child: const Text("M",
                                      textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("T", textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("W", textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("TH", textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("F", textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("S", textAlign: TextAlign.center)),
                            ])
                          ] +
                          List.generate(
                              PlannerService.sharedInstance.user.habits.length,
                              (int i) {
                            return TableRow(children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Container(
                                  child: TextButton(
                                    child: Text(
                                      PlannerService.sharedInstance.user
                                          .habits[i].description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      print("Buttton was pressed");
                                      //habitClicked(i);
                                      setEditHabitBtnState();
                                      editHabitTxtController.text =
                                          PlannerService.sharedInstance.user
                                              .habits[i].description;
                                      showDialog(
                                          context: context,
                                          barrierColor: Colors.black26,
                                          builder: (context) => AlertDialog(
                                                title: Text("Edit"),
                                                content: TextFormField(
                                                  controller:
                                                      editHabitTxtController,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: "Description",
                                                  ),
                                                  validator: (String? value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter some text';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                actions: [
                                                  TextButton(
                                                      child: const Text('save'),
                                                      onPressed:
                                                          saveHabitBtnDisabled
                                                              ? null
                                                              : saveNewHabit),
                                                  TextButton(
                                                    child: const Text('cancel'),
                                                    onPressed: () {
                                                      newHabitTextController
                                                          .text = "";
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  )
                                                ],
                                              ));
                                    },
                                  ),
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user
                                        .habits[i].habitTrackerMap["Sunday"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      setState(() {
                                        PlannerService
                                            .sharedInstance
                                            .user
                                            .habits[i]
                                            .habitTrackerMap["Sunday"] = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user
                                        .habits[i].habitTrackerMap["Mon"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      setState(() {
                                        PlannerService
                                            .sharedInstance
                                            .user
                                            .habits[i]
                                            .habitTrackerMap["Mon"] = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user
                                        .habits[i].habitTrackerMap["Tues"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      setState(() {
                                        PlannerService
                                            .sharedInstance
                                            .user
                                            .habits[i]
                                            .habitTrackerMap["Tues"] = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user
                                        .habits[i].habitTrackerMap["Wed"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      setState(() {
                                        PlannerService
                                            .sharedInstance
                                            .user
                                            .habits[i]
                                            .habitTrackerMap["Wed"] = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user
                                        .habits[i].habitTrackerMap["Thurs"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      setState(() {
                                        PlannerService
                                            .sharedInstance
                                            .user
                                            .habits[i]
                                            .habitTrackerMap["Thurs"] = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user
                                        .habits[i].habitTrackerMap["Friday"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      setState(() {
                                        PlannerService
                                            .sharedInstance
                                            .user
                                            .habits[i]
                                            .habitTrackerMap["Friday"] = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user
                                        .habits[i].habitTrackerMap["Saturday"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      setState(() {
                                        PlannerService
                                                .sharedInstance
                                                .user
                                                .habits[i]
                                                .habitTrackerMap["Saturday"] =
                                            value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ]);
                          }),
                    ),
                    margin: EdgeInsets.only(top: 20),
                  ),
                  TextButton(
                      onPressed: addNewHabitClicked,
                      child: Text("Add New Habit"))
                ],
              ),
              margin: EdgeInsets.all(15),
            ),
            Container(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/deadline_icon.png",
                          height: 40,
                          width: 40,
                        ),
                        Text(
                          "Upcoming Deadlines & Events",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  //Column(children: [ListTile(leading: ,)],)
                  Container(
                    child: Container(
                      child: SfCalendar(
                        view: CalendarView.schedule,
                        dataSource: EventDataSource(
                            PlannerService.sharedInstance.user.allEvents +
                                PlannerService.sharedInstance.user.goals),
                        scheduleViewSettings: const ScheduleViewSettings(
                            hideEmptyScheduleWeek: true,
                            monthHeaderSettings: MonthHeaderSettings(
                              monthFormat: 'MMMM, yyyy',
                              height: 60,
                              textAlign: TextAlign.center,
                              backgroundColor: Color(0xFF3700AD),
                            )),
                        // scheduleViewSettings: ScheduleViewSettings(
                        //   appointmentItemHeight: 70,
                        // ),
                      ),
                    ),
                    margin: EdgeInsets.only(top: 20),
                  ),
                ],
              ),
              margin: EdgeInsets.all(15),
            ),
          ],
        ),
        //),
        margin: EdgeInsets.all(15),
      ),
      // body: Column(
      //   children: const [
      //     Text("Today..."),
      //   ],
      // ),
    );
  }

  addNewHabitClicked() {
    showDialog(
      context: context, // user must tap button!

      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            //insetPadding: EdgeInsets.symmetric(vertical: 200, horizontal: 100),
            //child: Expanded(
            //child: Container(
            title: const Text("New Habit"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: addNewHabitDialogContent(setDialogState),
            // content: TextFormField(
            //   controller: newHabitTextController,
            //   decoration: const InputDecoration(
            //     hintText: "Description",
            //   ),
            //   validator: (String? value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please enter some text';
            //     }
            //     return null;
            //   },
            // ),
            actions: <Widget>[
              TextButton(
                  child: const Text('save'),
                  onPressed: saveHabitBtnDisabled ? null : saveNewHabit),
              TextButton(
                child: const Text('cancel'),
                onPressed: () {
                  newHabitTextController.text = "";
                  Navigator.of(context).pop();
                },
              )
            ],
            // ),
            //),
          );
        });
      },
    );
  }

  void saveNewHabit() {
    var newHabit = Habit(newHabitTextController.text);
    setState(() {
      PlannerService.sharedInstance.user.habits.add(newHabit);
      newHabitTextController.text = "";
    });
    Navigator.of(context).pop();
  }

  addNewHabitDialogContent(StateSetter setDialogState) {
    return TextFormField(
      controller: newHabitTextController,
      onChanged: (text) {
        setDialogState(() {
          if (text != "") {
            setState(() {
              print("button enabled");
              saveHabitBtnDisabled = false;
            });
          } else {
            setState(() {
              saveHabitBtnDisabled = true;
            });
          }
        });
      },
      decoration: const InputDecoration(
        hintText: "Description",
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  void setEditHabitBtnState() {
    if (editHabitTxtController.text != "") {
      setState(() {
        print("button enabled");
        editHabitBtnDisabled = false;
      });
    } else {
      setState(() {
        editHabitBtnDisabled = true;
      });
    }
  }

  void setSaveHabitBtnState() {
    print("I am ttyping");
    if (newHabitTextController.text != "") {
      setState(() {
        print("button enabled");
        saveHabitBtnDisabled = false;
      });
    } else {
      setState(() {
        saveHabitBtnDisabled = true;
      });
    }
  }

  // showHabitDialog(int idx) async {
  //   showDialog(
  //       context: context, // user must tap button!
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(builder: (context, setDialogState) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20.0),
  //           ),
  //           content: ,
  //           actions: <Widget>[
  //             TextButton(
  //                 child: const Text('save'),
  //                 onPressed: editHabitBtnDisabled ? null : editHabit(idx)),
  //             TextButton(
  //               child: const Text('cancel'),
  //               onPressed: () {
  //                 newHabitTextController.text = "";
  //                 Navigator.of(context).pop();
  //               },
  //             )
  //           ],
  //           // ),
  //           //),
  //         );
  //       });
  //   },
  //   );
  // }

  habitClicked(int idx) {
    print("in habit clicked func");
    editHabitTxtController.text =
        PlannerService.sharedInstance.user.habits[idx].description;
    Future<void>.delayed(
      const Duration(), // OR const Duration(milliseconds: 500),
      () => showDialog(
        context: context, // user must tap button!
        builder: (BuildContext context) {
          //return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("New Habit"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            //content: showHabitDialogContent(setDialogState, idx),
            content: TextFormField(
              controller: editHabitTxtController,
              decoration: const InputDecoration(
                hintText: "Description",
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text('save'),
                  onPressed: editHabitBtnDisabled ? null : editHabit(idx)),
              TextButton(
                child: const Text('cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
          //});
        },
      ),
    );
    // showDialog(
    //   context: context, // user must tap button!
    //   builder: (BuildContext context) {
    //     //return StatefulBuilder(builder: (context, setDialogState) {
    //     return AlertDialog(
    //       title: const Text("New Habit"),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(20.0),
    //       ),
    //       //content: showHabitDialogContent(setDialogState, idx),
    //       content: TextFormField(
    //         controller: editHabitTxtController,
    //         decoration: const InputDecoration(
    //           hintText: "Description",
    //         ),
    //         validator: (String? value) {
    //           if (value == null || value.isEmpty) {
    //             return 'Please enter some text';
    //           }
    //           return null;
    //         },
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //             child: const Text('save'),
    //             onPressed: editHabitBtnDisabled ? null : editHabit(idx)),
    //         TextButton(
    //           child: const Text('cancel'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         )
    //       ],
    //     );
    //     //});
    //   },
    // );
  }

  showHabitDialogContent(StateSetter setDialogState, int idx) {
    return TextFormField(
      controller: editHabitTxtController,
      onChanged: (text) {
        setDialogState(() {
          if (text != "") {
            setState(() {
              print("button enabled");
              editHabitBtnDisabled = false;
            });
          } else {
            setState(() {
              editHabitBtnDisabled = true;
            });
          }
        });
      },
      decoration: const InputDecoration(
        hintText: "Description",
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  editHabit(int idx) {
    //setState(() {
    PlannerService.sharedInstance.user.habits[idx].description =
        editHabitTxtController.text;
    //});
    Navigator.of(context).pop();
  }
}
