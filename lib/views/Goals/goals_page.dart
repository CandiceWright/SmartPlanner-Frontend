import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/views/Goals/accomplished_goals_page.dart';
import '/models/goal.dart';
import 'new_goal_page.dart';
import 'edit_goal_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;

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
    ////print(PlannerService.sharedInstance.user.goals);
  }

  void _openNewGoalPage() {
    //this function needs to change to create new goal
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => NewGoalPage(updateGoals: _updateGoalsList)));
  }

  void _openEditGoal(int idx, int eventId) {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditGoalPage(
                  updateGoal: _updateGoalsList,
                  goalIdx: idx,
                  eventId: eventId,
                )));
  }

  void showGoalCompleteAnimation(int idx, int eventId) async {
    //first update on server
    var body = {'goalId': eventId, 'isAccomplished': true};
    String bodyF = jsonEncode(body);
    //print(bodyF);

    var url =
        Uri.parse(PlannerService.sharedInstance.serverUrl + '/goals/status');
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      PlannerService.sharedInstance.user!.accomplishedGoals.add(PlannerService
          .sharedInstance.user!.goals[idx]); //move to accomplished
      PlannerService.sharedInstance.user!.goals.removeAt(idx);
      //update event isAccomplished value in db

      _updateGoalsList();
      Navigator.pop(context);
      _controllerCenter.play();
      //print("Yayy you did it");
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

  void deleteGoal(int idx, int eventId) {
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
                  //first send server request
                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/goals/' +
                      eventId.toString());
                  var response = await http.delete(
                    url,
                  );
                  //print('Response status: ${response.statusCode}');
                  //print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    PlannerService.sharedInstance.user!.goals.removeAt(idx);
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

  void _showGoalContent(Event goal, int arrIdx, int eventId) {
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
            elevation: 1,
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.yMMMd().format(goal.start),
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
                  // Padding(
                  //   child: Image.asset(
                  //     "assets/images/goal_icon.png",
                  //     height: 60,
                  //     width: 60,
                  //   ),
                  //   padding: EdgeInsets.all(10),
                  // ),

                  // Text(
                  //   goal.notes,
                  //   // style: Theme.of(context).textTheme.subtitle2,
                  //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  // ),
                  ElevatedButton(
                      onPressed: () {
                        showGoalCompleteAnimation(arrIdx, eventId);
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
                  _openEditGoal(arrIdx, eventId);
                },
                child: new Text('edit')),
            TextButton(
                onPressed: () {
                  deleteGoal(arrIdx, eventId);
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
    //print("I am in update goals");
    setState(() {});
  }

  void goToAccomplishedGoals() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                AccomplishedGoalsPage(updateGoals: _updateGoalsList)));
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

    return Stack(
      children: [
        Image.asset(
          PlannerService.sharedInstance.user!.spaceImage,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: const Text(
              "Goals",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            bottom: const PreferredSize(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "I plan to accomplish X by Y",
                      style: TextStyle(color: Colors.white),
                      //textAlign: TextAlign.center,
                    ),
                  ),
                ),
                preferredSize: Size.fromHeight(10.0)),
            actions: [
              IconButton(
                onPressed: () {
                  goToAccomplishedGoals();
                },
                icon: Icon(Icons.done),
                //color: Colors.pink,
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
                      PlannerService.sharedInstance.user!.goals.length,
                      (int index) {
                    return GestureDetector(
                      onTap: () => {
                        _showGoalContent(
                            PlannerService.sharedInstance.user!.goals[index],
                            index,
                            PlannerService
                                .sharedInstance.user!.goals[index].id!)
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child:
                            //Row(
                            //children: [
                            Column(
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 5, left: 8, right: 8),
                                    child: Text(
                                      DateFormat.yMMMd().format(PlannerService
                                          .sharedInstance
                                          .user!
                                          .goals[index]
                                          .start),
                                      // style: Theme.of(context).textTheme.subtitle2,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.alarm,
                                          color: PlannerService.sharedInstance
                                                      .user!.goals[index].start
                                                      .difference(
                                                          DateTime.now())
                                                      .inDays <
                                                  0
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            PlannerService.sharedInstance.user!
                                                    .goals[index].start
                                                    .difference(DateTime.now())
                                                    .inDays
                                                    .toString() +
                                                " days remaining",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.alarm,
                                          color: PlannerService.sharedInstance
                                                      .user!.goals[index].start
                                                      .difference(
                                                          DateTime.now())
                                                      .inDays <
                                                  0
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ]),
                                  CircleAvatar(
                                    // // backgroundImage: AssetImage(
                                    //     PlannerService.sharedInstance.user!.profileImage),
                                    backgroundImage: PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .goals[index]
                                                    .imageUrl !=
                                                "" ||
                                            PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .goals[index]
                                                    .localImgPath !=
                                                ""
                                        ? (!File(PlannerService.sharedInstance.user!.goals[index].localImgPath!)
                                                .existsSync()
                                            ? NetworkImage(PlannerService
                                                .sharedInstance
                                                .user!
                                                .goals[index]
                                                .imageUrl!)
                                            : FileImage(File(PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .goals[index]
                                                    .localImgPath!))
                                                as ImageProvider)
                                        : null,
                                    radius: PlannerService.sharedInstance.user!
                                                    .goals[index].imageUrl! !=
                                                "" ||
                                            PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .goals[index]
                                                    .localImgPath !=
                                                ""
                                        ? 50
                                        : 0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      PlannerService.sharedInstance.user!
                                          .goals[index].description,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                              margin: EdgeInsets.all(15),
                            ),
                            // Image.asset(
                            //   "assets/images/goal_icon.png",
                            //   height: 40,
                            //   width: 40,
                            // ),
                          ],
                        ),
                        elevation: 3,
                        margin: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                            //color: Color(0xffd1849e),
                            color: PlannerService.sharedInstance.user!
                                .goals[index].category!.color,
                            width: 5.0,
                          ),
                        ),
                        // color: PlannerService
                        //     .sharedInstance.user!.goals[index].category!.color,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
                margin: EdgeInsets.all(15),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openNewGoalPage,
            tooltip: 'Increment',
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ), // This trailing comma makes auto-formatting nicer for build methods.
        )
      ],
    );
  }
}
