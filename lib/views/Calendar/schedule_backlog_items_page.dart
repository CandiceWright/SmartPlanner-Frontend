import 'package:flutter/material.dart';
import 'package:practice_planner/models/backlog_item.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/views/Backlog/new_task_page.dart';
import 'package:practice_planner/views/Calendar/set_backlog_item_time_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class ScheduleBacklogItemsPage extends StatefulWidget {
  const ScheduleBacklogItemsPage(
      {Key? key,
      required this.updateTomorrowEvents,
      required this.fromPage,
      required this.calendarDate})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Function updateTomorrowEvents;
  final String fromPage;
  final DateTime calendarDate;

  @override
  State<ScheduleBacklogItemsPage> createState() =>
      _ScheduleBacklogItemsPageState();
}

class _ScheduleBacklogItemsPageState extends State<ScheduleBacklogItemsPage> {
  bool noUnscheduledBacklogItems = false;

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
        // print(value[i].description);
        // print(value[i].scheduledDate);
        // print(value[i].calendarItemRef! != null
        //     ? value[i].calendarItemRef!.id
        //     : "calendarRef null");
        if ((value[i].scheduledDate == null)) {
          if (value[i].status != "complete") {
            counter++;
          }
        } else if (value[i].calendarItemRef == null &&
            DateTime(
                    value[i].scheduledDate!.year,
                    value[i].scheduledDate!.month,
                    value[i].scheduledDate!.day) ==
                widget.calendarDate) {
          //this is one of the refs where id = -1
          //a backlog item that's not on the calendar
          if (value[i].status != "complete") {
            counter++;
          }
        }
      } //1 per category
    });
    if (counter == 0) {
      noUnscheduledBacklogItems = true;
    }
  }

  // void _openNewBacklogItemPage() {
  //   //this function needs to change to create new goal
  //   Navigator.push(
  //       context,
  //       CupertinoPageRoute(
  //           builder: (context) =>
  //               NewTaskPage(updateBacklog: _updateBacklogList)));
  // }

  // void _updateBacklogList() {
  //   //print("I am in update backlog");
  //   setState(() {});
  // }

  void setTime(BacklogItem backlogItem, BacklogMapRef bmRef) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: "SetTime"),
        builder: (context) => SetBacklogItemTimePage(
          backlogItem: backlogItem,
          updateEvents: widget.updateTomorrowEvents,
          bmRef: bmRef,
          fromPage: widget.fromPage,
          calendarDate: widget.calendarDate,
        ),
      ),
    );
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (context) => SetBacklogItemTimePage(
    //               backlogItem: backlogItem,
    //             )));
  }

  List<Widget> buildBacklogListView() {
    //build unscheduled backlog
    List<Widget> backloglistview = [];
    PlannerService.sharedInstance.user!.backlogMap.forEach((key, value) {
      List<Widget> unscheduledExpansionTileChildren = [];

      for (int i = 0; i < value.length; i++) {
        //if (value[i].scheduledDate == null && !value[i].isComplete!) {
        // print(value[i].description);
        // print(value[i].scheduledDate);
        // print(value[i].calendarItemRef! != null
        //     ? value[i].calendarItemRef!.id
        //     : "calendarRef null");
        if ((value[i].scheduledDate == null)) {
          //a backlog item that hasn't been assigned to a day. In this case, it will need to be added too selected datee task list too
          if (value[i].status != "complete") {
            Widget child = CheckboxListTile(
              title: Text(
                value[i].description,
                // style: const TextStyle(
                //     color: Colors.black, fontWeight: FontWeight.bold),
              ),
              value: PlannerService
                  .sharedInstance.user!.backlogMap[key]![i].isComplete,
              onChanged: (bool? checked) {
                ////print(value);
                BacklogMapRef bmRef =
                    BacklogMapRef(categoryName: key, arrayIdx: i);
                setTime(value[i], bmRef);
                // setState(() {
                //   PlannerService.sharedInstance.user.backlog[key][i].isComplete =
                //       value;
                //   //_value = value!;
                // });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
            //if (value[i].scheduledDate == null) {
            unscheduledExpansionTileChildren.add(child);
            //}
          }
        } else if (value[i].calendarItemRef == null &&
            DateTime(
                    value[i].scheduledDate!.year,
                    value[i].scheduledDate!.month,
                    value[i].scheduledDate!.day) ==
                widget.calendarDate) {
          //a backlog item that's not on the calendar
          if (value[i].status != "complete") {
            Widget child = CheckboxListTile(
              title: Text(
                value[i].description,
                // style: const TextStyle(
                //     color: Colors.black, fontWeight: FontWeight.bold),
              ),
              value: PlannerService
                  .sharedInstance.user!.backlogMap[key]![i].isComplete,
              onChanged: (bool? checked) {
                ////print(value);
                BacklogMapRef bmRef =
                    BacklogMapRef(categoryName: key, arrayIdx: i);
                setTime(value[i], bmRef);
                // setState(() {
                //   PlannerService.sharedInstance.user.backlog[key][i].isComplete =
                //       value;
                //   //_value = value!;
                // });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
            //if (value[i].scheduledDate == null) {
            unscheduledExpansionTileChildren.add(child);
            //}
          }
        }

        // if ((value[i].scheduledDate == null ||
        //         value[i].calendarItemRef!.id == -1) &&
        //     value[i].status != "complete") {

        // }
      }
      Widget expansionTile = ExpansionTile(
        title: Text(key),
        initiallyExpanded: true,
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
    return backloglistview;
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
          "Select Backlog item",
          style: TextStyle(color: Colors.white),
        ),
        bottom: const PreferredSize(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Items that aren't yet scheduled shown below",
                    style: TextStyle(color: Colors.white)),
                // child: widget.fromPage == "today"
                //     ? const Text(
                //         "Add item to today's schedule.",
                //         style: TextStyle(color: Colors.white),
                //         //textAlign: TextAlign.center,
                //       )
                //     : Text(
                //         "Add item to " + widget.fromPage + " schedule",
                //         style: TextStyle(color: Colors.white),
                //         //textAlign: TextAlign.center,
                //       ),
              ),
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
