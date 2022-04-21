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
      {Key? key, required this.updateTomorrowEvents, required this.fromPage})
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

  @override
  State<ScheduleBacklogItemsPage> createState() =>
      _ScheduleBacklogItemsPageState();
}

class _ScheduleBacklogItemsPageState extends State<ScheduleBacklogItemsPage> {
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

  void setTime(BacklogItem backlogItem, BacklogMapRef bmRef) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: "SetTime"),
        builder: (context) => SetBacklogItemTimePage(
            backlogItem: backlogItem,
            updateEvents: widget.updateTomorrowEvents,
            bmRef: bmRef,
            fromPage: widget.fromPage),
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
    //print("building backlog view");
    List<Widget> todayItems = [];
    List<Widget> tomorrowItems = [];

    //build unscheduled backlog
    List<Widget> backloglistview = [];
    PlannerService.sharedInstance.user.backlogMap.forEach((key, value) {
      List<Widget> unscheduledExpansionTileChildren = [];
      for (int i = 0; i < value.length; i++) {
        if (value[i].scheduledDate == null && !value[i].isComplete!) {
          Widget child = CheckboxListTile(
            title: Text(
              value[i].description,
              // style: const TextStyle(
              //     color: Colors.black, fontWeight: FontWeight.bold),
            ),
            value: PlannerService
                .sharedInstance.user.backlogMap[key]![i].isComplete,
            onChanged: (bool? checked) {
              //print(value);
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
        // else {
        //   if (value[i].scheduledDate == DateTime.now()) {
        //     todayItems.add(child);
        //   } else {
        //     tomorrowItems.add(child);
        //   }
        // }
      }
      Widget expansionTile = ExpansionTile(
        title: Text(key),
        initiallyExpanded: true,
        children: unscheduledExpansionTileChildren,
        leading: Icon(
          Icons.circle,
          color: PlannerService.sharedInstance.user.LifeCategoriesColorMap[key],
        ),
        trailing: Text(unscheduledExpansionTileChildren.length.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      );
      backloglistview.add(expansionTile); //1 per category
    });
    return backloglistview;

    // Widget todayExpansionTile = ExpansionTile(
    //   title: const Text("Working on Today"),
    //   //initiallyExpanded: true,
    //   children: todayItems,
    // );

    // Widget tomorrowExpansionTile = ExpansionTile(
    //   title: const Text("Working on Tomorrow"),
    //   //initiallyExpanded: true,
    //   children: tomorrowItems,
    // );

    // Widget unscheduledExpansionTile = ExpansionTile(
    //   title: const Text("Backlog"),
    //   initiallyExpanded: true,
    //   children: backloglistview,
    //   // trailing: Text(value.length.toString(),style: TextStyle(color: Theme.of(context).colorScheme.primary)),
    // );

    // List<Widget> expansionTiles = [
    //   todayExpansionTile,
    //   tomorrowExpansionTile,
    //   unscheduledExpansionTile
    // ];

    // return expansionTiles;
  }

  // List<Widget> buildBacklogListView() {
  //   print("building backlog view");
  //   List<Widget> backloglistview = [];
  //   PlannerService.sharedInstance.user.backlogMap.forEach((key, value) {
  //     List<Widget> expansionTileChildren = [];
  //     for (int i = 0; i < value.length; i++) {
  //       Widget child = CheckboxListTile(
  //         title: Text(value[i].description),
  //         value:
  //             PlannerService.sharedInstance.user.backlogMap[key]![i].isComplete,
  //         onChanged: (bool? checked) {
  //           //print(value);
  //           BacklogMapRef bmRef = BacklogMapRef(categoryName: key, arrayIdx: i);
  //           setTime(value[i], bmRef);
  //           // setState(() {
  //           //   PlannerService.sharedInstance.user.backlog[key][i].isComplete =
  //           //       value;
  //           //   //_value = value!;
  //           // });
  //         },
  //         controlAffinity: ListTileControlAffinity.leading,
  //       );
  //       expansionTileChildren.add(child);
  //     }
  //     Widget expansionTile = ExpansionTile(
  //       title: Text(key),
  //       children: expansionTileChildren,
  //       trailing: Text(value.length.toString(),
  //           style: TextStyle(color: Theme.of(context).colorScheme.primary)),
  //     );
  //     backloglistview.add(expansionTile);
  //   });

  //   return backloglistview;
  // }

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
        // ignore: prefer_const_constructors
        title: const Text(
          "Select Backlog item",
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Which item do you want to schedule?",
                  style: TextStyle(color: Colors.white),
                  //textAlign: TextAlign.center,
                ),
              ),
            ),
            preferredSize: Size.fromHeight(10.0)),

        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/images/login_screens_background.png",
                  ),
                  fit: BoxFit.fill)),
        ),

        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),
      body: Column(
        children: [
          // const Text("Which item do you want to schedule for tomorrow?"),
          Expanded(
            child: ListView(
              children: backlogListView,
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
