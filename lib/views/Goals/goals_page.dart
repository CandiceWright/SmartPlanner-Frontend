import 'package:flutter/material.dart';
import 'package:practice_planner/views/Goals/accomplished_goals_page.dart';
import '/models/goal.dart';
import 'new_goal_page.dart';
import 'edit_goal_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:confetti/confetti.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late ConfettiController _controllerCenter;
  //ConfettiController _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 4));
    //print(PlannerService.sharedInstance.user.goals);
  }

  void _openNewGoalPage() {
    //this function needs to change to create new goal
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewGoalPage(updateGoals: _updateGoalsList)));
  }

  void _openEditGoal(int idx) {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditGoalPage(
                  updateGoal: _updateGoalsList,
                  goalIdx: idx,
                )));
  }

  void showGoalCompleteAnimation(int idx) {
    PlannerService.sharedInstance.user.accomplishedGoals.add(
        PlannerService.sharedInstance.user.goals[idx]); //move to accomplished
    PlannerService.sharedInstance.user.goals.removeAt(idx);
    _updateGoalsList();
    Navigator.pop(context);
    _controllerCenter.play();
    print("Yayy you did it");
  }

  void deleteGoal(int idx) {
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
                onPressed: () {
                  PlannerService.sharedInstance.user.goals.removeAt(idx);
                  setState(() {});
                  Navigator.pop(context);
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

                  // Text(
                  //   goal.notes,
                  //   // style: Theme.of(context).textTheme.subtitle2,
                  //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  // ),
                  ElevatedButton(
                      onPressed: () {
                        showGoalCompleteAnimation(idx);
                      },
                      child: const Text(
                        "I DID IT!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  _openEditGoal(idx);
                },
                child: new Text('edit')),
            TextButton(
                onPressed: () {
                  deleteGoal(idx);
                },
                child: new Text('delete')),
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

  void goToAccomplishedGoals() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                AccomplishedGoalsPage(updateGoals: _updateGoalsList)));
  }

  List<Widget> buildGoalsListView() {
    print("building goals list view");
    List<Widget> goalsListView = [];
    /*This implementation uses cards*/
    for (int i = 0; i < PlannerService.sharedInstance.user.goals.length; i++) {
      Widget goalContainerWidget = GestureDetector(
        onTap: () =>
            {_showGoalContent(PlannerService.sharedInstance.user.goals[i], i)},
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
                          DateFormat.yMMMd().format(
                              PlannerService.sharedInstance.user.goals[i].date),
                          // style: Theme.of(context).textTheme.subtitle2,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Text(
                          PlannerService
                              .sharedInstance.user.goals[i].description,
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
          color: PlannerService.sharedInstance.user.goals[i].category.color,
        ),
      );
      goalsListView.add(goalContainerWidget);
    }
    return goalsListView;
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
        title: const Text("Goals"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              goToAccomplishedGoals();
            },
            icon: Icon(Icons.done_all),
            color: Colors.pink,
          )
          // GestureDetector(
          //   onTap: () {},
          //   child: Image.asset(
          //     "assets/images/goal_icon.png",
          //     // height: 40,
          //     // width: 40,
          //   ),
          // )
        ],
      ),
      body: Stack(
        children: [
          Align(
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
            alignment: Alignment.center,
          ),
          Container(
            child: ListView(
              //children: goalsListView,
              children: List.generate(
                  PlannerService.sharedInstance.user.goals.length, (int index) {
                return GestureDetector(
                  onTap: () => {
                    _showGoalContent(
                        PlannerService.sharedInstance.user.goals[index], index)
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
                                        .sharedInstance.user.goals[index].date),
                                    // style: Theme.of(context).textTheme.subtitle2,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    PlannerService.sharedInstance.user
                                        .goals[index].description,
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
                    color: PlannerService
                        .sharedInstance.user.goals[index].category.color,
                  ),
                );
              }),
            ),
            margin: EdgeInsets.all(15),
          ),
        ],
      ),
      // body: Container(
      //   child: ListView(
      //     children: goalsListView,
      //   ),
      //   margin: EdgeInsets.all(15),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewGoalPage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
