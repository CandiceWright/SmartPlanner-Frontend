import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_planner/models/backlog_item.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/views/Backlog/edit_task_page.dart';
import 'package:practice_planner/views/Backlog/new_task_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class BacklogPage extends StatefulWidget {
  const BacklogPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<BacklogPage> createState() => _BacklogPageState();
}

class _BacklogPageState extends State<BacklogPage> {
  //bool _value = false;
  //var backlog = PlannerService.sharedInstance.user.backlog;
  FontWeight? expandedTileFontWeight = FontWeight.bold;
  // List<Widget> currentlyShownBacklogItems = [];
  Map<String, List<Widget>> backlogItemCardsMap = {};
  var selectedCategories =
      PlannerService.sharedInstance.user!.LifeCategoriesColorMap;

  @override
  void initState() {
    super.initState();
    //print(PlannerService.sharedInstance.user.backlog);
  }

  void _openNewBacklogItemPage() {
    //this function needs to change to create new goal
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                NewTaskPage(updateBacklog: _updateBacklogList)));
  }

  void _updateBacklogList() {
    print("I am in update backlog");
    setState(() {});
  }

  openEditBacklogItemPage(int idx, String category) {
    print(PlannerService.sharedInstance.user!.backlogMap[category]![idx]);
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

  void deleteBacklogItem(int idx, String key) {
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
                  //first call server
                  var taskId = PlannerService
                      .sharedInstance.user!.backlogMap[key]![idx].id;
                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/backlog/' +
                      taskId.toString());
                  var response = await http.delete(
                    url,
                  );
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    PlannerService.sharedInstance.user!.backlogMap[key]!
                        .removeAt(idx);
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

  void unscheduleBacklogItem(int idx, String key) {
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
                  //first do server stuff
                  var body = {
                    'eventId': PlannerService.sharedInstance.user!
                        .backlogMap[key]![idx].calendarItemRef!.id,
                    'taskId': PlannerService
                        .sharedInstance.user!.backlogMap[key]![idx].id
                  };
                  String bodyF = jsonEncode(body);
                  print(bodyF);

                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/backlog/unscheduletask');
                  var response = await http.post(url,
                      headers: {"Content-Type": "application/json"},
                      body: bodyF);
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    //delete event & unschedule backlog item
                    //first remove event from scheduled events
                    Event calendarItemRef = PlannerService.sharedInstance.user!
                        .backlogMap[key]![idx].calendarItemRef!;
                    PlannerService.sharedInstance.user!.scheduledEvents
                        .removeAt(PlannerService
                            .sharedInstance.user!.scheduledEvents
                            .indexOf(calendarItemRef));

                    //update the backlog item so that it no longer references a scheduled event
                    PlannerService.sharedInstance.user!.backlogMap[key]![idx]
                        .scheduledDate = null;
                    PlannerService.sharedInstance.user!.backlogMap[key]![idx]
                        .calendarItemRef = null;

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

  void openViewDialog(BacklogItem backlogItem, int idx, String key) {
    if (backlogItem.scheduledDate == null) {
      //item is not scheduled
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Container(
                child: Text(
                  backlogItem.description,
                  textAlign: TextAlign.center,
                ),
              ),
              content:
                  //Card(
                  //child: Container(
                  //child: Column(
                  Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  backlogItem.completeBy != null
                      ? Text(
                          "Deadline " +
                              DateFormat.yMMMd()
                                  .format(backlogItem.completeBy!),
                          style: const TextStyle(
                            // fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        )
                      : Text(""),
                  Text(backlogItem.notes)
                ],
              ),
              //),
              //),
              actions: <Widget>[
                TextButton(
                  child: new Text('edit'),
                  onPressed: () {
                    openEditBacklogItemPage(idx, key);
                  },
                ),
                TextButton(
                    onPressed: () {
                      deleteBacklogItem(idx, key);
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
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Container(
                child: Text(
                  backlogItem.description,
                  textAlign: TextAlign.center,
                ),
              ),
              content:
                  //Card(
                  //child: Container(
                  //child: Column(
                  Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Complete by " +
                        DateFormat.yMMMd().format(backlogItem.completeBy!),
                    style: const TextStyle(
                      // fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  Text(backlogItem.notes)
                ],
              ),
              //),
              //),
              actions: <Widget>[
                TextButton(
                  child: const Text('unschedule'),
                  onPressed: () {
                    unscheduleBacklogItem(idx, key);
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
      // var tomorrow = DateTime(
      //     DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
      // if (backlogItem.scheduledDate == tomorrow) {
      //   //scheduled for tomorrow

      // } else { //today

      // }
    }
  }

  buildBacklogListView() {
    print("I am trying to see what the correct value to use is");
    print(PlannerService.sharedInstance.user!.backlogMap.values.isEmpty ||
        (PlannerService.sharedInstance.user!.backlogMap.keys.length == 1 &&
            PlannerService.sharedInstance.user!.backlogMap.entries.first.value
                    .length ==
                0));
    print(PlannerService.sharedInstance.user!.backlogMap.values.length);

    PlannerService.sharedInstance.user!.backlogMap.forEach((key, value) {
      List<Widget> categoryChildren = [];
      print("I am building backlog and this is value.length");
      print(value.length);
      for (int i = 0; i < value.length; i++) {
        // print("trying to find null value:");
        // print("Printing lin 352 below");
        // print(PlannerService
        //     .sharedInstance.user!.backlogMap[key]![i].description);
        // print("printing liine 355 below");
        // print(
        //     PlannerService.sharedInstance.user!.backlogMap[key]![i].isComplete);
        // print("printing line 358 below");
        // print(DateFormat.yMMMd().format(value[i].completeBy!));
        // print(PlannerService.sharedInstance.user!.LifeCategoriesColorMap[key]);

        Widget child = GestureDetector(
          onTap: () {
            openViewDialog(value[i], i, key);
          },
          child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.grey.shade100,
              margin: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.circle,
                      color: PlannerService
                          .sharedInstance.user!.LifeCategoriesColorMap[key],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            PlannerService.sharedInstance.user!
                                .backlogMap[key]![i].description,
                            style: const TextStyle(
                                // color: PlannerService.sharedInstance.user!
                                //     .backlogMap[key]![i].category.color,
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: value[i].completeBy == null
                              ? const Text("")
                              : Text("Deadline " +
                                  DateFormat.yMMMd()
                                      .format(value[i].completeBy!)),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: PlannerService
                        .sharedInstance.user!.backlogMap[key]![i].isComplete,
                    shape: const CircleBorder(),
                    onChanged: (bool? value) {
                      print(value);
                      setState(() {
                        PlannerService.sharedInstance.user!.backlogMap[key]![i]
                            .isComplete = value;
                        //_value = value!;
                      });
                    },
                  ),
                ],
              )),
        );

        //setState(() {
        categoryChildren.add(child);
        //});
      }

      backlogItemCardsMap.addAll({key: categoryChildren});
    });
    return updateCurrentlyShownBacklogCards();
    //return backloglistview;
  }

  List<Widget> updateCurrentlyShownBacklogCards() {
    List<Widget> currentlyShownBacklogItems = [];
    //setState(() {
    selectedCategories.forEach((key, value) {
      setState(() {
        currentlyShownBacklogItems.addAll(backlogItemCardsMap[key]!);
      });
    });
    //});
    return currentlyShownBacklogItems;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //buildBacklogListView();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.transparent,
        title: Text(
          "Backlog",
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
          //style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      title: const Text(
                        "Your backlog holds any tasks that you need to do, but haven't scheduled time on your calendar to do yet.",
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
            },
            icon: const Icon(Icons.info),
          )
        ],
        // bottom: const PreferredSize(
        //     child: Align(
        //       alignment: Alignment.center,
        //       child: Padding(
        //         padding: EdgeInsets.only(bottom: 10),
        //         child: Text(
        //           "Anything I need to do, but haven't scheduled time to do it yet.",
        //           style: TextStyle(color: Colors.white),
        //           //textAlign: TextAlign.center,
        //         ),
        //       ),
        //     ),
        //     preferredSize: Size.fromHeight(10.0)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    PlannerService.sharedInstance.user!.spaceImage,
                  ),
                  fit: BoxFit.fill)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              height: 80.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                    PlannerService.sharedInstance.user!.lifeCategories.length,
                    (int index) {
                  return GestureDetector(
                      onTap: () {
                        //first check if it is selected or not
                        bool isSelected = selectedCategories.containsKey(
                            PlannerService.sharedInstance.user!
                                .lifeCategories[index].name);

                        if (isSelected) {
                          setState(() {
                            selectedCategories.remove(PlannerService
                                .sharedInstance
                                .user!
                                .lifeCategories[index]
                                .name);
                          });
                        } else {
                          setState(() {
                            selectedCategories.addAll({
                              PlannerService.sharedInstance.user!
                                      .lifeCategories[index].name:
                                  PlannerService.sharedInstance.user!
                                      .lifeCategories[index].color
                            });
                          });
                        }
                        updateCurrentlyShownBacklogCards();
                      },
                      child: Card(
                        //margin: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            width: 2.0,
                            color: selectedCategories.containsKey(PlannerService
                                    .sharedInstance
                                    .user!
                                    .lifeCategories[index]
                                    .name)
                                ? Colors.grey.shade700
                                : Colors.transparent,
                          ),
                        ),
                        //color: Colors.white,
                        color: PlannerService
                            .sharedInstance.user!.lifeCategories[index].color,
                        elevation: 0,
                        //shape: const ContinuousRectangleBorder(),
                        shadowColor: PlannerService
                            .sharedInstance.user!.lifeCategories[index].color,
                        //color: Colors.blue[index * 100],
                        child: Flex(direction: Axis.horizontal, children: [
                          Column(
                            //width: 50.0,
                            //height: 50.0,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    PlannerService.sharedInstance.user!
                                        .lifeCategories[index].name,
                                    style: TextStyle(color: Colors.white),
                                  )),
                              // Icon(
                              //   Icons.circle,
                              //   color: PlannerService.sharedInstance.user!
                              //       .lifeCategories[index].color,
                              // ),
                            ],
                          )
                        ]),
                      ));
                }),
              ),
              color: Colors.white,
            ),
          ),
          Expanded(
            child:
                PlannerService.sharedInstance.user!.backlogMap.values.isEmpty ||
                        (PlannerService.sharedInstance.user!.backlogMap.keys
                                    .length ==
                                1 &&
                            PlannerService.sharedInstance.user!.backlogMap
                                    .entries.first.value.length ==
                                0)
                    ? Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "No backlog items have been created yet. Click the plus sign to get started or the info button at the top to learn more.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ))
                    : ListView(
                        children: buildBacklogListView(),
                      ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openNewBacklogItemPage,
        tooltip: 'Create new task.',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
