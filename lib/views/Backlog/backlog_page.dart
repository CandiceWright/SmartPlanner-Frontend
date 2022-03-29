import 'package:flutter/material.dart';
import 'package:practice_planner/views/Backlog/new_task_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

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

  List<Widget> buildBacklogListView() {
    //print("building backlog view");
    List<Widget> todayItems = [];
    List<Widget> tomorrowItems = [];

    //build unscheduled backlog
    List<Widget> backloglistview = [];
    PlannerService.sharedInstance.user.backlogMap.forEach((key, value) {
      List<Widget> unscheduledExpansionTileChildren = [];
      for (int i = 0; i < value.length; i++) {
        //if (value[i].scheduledDate == null) {
        Widget child = CheckboxListTile(
          title: Text(
            value[i].description,
            // style: const TextStyle(
            //     color: Colors.black, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(DateFormat.yMMMd().format(value[i].completeBy!)),
          value:
              PlannerService.sharedInstance.user.backlogMap[key]![i].isComplete,
          onChanged: (bool? value) {
            print(value);
            setState(() {
              PlannerService
                  .sharedInstance.user.backlogMap[key]![i].isComplete = value;
              //_value = value!;
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
        if (value[i].scheduledDate == null) {
          unscheduledExpansionTileChildren.add(child);
        }
        //}
        else {
          if (value[i].scheduledDate == DateTime.now()) {
            todayItems.add(child);
          } else {
            tomorrowItems.add(child);
          }
        }
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
    //return backloglistview;

    Widget todayExpansionTile = ExpansionTile(
      title: const Text("Working on Today"),
      //initiallyExpanded: true,
      children: todayItems,
    );

    Widget tomorrowExpansionTile = ExpansionTile(
      title: const Text("Working on Tomorrow"),
      //initiallyExpanded: true,
      children: tomorrowItems,
    );

    Widget unscheduledExpansionTile = ExpansionTile(
      title: const Text("Backlog"),
      initiallyExpanded: true,
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
        title: const Text("Life Backlog"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // SingleChildScrollView(
          //   child: Card(
          //       child: Container(
          //         child: Column(
          //           children: [
          //             CheckboxListTile(
          //               title: Text("Test task 1"),
          //               value: false,
          //               onChanged: (bool? value) {
          //                 print(value);
          //                 setState(() {
          //                   _value = value!;
          //                 });
          //               },
          //               secondary: IconButton(
          //                 icon: const Icon(Icons.visibility_outlined),
          //                 tooltip: 'View this backlog item',
          //                 onPressed: () {
          //                   setState(() {});
          //                 },
          //               ),
          //               controlAffinity: ListTileControlAffinity.leading,
          //             ),
          //             CheckboxListTile(
          //               title: Text("Test task 1"),
          //               value: false,
          //               onChanged: (bool? value) {
          //                 print(value);
          //                 setState(() {
          //                   _value = value!;
          //                 });
          //               },
          //               secondary: IconButton(
          //                 icon: const Icon(Icons.visibility_outlined),
          //                 tooltip: 'View this backlog item',
          //                 onPressed: () {
          //                   setState(() {});
          //                 },
          //               ),
          //               controlAffinity: ListTileControlAffinity.leading,
          //             ),
          //             CheckboxListTile(
          //               title: Text("Test task 1"),
          //               value: false,
          //               onChanged: (bool? value) {
          //                 print(value);
          //                 setState(() {
          //                   _value = value!;
          //                 });
          //               },
          //               secondary: IconButton(
          //                 icon: const Icon(Icons.visibility_outlined),
          //                 tooltip: 'View this backlog item',
          //                 onPressed: () {
          //                   setState(() {});
          //                 },
          //               ),
          //               controlAffinity: ListTileControlAffinity.leading,
          //             )
          //           ],
          //         ),
          //       ),
          //       color: Colors.pink.shade50,
          //       // margin: EdgeInsets.all(20),
          //       margin:
          //           EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
          //       elevation: 5,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10.0),
          //       )),
          // ),
          // const Divider(
          //   thickness: 0.5,
          //   indent: 20,
          //   endIndent: 0,
          //   color: Colors.grey,
          // ),
          Expanded(
            child: ListView(
              children: backlogListView,
            ),
          )
        ],
      ),
      // body: Column(
      //   children: [
      //     Card(
      //         child: Container(
      //           child: Column(
      //             children: [
      //               CheckboxListTile(
      //                 title: Text("Test task 1"),
      //                 value: false,
      //                 onChanged: (bool? value) {
      //                   print(value);
      //                   setState(() {
      //                     _value = value!;
      //                   });
      //                 },
      //                 secondary: IconButton(
      //                   icon: const Icon(Icons.visibility_outlined),
      //                   tooltip: 'View this backlog item',
      //                   onPressed: () {
      //                     setState(() {});
      //                   },
      //                 ),
      //                 controlAffinity: ListTileControlAffinity.leading,
      //               )
      //             ],
      //           ),
      //         ),
      //         color: Colors.pink.shade50,
      //         // margin: EdgeInsets.all(20),
      //         margin: EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
      //         elevation: 5,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(10.0),
      //         )),
      //     const Divider(
      //       thickness: 0.5,
      //       indent: 20,
      //       endIndent: 0,
      //       color: Colors.grey,
      //     ),
      //     Expanded(
      //       child: ListView(
      //         children: backlogListView,
      //       ),
      //     )
      //   ],
      // ),
      // margin: EdgeInsets.all(15),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewBacklogItemPage,
        tooltip: 'Create new task.',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
