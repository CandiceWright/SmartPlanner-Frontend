/* Page used to add multiple backlog items to selected date task list */
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:practice_planner/models/backlog_item.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/views/Backlog/new_task_page.dart';
import 'package:practice_planner/views/Calendar/set_backlog_item_time_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class SelectBacklogItemsPage extends StatefulWidget {
  const SelectBacklogItemsPage(
      {Key? key, required this.updatePotentialCandidates, required this.date})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Function updatePotentialCandidates;
  final DateTime date;

  @override
  State<SelectBacklogItemsPage> createState() => _SelectBacklogItemsPageState();
}

class _SelectBacklogItemsPageState extends State<SelectBacklogItemsPage> {
  bool noUnscheduledBacklogItems = false;
  List<bool> selectedItems = [];
  //List<BacklogItem> backlogItemsList = [];
  List<BacklogMapRef> selectedBacklogItemsList = [];
  List<BacklogMapRef> backlogItemsToShow = [];

  @override
  void initState() {
    super.initState();
    ////print(PlannerService.sharedInstance.user.backlog);
    getNumberUnscheduledBacklogItems();
  }

  void getNumberUnscheduledBacklogItems() {
    int counter = 0;
    PlannerService.sharedInstance.user!.backlogMap.forEach((key, value) {
      for (int i = 0; i < value.length; i++) {
        if (value[i].scheduledDate == null && !value[i].isComplete!) {
          counter++;
        }
      } //1 per category
    });
    if (counter == 0) {
      noUnscheduledBacklogItems = true;
    }
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
    setState(() {});
  }

