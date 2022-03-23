import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/views/Goals/goals_page.dart';
import '/services/planner_service.dart';
import '../Profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _HomePageState extends State<HomePage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  //var todayTasks = PlannerService.sharedInstance.user.todayTasks;
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
          child: Text(
            "Habits",
            textAlign: TextAlign.center,
            style: TextStyle(
              //color: Theme.of(context).colorScheme.primary,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          margin: EdgeInsets.only(left: 10, right: 10),
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
            child: Text(
              PlannerService.sharedInstance.user.habits[i].description,
              textAlign: TextAlign.center,
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
    // List<Widget> goalsListView = buildGoalsListView();
    List<Widget> todayTasksView = buildTodayTaskListView();
    List<TableRow> habitTableRows = buildHabitsView();
    //List<TableRow> habitTableRows = [];
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
        title: Card(
          child: Container(
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
                Container(
                  child: Text(
                    "Today's a new day!",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              ],
            ),
            //padding: EdgeInsets.all(30),
            //margin: EdgeInsets.all(]15),
          ),
          margin: EdgeInsets.all(15),
          //color: Colors.pink.shade50,
        ),
      ),
      //body: Text('This is my default text'),
      body: Container(
        //child: Expanded(
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Today...",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: todayTasksView,
                    ),
                  ),
                ],
              ),
              margin: EdgeInsets.all(15),
            ),
            Container(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "This week...",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    child: Table(
                      // border: TableBorder.symmetric(),
                      border: const TableBorder(
                        verticalInside:
                            BorderSide(width: 1, style: BorderStyle.solid),
                        horizontalInside: BorderSide(width: 1),
                      ),
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                      },
                      children: habitTableRows,
                    ),
                    margin: EdgeInsets.only(top: 20),
                  ),
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
                  Container(
                    child: Table(
                      // border: TableBorder.symmetric(),
                      border: TableBorder(
                        verticalInside:
                            BorderSide(width: 1, style: BorderStyle.solid),
                        horizontalInside: BorderSide(width: 1),
                      ),
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                      },
                      children: habitTableRows,
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
}
