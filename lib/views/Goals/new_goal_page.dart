import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/models/life_category.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class NewGoalPage extends StatefulWidget {
  const NewGoalPage({Key? key, required this.updateGoals}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateGoals;

  @override
  State<NewGoalPage> createState() => _NewGoalPageState();
}

class _NewGoalPageState extends State<NewGoalPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  var dateTxtController = TextEditingController();
  var descriptionTxtController = TextEditingController();
  var notesTxtController = TextEditingController();
  var categoryTxtController = TextEditingController();
  bool doneBtnDisabled = true;
  var currChosenCategory =
      PlannerService.sharedInstance.user!.lifeCategories[0];
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImg;
  File? fileMedia;

  @override
  void initState() {
    super.initState();
    dateTxtController.addListener(setDoneBtnState);
    descriptionTxtController.addListener(setDoneBtnState);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateTxtController.text = DateFormat.yMMMd().format(selectedDate);
        //print(DateFormat.yMMMd().format(selectedDate));
      });
  }

  void chooseImage() {}

  void createGoal() async {
    //first save image and get url
    String? imgUrl = "";
    String bodyF = "";
    var goalTitle = descriptionTxtController.text;
    var goalNotes = notesTxtController.text;
    print("I am in create goal and this is selectedImg");
    print(_selectedImg);
    if (_selectedImg != null) {
      print("an image was chosen");
      //save image to storage and get url
      imgUrl = await PlannerService.firebaseStorage
          .uploadPicture(_selectedImg!.path, "/goals/" + _selectedImg!.name);
      if (imgUrl == "error") {
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
      } else {
        var body = {
          'userId': PlannerService.sharedInstance.user!.id,
          'description': goalTitle,
          'type': "goal",
          'start': selectedDate.toString(),
          'end': selectedDate.toString(),
          'notes': goalNotes,
          'category': currChosenCategory.id,
          'isAllDay': true,
          'isAccomplished': false,
          'imgUrl': imgUrl
        };
        bodyF = jsonEncode(body);
        print(bodyF);

        var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/goals');
        var response = await http.post(url,
            headers: {"Content-Type": "application/json"}, body: bodyF);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          var decodedBody = json.decode(response.body);
          print(decodedBody);
          var id = decodedBody["insertId"];
          var newGoal = Event(
              id: id,
              description: goalTitle,
              type: "goal",
              start: selectedDate,
              end: selectedDate,
              //background: const Color(0xFFFF80b1),
              background: currChosenCategory.color,
              isAllDay: true,
              notes: goalNotes,
              category: currChosenCategory,
              isAccomplished: false,
              imageUrl: imgUrl);
          PlannerService.sharedInstance.user!.goals.add(newGoal);
          PlannerService.sharedInstance.user!.goals.sort((goal1, goal2) {
            DateTime goal1Date = goal1.start;
            DateTime goal2Date = goal2.start;
            return goal1Date.compareTo(goal2Date);
          });
          widget.updateGoals();
          _backToGoalsPage();
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
    } else {
      print("no image chosen");
      var body = {
        'userId': PlannerService.sharedInstance.user!.id,
        'description': goalTitle,
        'type': "goal",
        'start': selectedDate.toString(),
        'end': selectedDate.toString(),
        'notes': goalNotes,
        'category': currChosenCategory.id,
        'isAllDay': true,
        'isAccomplished': false,
        'imgUrl': imgUrl
      };
      bodyF = jsonEncode(body);
      print(bodyF);

      var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/goals');
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var decodedBody = json.decode(response.body);
        print(decodedBody);
        var id = decodedBody["insertId"];
        var newGoal = Event(
            id: id,
            description: goalTitle,
            type: "goal",
            start: selectedDate,
            end: selectedDate,
            //background: const Color(0xFFFF80b1),
            background: currChosenCategory.color,
            isAllDay: true,
            notes: goalNotes,
            category: currChosenCategory,
            isAccomplished: false,
            imageUrl: imgUrl);
        PlannerService.sharedInstance.user!.goals.add(newGoal);
        PlannerService.sharedInstance.user!.goals.sort((goal1, goal2) {
          DateTime goal1Date = goal1.start;
          DateTime goal2Date = goal2.start;
          return goal1Date.compareTo(goal2Date);
        });
        widget.updateGoals();
        _backToGoalsPage();
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
  }

  void setDoneBtnState() {
    print(dateTxtController.text);
    print(descriptionTxtController.text);
    if (dateTxtController.text != "" && descriptionTxtController.text != "") {
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

  void _backToGoalsPage() {
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
              "New Goal",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,

            centerTitle: true,
            //leading: BackButton(color: Colors.black),
            actions: [
              TextButton(
                onPressed: doneBtnDisabled ? null : createGoal,
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
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    child: TextButton(
                                      child: Text("Add an image (Optional)"),
                                      onPressed: () async {
                                        _selectedImg = await _picker.pickImage(
                                            source: ImageSource.gallery);
                                        print(_selectedImg);
                                        if (_selectedImg != null) {
                                          setState(() {
                                            fileMedia =
                                                File(_selectedImg!.path);
                                          });
                                        }
                                      },

                                      //style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                ],
                              ),
                              CircleAvatar(
                                // // backgroundImage: AssetImage(
                                //     PlannerService.sharedInstance.user!.profileImage),
                                backgroundImage: _selectedImg != null
                                    ? FileImage(fileMedia!)
                                    : null,
                                radius: _selectedImg != null ? 40 : 0,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            controller: descriptionTxtController,
                            decoration: const InputDecoration(
                              hintText: "What's your goal?",
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
                              hintText: "By",
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
                                    icon: Icon(Icons.help),
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
    // return Scaffold(
    //   appBar: AppBar(
    //     // Here we take the value from the MyHomePage object that was created by
    //     // the App.build method, and use it to set our appbar title.
    //     title: Text("New Goal"),
    //     centerTitle: true,
    //     leading: BackButton(color: Colors.black),
    //     actions: [
    //       TextButton(
    //         onPressed: doneBtnDisabled ? null : createGoal,
    //         child: Text("Done"),
    //       ),
    //       // IconButton(
    //       //   icon: const Icon(Icons.check),
    //       //   color: Colors.pink,
    //       //   tooltip: 'Open shopping cart',
    //       //   onPressed: () {
    //       //     // handle the press
    //       //   },
    //       // ),
    //     ],
    //   ),
    //   body: Card(
    //     child: Container(
    //       child: ListView(
    //         children: [
    //           // Image.asset(
    //           //   "assets/images/goal_icon.png",
    //           //   height: 80,
    //           //   width: 80,
    //           // ),
    //           Form(
    //             key: _formKey,
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 Container(
    //                   child: TextFormField(
    //                     controller: descriptionTxtController,
    //                     decoration: const InputDecoration(
    //                       hintText: "What's your goal?",
    //                     ),
    //                     validator: (String? value) {
    //                       if (value == null || value.isEmpty) {
    //                         return 'Please enter some text';
    //                       }
    //                       return null;
    //                     },
    //                   ),
    //                   padding: EdgeInsets.all(20),
    //                 ),
    //                 Container(
    //                   child: TextFormField(
    //                     controller: dateTxtController,
    //                     readOnly: true,
    //                     decoration: InputDecoration(
    //                       hintText: "By",
    //                       icon: Icon(
    //                         Icons.calendar_today,
    //                         color: Theme.of(context).colorScheme.primary,
    //                       ),
    //                     ),
    //                     onTap: () => _selectDate(context),
    //                     validator: (String? value) {
    //                       if (value == null || value.isEmpty) {
    //                         return 'Please enter some text';
    //                       }
    //                       return null;
    //                     },
    //                   ),
    //                   padding: EdgeInsets.all(20),
    //                 ),
    //                 Container(
    //                   child: DropdownButton(
    //                     //value: PlannerService.sharedInstance.user.theme.themeId,
    //                     value: currChosenCategory,
    //                     items: List.generate(
    //                         PlannerService.sharedInstance.user.lifeCategories
    //                             .length, (int index) {
    //                       return DropdownMenuItem(
    //                         //value: "pink",
    //                         value: PlannerService
    //                             .sharedInstance.user.lifeCategories[index],
    //                         child: Row(
    //                           children: [
    //                             Icon(
    //                               Icons.circle,
    //                               color: PlannerService.sharedInstance.user
    //                                   .lifeCategories[index].color,
    //                             ),
    //                             Text(PlannerService.sharedInstance.user
    //                                 .lifeCategories[index].name),
    //                           ],
    //                         ),
    //                       );
    //                     }),

    //                     // onChanged: (String? newValue) {
    //                     onChanged: (LifeCategory? newValue) {
    //                       setState(() {
    //                         currChosenCategory = newValue!;
    //                       });
    //                     },
    //                   ),
    //                   padding: EdgeInsets.all(20),
    //                 ),
    //                 Container(
    //                   child: TextFormField(
    //                     controller: notesTxtController,
    //                     decoration: const InputDecoration(
    //                       hintText: "Notes",
    //                       fillColor: Colors.white,
    //                     ),
    //                     validator: (String? value) {
    //                       if (value == null || value.isEmpty) {
    //                         return 'Please enter some text';
    //                       }
    //                       return null;
    //                     },
    //                     maxLines: null,
    //                     minLines: 10,
    //                   ),
    //                   padding: EdgeInsets.all(20),
    //                   margin: EdgeInsets.only(top: 10),
    //                   decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(8.0),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           )
    //         ],
    //       ),
    //       margin: EdgeInsets.all(15),
    //     ),
    //     //color: Colors.pink.shade50,
    //     // margin: EdgeInsets.all(20),
    //     margin: EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
    //     elevation: 5,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(10.0),
    //     ),
    //   ),
    // );
  }
}