  List<Widget> buildBacklogListView() {
    backlogItemsToShow = [];

    PlannerService.sharedInstance.user!.backlogMap.forEach((key, value) {
      List<BacklogItem> list =
          PlannerService.sharedInstance.user!.backlogMap[key]!;
      for (int i = 0; i < list.length; i++) {
        //only show items that aren't scheduled
        if (list[i].scheduledDate == null && list[i].status != "complete") {
          //if (list[i].calendarItemRef == null) {
          BacklogMapRef bmr = BacklogMapRef(categoryName: key, arrayIdx: i);
          backlogItemsToShow.add(bmr);
          selectedItems.add(false);
        }
      }
    });

    backlogItemsToShow.sort((backlogItem1, backlogItem2) {
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

    List<Widget> backlogItemCardsToShow = [];

    for (int i = 0; i < backlogItemsToShow.length; i++) {
      Widget child = ListTile(
        leading: Icon(
          Icons.circle,
          color: PlannerService.sharedInstance.user!
              .LifeCategoriesColorMap[backlogItemsToShow[i].categoryName],
        ),
        title: Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Text(
            PlannerService
                .sharedInstance
                .user!
                .backlogMap[backlogItemsToShow[i].categoryName]![
                    backlogItemsToShow[i].arrayIdx]
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
                  .backlogMap[backlogItemsToShow[i].categoryName]![
                      backlogItemsToShow[i].arrayIdx]
                  .completeBy!),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: PlannerService
                              .sharedInstance
                              .user!
                              .backlogMap[backlogItemsToShow[i].categoryName]![
                                  backlogItemsToShow[i].arrayIdx]
                              .completeBy! ==
                          DateTime.now() ||
                      PlannerService
                              .sharedInstance
                              .user!
                              .backlogMap[backlogItemsToShow[i].categoryName]![
                                  backlogItemsToShow[i].arrayIdx]
                              .completeBy! ==
                          DateTime(DateTime.now().year, DateTime.now().month,
                              DateTime.now().day + 1)
                  ? Colors.red
                  : Colors.grey),
        ),
        trailing: Checkbox(
          value: selectedItems[i],
          onChanged: (bool? checked) {
            if (checked!) {
              setState(() {
                selectedItems[i] = true; //the same size as backlogItemsToShow
              });
              HapticFeedback.selectionClick();
            } else {
              setState(() {
                selectedItems[i] = false;
              });
            }
          },
        ),
      );

      backlogItemCardsToShow.add(child);
    }

    return backlogItemCardsToShow;

    // ////print("building backlog view");
    // List<Widget> todayItems = [];
    // List<Widget> tomorrowItems = [];

    // //build unscheduled backlog
    // List<Widget> backloglistview = [];
    // PlannerService.sharedInstance.user!.backlogMap.forEach((key, value) {
    //   List<Widget> unscheduledExpansionTileChildren = [];
    //   for (int i = 0; i < value.length; i++) {
    //     if (value[i].scheduledDate == null && !value[i].isComplete!) {
    //       selectedItems.add(false);
    //       //backlogItemsList.add(value[i]);
    //       Widget child = CheckboxListTile(
    //         title: Text(
    //           value[i].description,
    //           // style: const TextStyle(
    //           //     color: Colors.black, fontWeight: FontWeight.bold),
    //         ),
    //         subtitle: Text(
    //           DateFormat.yMMMd().format(value[i].completeBy!),
    //           style: TextStyle(
    //               color: value[i].completeBy! == DateTime.now() ||
    //                       value[i].completeBy! ==
    //                           DateTime(DateTime.now().year,
    //                               DateTime.now().month, DateTime.now().day + 1)
    //                   ? Colors.red
    //                   : Colors.grey),
    //         ),
    //         value: PlannerService
    //             .sharedInstance.user!.backlogMap[key]![i].isComplete,
    //         onChanged: (bool? checked) {
    //           ////print(value);
    //           BacklogMapRef bmRef =
    //               BacklogMapRef(categoryName: key, arrayIdx: i);
    //           selectedBacklogItemsList.add(bmRef);
    //           selectedItems[i] = true;
    //           //setTime(value[i], bmRef);
    //           // setState(() {
    //           //   PlannerService.sharedInstance.user.backlog[key][i].isComplete =
    //           //       value;
    //           //   //_value = value!;
    //           // });
    //         },
    //         controlAffinity: ListTileControlAffinity.leading,
    //       );
    //       //if (value[i].scheduledDate == null) {
    //       unscheduledExpansionTileChildren.add(child);
    //       //}
    //     }
    //   }
    //   Widget expansionTile = ExpansionTile(
    //     title: Text(key),
    //     initiallyExpanded: true,
    //     children: unscheduledExpansionTileChildren,
    //     leading: Icon(
    //       Icons.circle,
    //       color:
    //           PlannerService.sharedInstance.user!.LifeCategoriesColorMap[key],
    //     ),
    //     trailing: Text(unscheduledExpansionTileChildren.length.toString(),
    //         style: TextStyle(color: Theme.of(context).colorScheme.primary)),
    //   );
    //   backloglistview.add(expansionTile); //1 per category
    // });
    // return backloglistview;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //List<Widget> backlogListView = buildBacklogListView();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // ignore: prefer_const_constructors

        title: const Text(
          "Backlog",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
              onPressed: () async {
                print(widget.date.toString());
                //build selectedBacklogItemsList
                for (int i = 0; i < selectedItems.length; i++) {
                  print("I am in for loop");
                  if (selectedItems[i] == true) {
                    selectedBacklogItemsList.add(backlogItemsToShow[i]);
                    //set scheduled date to widget.date
                    PlannerService
                        .sharedInstance
                        .user!
                        .backlogMap[backlogItemsToShow[i].categoryName]![
                            backlogItemsToShow[i].arrayIdx]
                        .scheduledDate = widget.date;
                    if (PlannerService
                        .sharedInstance.user!.scheduledBacklogItemsMap
                        .containsKey(widget.date)) {
                      PlannerService.sharedInstance.user!
                          .scheduledBacklogItemsMap[widget.date]!
                          .add(backlogItemsToShow[i]);
                    } else {
                      var arr = [backlogItemsToShow[i]];
                      PlannerService
                          .sharedInstance.user!.scheduledBacklogItemsMap
                          .addAll({widget.date: arr});
                    }
                    //update server to record that backlog item has been scheduled
                    //update task with event id and scheduled date (call schedule task server route)
                    var body = {
                      'taskId': PlannerService
                          .sharedInstance
                          .user!
                          .backlogMap[backlogItemsToShow[i].categoryName]![
                              backlogItemsToShow[i].arrayIdx]
                          .id,
                      'calendarRefId':
                          -1, //use negative 1 because it is not on calendar
                      'scheduledDate': widget.date.toString(),
                    };
                    String bodyF = jsonEncode(body);
                    //print(bodyF);

                    var url = Uri.parse(
                        PlannerService.sharedInstance.serverUrl +
                            '/backlog/schedule');
                    var response2 = await http.patch(url,
                        headers: {"Content-Type": "application/json"},
                        body: bodyF);
                    //print('Response status: ${response2.statusCode}');
                    //print('Response body: ${response2.body}');

                    if (response2.statusCode == 200) {
                      print("scheduling successful");
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
                }
                if (selectedItems.isNotEmpty) {
                  widget.updatePotentialCandidates();
                }

                Navigator.of(context).pop();
              },
              child: Text("Ok"))
        ],

        bottom: const PreferredSize(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "I plan to work on...",
                    style: TextStyle(color: Colors.white),
                    //textAlign: TextAlign.center,
                  )),
            ),
            preferredSize: Size.fromHeight(10.0)),

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
      body: PlannerService.sharedInstance.user!.backlogMap.values.isEmpty ||
              (PlannerService.sharedInstance.user!.backlogMap.keys.length ==
                      1 &&
                  PlannerService.sharedInstance.user!.backlogMap.entries.first
                          .value.length ==
                      0)
          ? Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "No backlog items.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ))
          : noUnscheduledBacklogItems
              ? Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "All of your backlog items are already scheduled. Create a new backlog item to schedule.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ))
              : Column(
                  children: [
                    // const Text("Which item do you want to schedule for tomorrow?"),
                    Expanded(
                      child: ListView(
                        children: buildBacklogListView(),
                      ),
                    )
                  ],
                ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _openNewBacklogItemPage,
      //   tooltip: 'Done.',
      //   child: const Icon(Icons.done),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
