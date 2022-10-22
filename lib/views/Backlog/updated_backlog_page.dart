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
import 'package:flutter/services.dart';
import 'package:badges/badges.dart';

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
  List<Widget> currentlyShownBacklogItems = [];
  List<BacklogMapRef> backlogItemsToShow = [];
  List<BacklogMapRef> scheduledItemsToShow = [];
  List<BacklogMapRef> completedItemsToShow = [];

  var selectedCategories =
      PlannerService.sharedInstance.user!.LifeCategoriesColorMap;
  var selectedCategoriesScheduledView =
      PlannerService.sharedInstance.user!.LifeCategoriesColorMap;
  final List<bool> _selectedPageView = <bool>[true, false, false];
  int selectedMode = 0;
  bool showBadge = false;

  @override
  void initState() {
    super.initState();
    ////print(PlannerService.sharedInstance.user.backlog);
    buildBacklogList();
    buildScheduledList();
    buildCompletedList();
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
    //print("I am in update backlog");
    //setState(() {});
    buildBacklogList();
    buildScheduledList();
    buildCompletedList();
  }

  openEditBacklogItemPage(int idx, String category) {
    //print(PlannerService.sharedInstance.user!.backlogMap[category]![idx]);
    Navigator.pop(context);
    if (PlannerService
            .sharedInstance.user!.backlogMap[category]![idx].calendarItemRef !=
        null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Text(
                "This item is scheduled on your calendar so it cannot be edited. Remove this from your calendar to edit.",
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } else {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => EditTaskPage(
                    updateBacklog: _updateBacklogList,
                    id: idx,
                    category: category,
                  )));
    }
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
                  //first call server
                  var taskId = PlannerService
                      .sharedInstance.user!.backlogMap[key]![idx].id;
                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/backlog/' +
                      taskId.toString());
                  var response = await http.delete(
                    url,
                  );
                  //print('Response status: ${response.statusCode}');
                  //print('Response body: ${response.body}');

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
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
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
    // if (PlannerService
    //         .sharedInstance.user!.backlogMap[key]![idx].calendarItemRef !=
    //     null) {
    Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Text(
              "Navigate to the scheduled date on your calendar to unschedule this item",
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
//     } else {
//       Navigator.of(context).pop();
//       showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Container(
//                 child: const Text(
//                   "Are you sure you want to unschedule this backlog item?",
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               content: const Text(
//                   "This will not delete the backlog item. It will be removed from your calendar and moved to your backlog."),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('yes, unschedule'),
//                   onPressed: () async {
//                     //first check of the item is scheduled on calendar, if so, show a dialog

// //unschedule on server, just remove scheduled date from backlog id
//                     var body = {
//                       'taskId': PlannerService
//                           .sharedInstance.user!.backlogMap[key]![idx].id
//                     };
//                     String bodyF = jsonEncode(body);
//                     //print(bodyF);

//                     var url = Uri.parse(
//                         PlannerService.sharedInstance.serverUrl +
//                             '/backlog/unscheduletask');
//                     var response = await http.post(url,
//                         headers: {"Content-Type": "application/json"},
//                         body: bodyF);
//                     //print('Response status: ${response.statusCode}');
//                     //print('Response body: ${response.body}');

//                     if (response.statusCode == 200) {
//                       print("unscheduling successful");
//                       //setState(() {});
//                       setState(() {
//                         DateTime scheduledDate = DateTime(
//                             PlannerService.sharedInstance.user!
//                                 .backlogMap[key]![idx].scheduledDate!.year,
//                             PlannerService.sharedInstance.user!
//                                 .backlogMap[key]![idx].scheduledDate!.month,
//                             PlannerService.sharedInstance.user!
//                                 .backlogMap[key]![idx].scheduledDate!.day);

//                         print(scheduledDate);
//                         print(PlannerService.sharedInstance.user!
//                             .scheduledBacklogItemsMap.keys);

//                         BacklogMapRef bmr =
//                             BacklogMapRef(categoryName: key, arrayIdx: idx);

//                         PlannerService.sharedInstance.user!
//                             .scheduledBacklogItemsMap[scheduledDate]!
//                             .remove(bmr);

//                         PlannerService.sharedInstance.user!
//                             .backlogMap[key]![idx].scheduledDate = null;
//                       });
//                       Navigator.pop(context);
//                       //}
//                     } else {
//                       //500 error, show an alert
//                       showDialog(
//                           context: context,
//                           builder: (context) {
//                             return AlertDialog(
//                               title: Text(
//                                   'Oops! Looks like something went wrong. Please try again.'),
//                               actions: <Widget>[
//                                 TextButton(
//                                   child: Text('OK'),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 )
//                               ],
//                             );
//                           });
//                     }
//                   },
//                 ),
//                 TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text('cancel'))
//               ],
//             );
//           });
//     }
  }

  void viewCompletedBacklogItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Container(
              child: Text(
                PlannerService
                    .sharedInstance
                    .user!
                    .backlogMap[completedItemsToShow[index].categoryName]![
                        completedItemsToShow[index].arrayIdx]
                    .description,
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
                      DateFormat.yMMMd().format(PlannerService
                          .sharedInstance
                          .user!
                          .backlogMap[
                              completedItemsToShow[index].categoryName]![
                              completedItemsToShow[index].arrayIdx]
                          .completeBy!),
                  style: const TextStyle(
                    // fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                Text(PlannerService
                    .sharedInstance
                    .user!
                    .backlogMap[completedItemsToShow[index].categoryName]![
                        completedItemsToShow[index].arrayIdx]
                    .notes)
              ],
            ),
            //),
            //),
            actions: <Widget>[
              TextButton(
                child: const Text('Move to Backlog'),
                onPressed: () async {
                  // Navigator.of(context).pop();
                  //make call to server
                  var body = {
                    'taskId': PlannerService
                        .sharedInstance
                        .user!
                        .backlogMap[completedItemsToShow[index].categoryName]![
                            completedItemsToShow[index].arrayIdx]
                        .id,
                    'status': "notStarted"
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
                    print("status update successful when moving to backlog");
                    setState(() {
                      PlannerService
                          .sharedInstance
                          .user!
                          .backlogMap[
                              completedItemsToShow[index].categoryName]![
                              completedItemsToShow[index].arrayIdx]
                          .status = "notStarted";

                      completedItemsToShow.removeAt(index);
                    });
                    _updateBacklogList();
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();

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
                  child: const Text('close'))
            ],
          );
        });
  }

  void viewScheduledBacklogItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Container(
              child: Text(
                PlannerService
                    .sharedInstance
                    .user!
                    .backlogMap[scheduledItemsToShow[index].categoryName]![
                        scheduledItemsToShow[index].arrayIdx]
                    .description,
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
                  "Scheduled for " +
                      DateFormat.yMMMd().format(PlannerService
                          .sharedInstance
                          .user!
                          .backlogMap[
                              scheduledItemsToShow[index].categoryName]![
                              scheduledItemsToShow[index].arrayIdx]
                          .completeBy!),
                  style: const TextStyle(
                    // fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                Text(PlannerService
                    .sharedInstance
                    .user!
                    .backlogMap[scheduledItemsToShow[index].categoryName]![
                        scheduledItemsToShow[index].arrayIdx]
                    .notes)
              ],
            ),
            //),
            //),
            actions: <Widget>[
              TextButton(
                child: new Text('edit'),
                onPressed: () {
                  openEditBacklogItemPage(scheduledItemsToShow[index].arrayIdx,
                      scheduledItemsToShow[index].categoryName);
                },
              ),
              TextButton(
                child: const Text('unschedule'),
                onPressed: () {
                  unscheduleBacklogItem(scheduledItemsToShow[index].arrayIdx,
                      scheduledItemsToShow[index].categoryName);
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
  }

  void openViewDialog(BacklogItem backlogItem, int idx, String key) {
    //item is not scheduled
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
                    ? Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "Deadline " +
                              DateFormat.yMMMd()
                                  .format(backlogItem.completeBy!),
                          style: const TextStyle(
                            // fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("No deadline"),
                      ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(backlogItem.notes),
                ),
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
  }

  buildCompletedList() {
    print("I am in build complete list");
    //new implementation idea
    List<BacklogMapRef> tempCompletedItemsToShow = [];

    selectedCategories.forEach((key, value) {
      List<BacklogItem> list =
          PlannerService.sharedInstance.user!.backlogMap[key]!;
      for (int i = 0; i < list.length; i++) {
        if (list[i].status == "complete") {
          BacklogMapRef bmr = BacklogMapRef(categoryName: key, arrayIdx: i);
          tempCompletedItemsToShow.add(bmr);
          print("I just added to templCompleted");
        }
      }
    });

    tempCompletedItemsToShow.sort((backlogItem1, backlogItem2) {
      DateTime backlogItem1Date = PlannerService
          .sharedInstance
          .user!
          .backlogMap[backlogItem1.categoryName]![backlogItem1.arrayIdx]
          .completeBy!;
      DateTime backlogItem2Date = PlannerService
          .sharedInstance
          .user!
          .backlogMap[backlogItem2.categoryName]![backlogItem2.arrayIdx]
          .completeBy!;
      return backlogItem1Date.compareTo(backlogItem2Date);
    });

    setState(() {
      completedItemsToShow = tempCompletedItemsToShow;
    });
  }

  buildCompletedListView() {
    return Column(
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
                          PlannerService
                              .sharedInstance.user!.lifeCategories[index].name);

                      if (isSelected) {
                        setState(() {
                          selectedCategories.remove(PlannerService
                              .sharedInstance.user!.lifeCategories[index].name);
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
                      //updateCurrentlyShownBacklogCards();
                      buildCompletedList();
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
        Padding(
          padding: EdgeInsets.all(10),
          child: ToggleButtons(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: Text('Backlog'),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text('Scheduled'),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text("Complete"),
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
        Expanded(
          child: completedItemsToShow.isEmpty
              ? Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "No scheduled tasks. Use the calendar tab to schedule tasks.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ))
              : ListView(
                  //children: buildBacklogListView(),
                  //children: currentlyShownBacklogItems,
                  children: List.generate(completedItemsToShow.length, (index) {
                    return GestureDetector(
                        onTap: () {
                          viewCompletedBacklogItem(index);
                          // openViewDialog(
                          //     PlannerService.sharedInstance.user!.backlogMap[
                          //             scheduledItemsToShow[index]
                          //                 .categoryName]![
                          //         scheduledItemsToShow[index].arrayIdx],
                          //     scheduledItemsToShow[index].arrayIdx,
                          //     scheduledItemsToShow[index].categoryName);
                        },
                        child: Card(
                          margin: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[completedItemsToShow[index]
                                              .categoryName]![
                                          completedItemsToShow[index].arrayIdx]
                                      .status ==
                                  "notStarted"
                              ? Colors.grey.shade100
                              : (PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[
                                              completedItemsToShow[index]
                                                  .categoryName]![
                                              completedItemsToShow[index]
                                                  .arrayIdx]
                                          .status ==
                                      "complete"
                                  ? Colors.green.shade200
                                  : Colors.yellow.shade200),
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(
                              Icons.circle,
                              color: PlannerService.sharedInstance.user!
                                      .LifeCategoriesColorMap[
                                  completedItemsToShow[index].categoryName],
                            ),
                            title: Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text(
                                PlannerService
                                    .sharedInstance
                                    .user!
                                    .backlogMap[completedItemsToShow[index]
                                            .categoryName]![
                                        completedItemsToShow[index].arrayIdx]
                                    .description,
                                style: const TextStyle(
                                    // color: PlannerService.sharedInstance.user!
                                    //     .backlogMap[key]![i].category.color,
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            trailing: Icon(
                              Icons.check_rounded,
                              color: Theme.of(context).primaryColor,
                            ),

                            // subtitle: Text(
                            //   "Scheduled for " +
                            //       DateFormat.yMMMd().format(PlannerService
                            //           .sharedInstance
                            //           .user!
                            //           .backlogMap[completedItemsToShow[index]
                            //                   .categoryName]![
                            //               completedItemsToShow[index].arrayIdx]
                            //           .completeBy!),
                            //   textAlign: TextAlign.center,
                            // ),
                          ),
                        ));
                  }),
                ),
        )
      ],
    );
  }

  buildScheduledListView() {
    return Column(
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
                          PlannerService
                              .sharedInstance.user!.lifeCategories[index].name);

                      if (isSelected) {
                        setState(() {
                          selectedCategories.remove(PlannerService
                              .sharedInstance.user!.lifeCategories[index].name);
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
                      //updateCurrentlyShownBacklogCards();
                      buildScheduledList();
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
        Padding(
          padding: EdgeInsets.all(10),
          child: ToggleButtons(
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: Text('Backlog'),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text('Scheduled'),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text('Complete'),
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
        Expanded(
          child: scheduledItemsToShow.isEmpty
              ? Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "No scheduled tasks. Use the calendar tab to schedule tasks.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ))
              : ListView(
                  //children: buildBacklogListView(),
                  //children: currentlyShownBacklogItems,
                  children: List.generate(scheduledItemsToShow.length, (index) {
                    return GestureDetector(
                        onTap: () {
                          viewScheduledBacklogItem(index);
                          // openViewDialog(
                          //     PlannerService.sharedInstance.user!.backlogMap[
                          //             scheduledItemsToShow[index]
                          //                 .categoryName]![
                          //         scheduledItemsToShow[index].arrayIdx],
                          //     scheduledItemsToShow[index].arrayIdx,
                          //     scheduledItemsToShow[index].categoryName);
                        },
                        child: Card(
                          margin: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[scheduledItemsToShow[index]
                                              .categoryName]![
                                          scheduledItemsToShow[index].arrayIdx]
                                      .status ==
                                  "notStarted"
                              ? Colors.grey.shade100
                              : (PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[
                                              scheduledItemsToShow[index]
                                                  .categoryName]![
                                              scheduledItemsToShow[index]
                                                  .arrayIdx]
                                          .status ==
                                      "complete"
                                  ? Colors.green.shade200
                                  : Colors.yellow.shade200),
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(
                              Icons.circle,
                              color: PlannerService.sharedInstance.user!
                                      .LifeCategoriesColorMap[
                                  scheduledItemsToShow[index].categoryName],
                            ),
                            title: Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text(
                                PlannerService
                                    .sharedInstance
                                    .user!
                                    .backlogMap[scheduledItemsToShow[index]
                                            .categoryName]![
                                        scheduledItemsToShow[index].arrayIdx]
                                    .description,
                                style: const TextStyle(
                                    // color: PlannerService.sharedInstance.user!
                                    //     .backlogMap[key]![i].category.color,
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // subtitle: Text(
                            //   "Complete by " +
                            //       DateFormat.yMMMd().format(PlannerService
                            //           .sharedInstance
                            //           .user!
                            //           .backlogMap[scheduledItemsToShow[index]
                            //                   .categoryName]![
                            //               scheduledItemsToShow[index].arrayIdx]
                            //           .completeBy!),
                            //   textAlign: TextAlign.center,
                            // ),
                            subtitle: Text(
                              "Scheduled for " +
                                  DateFormat.yMMMd().format(PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[scheduledItemsToShow[index]
                                              .categoryName]![
                                          scheduledItemsToShow[index].arrayIdx]
                                      .scheduledDate!),
                              textAlign: TextAlign.center,
                            ),
                            // trailing: Checkbox(
                            //   value: PlannerService
                            //       .sharedInstance
                            //       .user!
                            //       .backlogMap[scheduledItemsToShow[index]
                            //               .categoryName]![
                            //           scheduledItemsToShow[index].arrayIdx]
                            //       .isComplete,
                            //   shape: const CircleBorder(),
                            //   onChanged: (bool? value) {
                            //     //print(value);
                            //     setState(() {
                            //       PlannerService
                            //           .sharedInstance
                            //           .user!
                            //           .backlogMap[scheduledItemsToShow[index]
                            //                   .categoryName]![
                            //               scheduledItemsToShow[index].arrayIdx]
                            //           .isComplete = value;

                            //       //_value = value!;
                            //     });
                            //   },
                            // ),
                          ),
                        ));
                  }),
                ),
        )
      ],
    );
  }

  Widget buildBacklogListView() {
    return Column(
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
                          PlannerService
                              .sharedInstance.user!.lifeCategories[index].name);

                      if (isSelected) {
                        setState(() {
                          selectedCategories.remove(PlannerService
                              .sharedInstance.user!.lifeCategories[index].name);
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
                      //updateCurrentlyShownBacklogCards();
                      buildBacklogList();
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
        Padding(
            padding: EdgeInsets.all(10),
            child: Badge(
              badgeColor: Theme.of(context).primaryColor,
              toAnimate: true,
              position: BadgePosition.topEnd(),
              badgeContent: Icon(
                Icons.plus_one_rounded,
                color: Colors.white,
              ),
              child: ToggleButtons(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Backlog'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Scheduled'),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Complete'),
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
              showBadge: showBadge,
            )),
        Expanded(
          child: backlogItemsToShow.isEmpty
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
                  //children: buildBacklogListView(),
                  //children: currentlyShownBacklogItems,
                  children: List.generate(backlogItemsToShow.length, (index) {
                    return GestureDetector(
                        onTap: () {
                          openViewDialog(
                              PlannerService.sharedInstance.user!.backlogMap[
                                      backlogItemsToShow[index].categoryName]![
                                  backlogItemsToShow[index].arrayIdx],
                              backlogItemsToShow[index].arrayIdx,
                              backlogItemsToShow[index].categoryName);
                        },
                        child: Card(
                          margin: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[backlogItemsToShow[index]
                                              .categoryName]![
                                          backlogItemsToShow[index].arrayIdx]
                                      .status ==
                                  "notStarted"
                              ? Colors.grey.shade100
                              : (PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[backlogItemsToShow[index]
                                                  .categoryName]![
                                              backlogItemsToShow[index]
                                                  .arrayIdx]
                                          .status ==
                                      "complete"
                                  ? Colors.green.shade200
                                  : Colors.yellow.shade200),
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(
                              Icons.circle,
                              color: PlannerService.sharedInstance.user!
                                      .LifeCategoriesColorMap[
                                  backlogItemsToShow[index].categoryName],
                            ),
                            title: Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text(
                                PlannerService
                                    .sharedInstance
                                    .user!
                                    .backlogMap[backlogItemsToShow[index]
                                            .categoryName]![
                                        backlogItemsToShow[index].arrayIdx]
                                    .description,
                                style: const TextStyle(
                                    // color: PlannerService.sharedInstance.user!
                                    //     .backlogMap[key]![i].category.color,
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            subtitle: Text(
                              "Complete by " +
                                  DateFormat.yMMMd().format(PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[backlogItemsToShow[index]
                                              .categoryName]![
                                          backlogItemsToShow[index].arrayIdx]
                                      .completeBy!),
                              textAlign: TextAlign.center,
                            ),
                            trailing: Checkbox(
                              value: PlannerService
                                          .sharedInstance
                                          .user!
                                          .backlogMap[backlogItemsToShow[index]
                                                  .categoryName]![
                                              backlogItemsToShow[index]
                                                  .arrayIdx]
                                          .status ==
                                      "complete"
                                  ? true
                                  : false,
                              shape: const CircleBorder(),
                              onChanged: (bool? value) async {
                                setState(() {
                                  PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[backlogItemsToShow[index]
                                              .categoryName]![
                                          backlogItemsToShow[index].arrayIdx]
                                      .isComplete = value;
                                  PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[backlogItemsToShow[index]
                                              .categoryName]![
                                          backlogItemsToShow[index].arrayIdx]
                                      .status = "complete";
                                  HapticFeedback.mediumImpact();
                                  showBadge = true;
                                });
                                await Future.delayed(const Duration(seconds: 1),
                                    () {
                                  setState(() {
                                    showBadge = false;
                                  });
                                });
                                //make call to server
                                var body = {
                                  'taskId': PlannerService
                                      .sharedInstance
                                      .user!
                                      .backlogMap[backlogItemsToShow[index]
                                              .categoryName]![
                                          backlogItemsToShow[index].arrayIdx]
                                      .id,
                                  'status': "complete"
                                };
                                String bodyF = jsonEncode(body);
                                //print(bodyF);

                                var url = Uri.parse(
                                    PlannerService.sharedInstance.serverUrl +
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
                                  //       .backlogMap[backlogItemsToShow[index]
                                  //               .categoryName]![
                                  //           backlogItemsToShow[index].arrayIdx]
                                  //       .isComplete = value;
                                  //   PlannerService
                                  //       .sharedInstance
                                  //       .user!
                                  //       .backlogMap[backlogItemsToShow[index]
                                  //               .categoryName]![
                                  //           backlogItemsToShow[index].arrayIdx]
                                  //       .status = "complete";
                                  //   HapticFeedback.mediumImpact();
                                  //   showBadge = true;
                                  // });
                                  // await Future.delayed(
                                  //     const Duration(seconds: 1), () {
                                  //   setState(() {
                                  //     showBadge = false;
                                  //   });
                                  // });
                                  _updateBacklogList();
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
                                //print(value);
                                // setState(() {
                                //   PlannerService
                                //       .sharedInstance
                                //       .user!
                                //       .backlogMap[backlogItemsToShow[index]
                                //               .categoryName]![
                                //           backlogItemsToShow[index].arrayIdx]
                                //       .isComplete = value;

                                //   //_value = value!;
                                // });
                              },
                            ),
                          ),
                        ));
                  }),
                ),
        )
      ],
    );
  }

  buildScheduledList() {
    List<BacklogMapRef> tempScheduledItemsToShow = [];
    List<BacklogMapRef> scheduledItems = [];
    PlannerService.sharedInstance.user!.scheduledBacklogItemsMap
        .forEach((key, value) {
      List<BacklogMapRef> list =
          PlannerService.sharedInstance.user!.scheduledBacklogItemsMap[key]!;
      for (int i = 0; i < list.length; i++) {
        if (PlannerService.sharedInstance.user!
                .backlogMap[list[i].categoryName]![list[i].arrayIdx].status !=
            "complete") {
          scheduledItems.add(list[i]);
        }
      }
    });

    //
    selectedCategories.forEach((key, value) {
      for (int i = 0; i < scheduledItems.length; i++) {
        if (scheduledItems[i].categoryName == key) {
          tempScheduledItemsToShow.add(scheduledItems[i]);
        }
      }
    });

    tempScheduledItemsToShow.sort((backlogItem1, backlogItem2) {
      DateTime backlogItem1Date = PlannerService
          .sharedInstance
          .user!
          .backlogMap[backlogItem1.categoryName]![backlogItem1.arrayIdx]
          .scheduledDate!;
      DateTime backlogItem2Date = PlannerService
          .sharedInstance
          .user!
          .backlogMap[backlogItem2.categoryName]![backlogItem2.arrayIdx]
          .scheduledDate!;
      return backlogItem1Date.compareTo(backlogItem2Date);
    });

    setState(() {
      scheduledItemsToShow = tempScheduledItemsToShow;
    });
  }

  buildBacklogList() {
    //new implementation idea
    List<BacklogMapRef> tempbacklogItemsToShow = [];

    selectedCategories.forEach((key, value) {
      List<BacklogItem> list =
          PlannerService.sharedInstance.user!.backlogMap[key]!;
      for (int i = 0; i < list.length; i++) {
        if (list[i].scheduledDate == null && list[i].status != "complete") {
          BacklogMapRef bmr = BacklogMapRef(categoryName: key, arrayIdx: i);
          tempbacklogItemsToShow.add(bmr);
        }
      }
    });

    tempbacklogItemsToShow.sort((backlogItem1, backlogItem2) {
      DateTime backlogItem1Date = PlannerService
          .sharedInstance
          .user!
          .backlogMap[backlogItem1.categoryName]![backlogItem1.arrayIdx]
          .completeBy!;
      DateTime backlogItem2Date = PlannerService
          .sharedInstance
          .user!
          .backlogMap[backlogItem2.categoryName]![backlogItem2.arrayIdx]
          .completeBy!;
      return backlogItem1Date.compareTo(backlogItem2Date);
    });

    setState(() {
      backlogItemsToShow = tempbacklogItemsToShow;
    });
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

    // buildBacklogList();
    // buildScheduledList();
    // buildCompletedList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.transparent,
        title: Text(
          "Tasks",
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
      body: selectedMode == 0
          ? buildBacklogListView()
          : selectedMode == 1
              ? buildScheduledListView()
              : buildCompletedListView(),

      floatingActionButton: selectedMode == 0
          ? FloatingActionButton(
              onPressed: _openNewBacklogItemPage,
              tooltip: 'Create new task.',
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : Container(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
