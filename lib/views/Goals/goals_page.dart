import 'package:flutter/material.dart';
import '/models/goal.dart';
import 'new_goal_page.dart';
import 'edit_goal_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
//import 'package:confetti/confetti.dart';

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
  //ConfettiController _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
    print(PlannerService.sharedInstance.user.goals);
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

  void showGoalCompleteAnimation() {
    print("Yayy you did it");
  }

  void _showGoalContent(Goal goal, int idx) {
    showDialog(
      context: context, // user must tap button!

      builder: (BuildContext context) {
        return SimpleDialog(
          //insetPadding: EdgeInsets.symmetric(vertical: 200, horizontal: 100),
          //child: Expanded(
          //child: Container(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          children: [
            Container(
              child: Column(
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
                      onPressed: showGoalCompleteAnimation,
                      child: const Text(
                        "I DID IT!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ],
              ),
              margin: EdgeInsets.all(10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => {_openEditGoal(idx)},
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          PlannerService
                              .sharedInstance.user.goals[i].description,
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
          color: Theme.of(context).colorScheme.primary,
        ),
      );
      goalsListView.add(goalContainerWidget);
    }
    /*This implementation uses containers*/
    // for (int i = 0; i < userGoals.length; i++) {
    //   Widget goalContainerWidget = Container(
    //     child: Column(
    //       children: [
    //         Text(
    //           userGoals[i].date.toString(),
    //           style: Theme.of(context).textTheme.subtitle2,
    //         ),
    //         Text(
    //           userGoals[i].description,
    //         ),
    //       ],
    //     ),
    //     margin: EdgeInsets.all(30),
    //     padding: EdgeInsets.all(15),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(20),
    //       color: Theme.of(context).colorScheme.primary,
    //     ),
    //   );
    //   goalsListView.add(goalContainerWidget);
    // }
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
    List<Widget> goalsListView = buildGoalsListView();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Goals"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView(
          children: goalsListView,
        ),
        margin: EdgeInsets.all(15),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewGoalPage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }