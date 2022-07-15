import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/definition.dart';
import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/models/life_category.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:http/http.dart' as http;

class NewDefinitionPage extends StatefulWidget {
  const NewDefinitionPage({Key? key, required this.updateDictionary})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateDictionary;

  @override
  State<NewDefinitionPage> createState() => _NewDefinitionPageState();
}

class _NewDefinitionPageState extends State<NewDefinitionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var descriptionTxtController = TextEditingController();
  var defintionTxtController = TextEditingController();
  bool doneBtnDisabled = true;
  var currChosenCategory =
      PlannerService.sharedInstance.user!.lifeCategories[0];

  @override
  void initState() {
    super.initState();
    defintionTxtController.addListener(setDoneBtnState);
    descriptionTxtController.addListener(setDoneBtnState);
  }

  Future<void> createDefinition() async {
    var name = descriptionTxtController.text;
    var definition = defintionTxtController.text;
    //first make a call to the server
    var body = {
      'userId': PlannerService.sharedInstance.user!.id,
      'name': name,
      'def': definition,
    };
    String bodyF = jsonEncode(body);
    print(bodyF);

    var url = Uri.parse('http://192.168.1.4:7343/dictionary');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      print(decodedBody);
      var id = decodedBody["insertId"];
      var newDefinition = Definition(id, name, definition);
      PlannerService.sharedInstance.user!.dictionaryArr.add(newDefinition);
      PlannerService.sharedInstance.user!.dictionaryMap[newDefinition.name] =
          newDefinition;
      PlannerService.sharedInstance.user!.dictionaryArr.sort((def1, def2) {
        String name1 = def1.name;
        String name2 = def2.name;
        return name1.compareTo(name2);
      });
      widget.updateDictionary();
      _backToDefinitionsPage();
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

  void setDoneBtnState() {
    print(defintionTxtController.text);
    print(descriptionTxtController.text);
    if (defintionTxtController.text != "" &&
        descriptionTxtController.text != "") {
      setState(() {
        print("button enabled");
        doneBtnDisabled = false;
      });
    } else {
      setState(() {
        doneBtnDisabled = true;
      });
    }
  }

  void _backToDefinitionsPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
              "New Definition",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,

            centerTitle: true,
            //leading: BackButton(color: Colors.black),
            actions: [
              TextButton(
                onPressed: doneBtnDisabled ? null : createDefinition,
                child: const Text(
                  "Done",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // IconButton(
              //   icon: const Icon(Icons.check),
              //   color: Colors.pink,
              //   tooltip: 'Open shopping cart',
              //   onPressed: () {
              //     // handle the press
              //   },
              // ),
            ],
          ),
          body: Card(
            child: Container(
              child: ListView(
                children: [
                  // Image.asset(
                  //   "assets/images/goal_icon.png",
                  //   height: 80,
                  //   width: 80,
                  // ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: TextFormField(
                            controller: descriptionTxtController,
                            decoration: const InputDecoration(
                              hintText: "What are you defining?",
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                          padding: EdgeInsets.all(20),
                        ),
                        Container(
                          child: TextFormField(
                            controller: defintionTxtController,
                            decoration: const InputDecoration(
                              hintText: "How do you define this in your world?",
                              fillColor: Colors.white,
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            maxLines: null,
                            minLines: 10,
                          ),
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              margin: EdgeInsets.all(15),
            ),
            //color: Colors.pink.shade50,
            // margin: EdgeInsets.all(20),
            margin: EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        )
      ],
    );
  }
}
