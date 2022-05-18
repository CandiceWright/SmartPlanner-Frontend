import 'package:flutter/material.dart';
import '/models/goal.dart';
import 'new_goal_page.dart';
import 'edit_goal_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:confetti/confetti.dart';

class AccomplishedGoalsPage extends StatefulWidget {
  const AccomplishedGoalsPage({Key? key, required this.updateGoals})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Function updateGoals;

  @override
  State<AccomplishedGoalsPage> createState() => _AccomplishedGoalsPageState();
}

class _AccomplishedGoalsPageState extends State<AccomplishedGoalsPage> {
  @override
  void initState() {
    super.initState();
  }

  void moveGoal(int idx) {
    PlannerService.sharedInstance.user!.goals
        .add(PlannerService.sharedInstance.user!.accomplishedGoals[idx]);
    //sort goals list again
    PlannerService.sharedInstance.user!.goals.sort((goal1, goal2) {
      DateTime goal1Date = goal1.start;
      DateTime goal2Date = goal2.start;
      return goal1Date.compareTo(goal2Date);
    });
    //delete from accomplishedGoals
    PlannerService.sharedInstance.user!.accomplishedGoals.removeAt(idx);
    _updateGoalsList();
    widget.updateGoals();
    Navigator.pop(context);
  }

  void _showGoalContent(Goal goal, int idx) {
    showDialog(
      context: context, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          //insetPadding: EdgeInsets.symmetric(vertical: 200, horizontal: 100),
          //child: Expanded(
          //child: Container(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Card(
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.yMMMd().format(goal.date),
                    // style: Theme.of(context).textTheme.subtitle2,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    child: Text(
                      goal.description,
                      style: TextStyle(fontSize: 15),
                    ),
                    padding: EdgeInsets.only(bottom: 10, top: 4),
                  ),
                  Padding(
                    child: Image.asset(
                      "assets/images/goal_icon.png",
                      height: 60,
                      width: 60,
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  moveGoal(idx);
                },
                child: new Text('Move back to goals')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text('close'))
          ],
          // ),
          //),
        );
      },
    );
  }

  void _updateGoalsList() {
    print("I am in update goals");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //List<Widget> goalsListView = buildGoalsListView();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Accomplished"),
        centerTitle: true,
        actions: [],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),
      body: Container(
        child: ListView(
          children: List.generate(
              PlannerService.sharedInstance.user!.accomplishedGoals.length,
              (int index) {
            return GestureDetector(
              onTap: () => {
                _showGoalContent(
                    PlannerService
                        .sharedInstance.user!.accomplishedGoals[index],
                    index)
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/goal_icon.png",
                      height: 40,
                      width: 40,
                    ),
                    Column(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Text(
                                DateFormat.yMMMd().format(PlannerService
                                    .sharedInstance
                                    .user!
                                    .accomplishedGoals[index]
                                    .date),
                                // style: Theme.of(context).textTheme.subtitle2,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                PlannerService.sharedInstance.user!
                                    .accomplishedGoals[index].description,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.all(15),
                        ),
                      ],
                    ),
                  ],
                ),
                elevation: 3,
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                //color: Theme.of(context).colorScheme.primary,
                color: PlannerService.sharedInstance.user!
                    .accomplishedGoals[index].category.color,
              ),
            );
          }),
        ),
        margin: EdgeInsets.all(15),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
