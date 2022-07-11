import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_planner/models/definition.dart';
import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/views/Dictionary/edit_definition_page.dart';
import 'package:practice_planner/views/Dictionary/new_definition_page.dart';
import 'package:practice_planner/views/Goals/accomplished_goals_page.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  late ConfettiController _controllerCenter;
  //ConfettiController _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
  }

  void _openNewDefinitionPage() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                NewDefinitionPage(updateDictionary: _updateDictionary)));
  }

  void _openEditDefinitionPage(int idx, Definition definition) {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditDefinitionPage(
                updateDictionary: _updateDictionary,
                idx: idx,
                definition: definition)));
  }

  void deleteDefinition(int idx) {
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
                  var defId =
                      PlannerService.sharedInstance.user!.dictionaryArr[idx].id;
                  var url = Uri.parse(
                      'http://192.168.1.4:7343/dictionary/' + defId.toString());
                  var response = await http.delete(
                    url,
                  );
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    PlannerService.sharedInstance.user!.dictionaryArr
                        .removeAt(idx);
                    setState(() {});
                    Navigator.pop(context);
                  } else {
                    //500 error, show an alert

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

  void _showDefinitionContent(Definition def, int idx) {
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
                  Padding(
                    child: Text(
                      def.name,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.only(bottom: 10, top: 4),
                  ),
                  Padding(
                    child: Text(
                      def.definition,
                      style: TextStyle(fontSize: 15),
                    ),
                    padding: EdgeInsets.only(bottom: 10, top: 4),
                  ),

                  // ElevatedButton(
                  //     onPressed: () {
                  //       showGoalCompleteAnimation(idx);
                  //     },
                  //     child: const Text(
                  //       "I DID IT!",
                  //       style: TextStyle(fontWeight: FontWeight.bold),
                  //     ))
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => _openEditDefinitionPage(idx, def),
                child: new Text('edit')),
            TextButton(
                onPressed: () {
                  deleteDefinition(idx);
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

  void _updateDictionary() {
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

    return Stack(
      children: [
        Image.asset(
          "assets/images/login_screens_background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Dictionary",
                //   style: GoogleFonts.roboto(
                //     textStyle: const TextStyle(
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
                style: TextStyle(color: Colors.white)),
            centerTitle: true,
            bottom: PreferredSize(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Define your World",
                      style: TextStyle(color: Colors.white),
                      //textAlign: TextAlign.center,
                    ),
                  ),
                ),
                preferredSize: Size.fromHeight(10.0)),
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Container(
                child: ListView(
                  //children: goalsListView,
                  children: List.generate(
                      PlannerService.sharedInstance.user!.dictionaryArr.length,
                      (int index) {
                    return GestureDetector(
                      onTap: () => {
                        _showDefinitionContent(
                            PlannerService
                                .sharedInstance.user!.dictionaryArr[index],
                            index)
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
                                  Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          PlannerService.sharedInstance.user!
                                              .dictionaryArr[index].name,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
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
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        color: Theme.of(context).colorScheme.primary,
                        // color: PlannerService
                        //     .sharedInstance.user!.goals[index].category.color,
                      ),
                    );
                  }),
                ),
                margin: EdgeInsets.all(15),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: _openNewDefinitionPage,
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
