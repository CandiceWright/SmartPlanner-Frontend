import 'package:flutter/material.dart';
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
  bool _value = false;
  var backlog = PlannerService.sharedInstance.user.backlog;

  @override
  void initState() {
    super.initState();
    print(PlannerService.sharedInstance.user.backlog);
  }

  void _openNewBacklogItemPage() {
    //this function needs to change to create new goal
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (context) => NewGoalPage(updateGoals: _updateGoalsList)));
  }

  void _updateBacklogList() {
    print("I am in update goals");
    setState(() {});
  }

  List<Widget> buildBacklogListView() {
    print("building backlog view");
    List<Widget> backloglistview = [];
    backlog.forEach((key, value) {
      List<Widget> expansionTileChildren = [];
      for (int i = 0; i < value.length; i++) {
        Widget child = CheckboxListTile(
          title: Text(value[i].description),
          subtitle: Text(DateFormat.yMMMd().format(value[i].completeBy)),
          value: value[i].isComplete,
          onChanged: (bool? value) {
            print(value);
            setState(() {
              _value = value!;
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
        expansionTileChildren.add(child);
      }
      Widget expansionTile = ExpansionTile(
        title: Text(key),
        children: expansionTileChildren,
        trailing:
            Text(value.length.toString(), style: TextStyle(color: Colors.pink)),
      );
      backloglistview.add(expansionTile);
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
    List<Widget> backlogListView = buildBacklogListView();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Life Backlog"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView(
          children: backlogListView,
        ),
        margin: EdgeInsets.all(15),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewBacklogItemPage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
