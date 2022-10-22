import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/models/life_category.dart';
import '/models/backlog_item.dart';
import '/services/planner_service.dart';
import 'package:http/http.dart' as http;

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({Key? key, required this.updateBacklog, this.selectdDate})
      : super(key: key);
  //const NewTaskPage({Key? key}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Function updateBacklog;
  final DateTime? selectdDate;

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // DateTime selectedDate = DateTime.now();
  DateTime? selectedDate;

  var dateTxtController = TextEditingController();
  var descriptionTxtController = TextEditingController();
  //var categoryTxtController = TextEditingController();
  var locationTxtController = TextEditingController();
  var notesTxtController = TextEditingController();
  bool doneBtnDisabled = true;
  var currChosenCategory =
      PlannerService.sharedInstance.user!.lifeCategories[0];
  String chosenStatus = "notStarted";

  @override
  void initState() {
    super.initState();
    //dateTxtController.addListener(setDoneBtnState);
    descriptionTxtController.addListener(setDoneBtnState);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate == null ? DateTime.now() : selectedDate!,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateTxtController.text = DateFormat.yMMMd().format(selectedDate!);
        ////print(DateFormat.yMMMd().format(selectedDate));
        setDoneBtnState();
        print(selectedDate);
      });
  }

  void createBacklogItem() async {
    HapticFeedback.lightImpact();
    var taskTitle = descriptionTxtController.text;
    //Make calls to server
    var body = {
      'userId': PlannerService.sharedInstance.user!.id,
      'description': taskTitle,
      'completeBy': selectedDate == null ? "none" : selectedDate.toString(),
      'category': currChosenCategory.id,
      'isComplete': false,
      'location': locationTxtController.text,
      'notes': notesTxtController.text,
      'status': chosenStatus
    };
    String bodyF = jsonEncode(body);
    //print(bodyF);

    var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/backlog');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      //print(decodedBody);
      var id = decodedBody["insertId"];
      var newBacklogItem = BacklogItem(
          id: id,
          description: taskTitle,
          completeBy: selectedDate,
          isComplete: false,
          category: currChosenCategory,
          //categoryTxtController.text,
          location: locationTxtController.text,
          notes: notesTxtController.text,
          status: chosenStatus);

      if (PlannerService.sharedInstance.user!.backlogMap
          .containsKey(currChosenCategory.name)) {
        PlannerService.sharedInstance.user!.backlogMap[currChosenCategory.name]!
            .add(newBacklogItem);
      } else {
        var arr = [newBacklogItem];
        PlannerService.sharedInstance.user!.backlogMap
            .addAll({newBacklogItem.category.name: arr});
      }

      if (widget.selectdDate != null) {
        //I want to make sure this backlog item is also scheduled for this date so
        //set scheduled date to widget.date
        PlannerService
            .sharedInstance
            .user!
            .backlogMap[currChosenCategory.name]![PlannerService.sharedInstance
                    .user!.backlogMap[currChosenCategory.name]!.length -
                1]
            .scheduledDate = widget.selectdDate;
        BacklogMapRef bmr = BacklogMapRef(
            categoryName: currChosenCategory.name,
            arrayIdx: PlannerService.sharedInstance.user!
                    .backlogMap[currChosenCategory.name]!.length -
                1);
        if (PlannerService.sharedInstance.user!.scheduledBacklogItemsMap
            .containsKey(widget.selectdDate)) {
          PlannerService.sharedInstance.user!
              .scheduledBacklogItemsMap[widget.selectdDate]!
              .add(bmr);
        } else {
          var arr = [bmr];
          PlannerService.sharedInstance.user!.scheduledBacklogItemsMap
              .addAll({widget.selectdDate!: arr});
        }
        //update server to record that backlog item has been scheduled
        //update task with event id and scheduled date (call schedule task server route)
        var body = {
          'taskId': PlannerService.sharedInstance.user!
              .backlogMap[bmr.categoryName]![bmr.arrayIdx].id,
          'calendarRefId': -1, //use negative 1 because it is not on calendar
          'scheduledDate': widget.selectdDate.toString(),
        };
        String bodyF = jsonEncode(body);
        //print(bodyF);

        var url = Uri.parse(
            PlannerService.sharedInstance.serverUrl + '/backlog/schedule');
        var response2 = await http.patch(url,
            headers: {"Content-Type": "application/json"}, body: bodyF);
        //print('Response status: ${response2.statusCode}');
        //print('Response body: ${response2.body}');

        if (response2.statusCode == 200) {
          print("scheduling successful");
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
      // PlannerService.sharedInstance.user!.backlogItems.add(newBacklogItem);
      // PlannerService.sharedInstance.user!.backlogItems
      //     .sort((backlogItem1, backlogItem2) {
      //   DateTime backlogItem1Date = backlogItem1.completeBy!;
      //   DateTime backlogItem2Date = backlogItem2.completeBy!;
      //   return backlogItem1Date.compareTo(backlogItem2Date);
      // });

      widget.updateBacklog();
      _backToBacklogPage();
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
    //print(dateTxtController.text);
    print("setting done button state");
    print(descriptionTxtController.text);
    print(selectedDate);
    if (descriptionTxtController.text != "" && selectedDate != null) {
      setState(() {
        //print("button enabled");
        doneBtnDisabled = false;
      });
    } else {
      setState(() {
        doneBtnDisabled = true;
      });
    }
  }

  void _backToBacklogPage() {
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
            backgroundColor: Colors.transparent,

            title: const Text(
              "New Task",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            //leading: BackButton(color: Colors.black),
            actions: [
              TextButton(
                onPressed: doneBtnDisabled ? null : createBacklogItem,
                child: Text("Done"),
              ),
            ],
          ),
          body: Card(
            color: Colors.white,
            child: Container(
              child: ListView(
                children: [
                  // Image.asset(
                  //   "assets/images/backlog_icon.png",
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
                              hintText: "What's the task?",
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
                            controller: dateTxtController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "Complete by",
                              icon: Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            onTap: () => _selectDate(context),
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
                          alignment: Alignment.center,
                          child: DropdownButton(
                            //value: PlannerService.sharedInstance.user.theme.themeId,
                            value: chosenStatus,
                            items: [
                              DropdownMenuItem(
                                //value: "pink",
                                value: "notStarted",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.grey,
                                    ),
                                    Text("Not Started"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                //value: "pink",
                                value: "started",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.yellow,
                                    ),
                                    Text("Started"),
                                  ],
                                ),
                              ),
                            ],

                            // onChanged: (String? newValue) {
                            onChanged: (String? newValue) {
                              print(newValue);
                              setState(() {
                                chosenStatus = newValue!;
                              });
                            },
                          ),
                        ),
                        Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      "Choose a Life Category",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Your life categories help you organize your tasks (i.e. business, self-care, fitness, work, school, etc.). You can create new life categories in your profile by clicking on your avatar on the home page.'),
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
                                    },
                                    icon: const Icon(
                                      Icons.info,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                              DropdownButton(
                                //value: PlannerService.sharedInstance.user.theme.themeId,
                                value: currChosenCategory,
                                items: List.generate(
                                    PlannerService.sharedInstance.user!
                                        .lifeCategories.length, (int index) {
                                  return DropdownMenuItem(
                                    //value: "pink",
                                    value: PlannerService.sharedInstance.user!
                                        .lifeCategories[index],
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: PlannerService
                                              .sharedInstance
                                              .user!
                                              .lifeCategories[index]
                                              .color,
                                        ),
                                        Text(PlannerService.sharedInstance.user!
                                            .lifeCategories[index].name),
                                      ],
                                    ),
                                  );
                                }),

                                // onChanged: (String? newValue) {
                                onChanged: (LifeCategory? newValue) {
                                  setState(() {
                                    currChosenCategory = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(20),
                        ),
                        Container(
                          child: TextFormField(
                            controller: locationTxtController,
                            decoration: InputDecoration(
                                hintText: "Location (Optional)",
                                icon: Icon(
                                  Icons.location_pin,
                                  //color: Colors.pink,
                                  color: Theme.of(context).colorScheme.primary,
                                )),
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
                            controller: notesTxtController,
                            decoration: const InputDecoration(
                              hintText: "Notes",
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
