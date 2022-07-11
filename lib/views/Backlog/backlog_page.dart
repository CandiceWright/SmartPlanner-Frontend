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
                  var url = Uri.parse(
                      'http://192.168.1.4:7343/backlog/' + taskId.toString());
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

                  var url = Uri.parse(
                      'http://192.168.1.4:7343/backlog/unscheduletask');
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
                  Text(
                    "Complete on/by " +
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
                    "Complete on/by " +
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

  List<Widget> buildBacklogListView() {
    //print("building backlog view");
    List<Widget> todayItems = [];
    List<Widget> tomorrowItems = [];

    //build unscheduled backlog
    List<Widget> backloglistview = [];
    PlannerService.sharedInstance.user!.backlogMap.forEach((key, value) {
      List<Widget> unscheduledExpansionTileChildren = [];
      for (int i = 0; i < value.length; i++) {
        Widget child = ListTile(
          title: Text(
            value[i].description,
            // style: const TextStyle(
            //     color: Colors.black, fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Complete on/by " +
              DateFormat.yMMMd().format(value[i].completeBy!)),
          leading: Checkbox(
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
          onTap: () {
            openViewDialog(value[i], i, key);
          },
          // secondary: TextButton(
          //   child: const Text("view"),
          //   onPressed: () {
          //     openViewDialog(value[i], i, key);
          //   },
          // ),
          // secondary: IconButton(
          //   icon: const Icon(Icons.visibility_outlined),
          //   tooltip: 'View this backlog item',
          //   onPressed: () {
          //     setState(() {});
          //   },
          // ),
        );
        // Widget child = CheckboxListTile(
        //   title: Text(
        //     value[i].description,
        //     // style: const TextStyle(
        //     //     color: Colors.black, fontWeight: FontWeight.bold),
        //   ),
        //   subtitle: Text("Complete on/by " +
        //       DateFormat.yMMMd().format(value[i].completeBy!)),
        //   value:
        //       PlannerService.sharedInstance.user.backlogMap[key]![i].isComplete,
        //   shape: const CircleBorder(),
        //   onChanged: (bool? value) {
        //     print(value);
        //     setState(() {
        //       PlannerService
        //           .sharedInstance.user.backlogMap[key]![i].isComplete = value;
        //       //_value = value!;
        //     });
        //   },
        //   secondary: TextButton(
        //     child: const Text("view"),
        //     onPressed: () {
        //       openViewDialog(value[i], i, key);
        //     },
        //   ),
        //   // secondary: IconButton(
        //   //   icon: const Icon(Icons.visibility_outlined),
        //   //   tooltip: 'View this backlog item',
        //   //   onPressed: () {
        //   //     setState(() {});
        //   //   },
        //   // ),
        //   controlAffinity: ListTileControlAffinity.leading,
        // );
        if (value[i].scheduledDate == null) {
          unscheduledExpansionTileChildren.add(child);
        }
        //}
        else {
          print("printing scheduled dates");
          print(value[i].scheduledDate);
          var test = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day);
          print(test);
          if (value[i].scheduledDate!.day == DateTime.now().day) {
            todayItems.add(child);
          } else {
            tomorrowItems.add(child);
          }
        }
      }
      Widget expansionTile = ExpansionTile(
        title: Text(key),
        //initiallyExpanded: true,
        children: unscheduledExpansionTileChildren,
        leading: Icon(
          Icons.circle,
          color:
              PlannerService.sharedInstance.user!.LifeCategoriesColorMap[key],
        ),
        trailing: Text(unscheduledExpansionTileChildren.length.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      );
      backloglistview.add(expansionTile); //1 per category
    });
    //return backloglistview;

    Widget todayExpansionTile = ExpansionTile(
      title: Text(
        "Today",
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      //initiallyExpanded: true,
      children: todayItems,
    );

    Widget tomorrowExpansionTile = ExpansionTile(
      title: Text(
        "Tomorrow",
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      //initiallyExpanded: true,
      children: tomorrowItems,
    );

    Widget unscheduledExpansionTile = ExpansionTile(
      title: Text(
        "Another Day",
        style: GoogleFonts.roboto(
          textStyle: TextStyle(
              color: Colors.black,
              fontWeight: expandedTileFontWeight,
              fontSize: 18),
        ),
        // style: TextStyle(
        //     color: Colors.black,
        //     fontWeight: expandedTileFontWeight,
        //     fontSize: 18),
      ),
      initiallyExpanded: true,
      onExpansionChanged: (expanded) {
        setState(() {
          if (expanded) {
            expandedTileFontWeight = FontWeight.bold;
          } else {
            expandedTileFontWeight = FontWeight.normal;
          }
        });
      },
      children: backloglistview,
      // trailing: Text(value.length.toString(),style: TextStyle(color: Theme.of(context).colorScheme.primary)),
    );

    List<Widget> expansionTiles = [
      todayExpansionTile,
      tomorrowExpansionTile,
      unscheduledExpansionTile
    ];

    return expansionTiles;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    List<Widget> backlogListView = buildBacklogListView();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          "Backlog",
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
          //style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/images/login_screens_background.png",
                  ),
                  fit: BoxFit.fill)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: backlogListView,
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
