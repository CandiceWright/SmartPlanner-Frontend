// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/models/event_data_source.dart';
import 'package:practice_planner/models/habit.dart';
import 'package:practice_planner/services/vide_capturer.dart';
import 'package:practice_planner/views/Calendar/calendar_page.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:video_player/video_player.dart';
import '/views/Goals/goals_page.dart';
import '/services/planner_service.dart';
import '../Profile/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _HomePageState extends State<HomePage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  //var todayTasks = PlannerService.sharedInstance.user.todayTasks;
  var newHabitTextController = TextEditingController();
  var planitMessageTxtController = TextEditingController();
  var editHabitTxtController = TextEditingController();
  bool editHabitBtnDisabled = false;
  bool saveHabitBtnDisabled = true;
  late VideoPlayerController _videoPlayerController;

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
    newHabitTextController.addListener(setSaveHabitBtnState);
    editHabitTxtController.addListener(setEditHabitBtnState);
  }

  Future _initVideoPlayer(File videoFile) async {
    print("Im in init player and this is file " + videoFile.path);
    _videoPlayerController = VideoPlayerController.file(videoFile);
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(false);
    await _videoPlayerController.play();
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

  void deleteStory(int idx) {
    print("this is the current size of stories");
    print(PlannerService.sharedInstance.user!.stories.length);
    print("this is tthe index of curr story");
    print(idx);
    //Navigator.pop(context);
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
                      '/user/stories/' +
                      PlannerService.sharedInstance.user!.stories[idx].id
                          .toString());
                  var response = await http.delete(
                    url,
                  );
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    //delete file from firebase
                    String? result = await PlannerService.firebaseStorage
                        .deleteFile(PlannerService
                            .sharedInstance.user!.stories[idx].video);
                    print("firebase delete done");
                    print(result);
                    if (result! == "success") {
                      PlannerService.sharedInstance.user!.stories.removeAt(idx);
                      setState(() {});
                      //Navigator.pop(context);
                      _videoPlayerController.pause();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return const NavigationWrapper();
                        },
                        settings: const RouteSettings(
                          name: 'navigaionPage',
                        ),
                      ));
                    } else {
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

  List<Widget> buildTodayTaskListView() {
    print("building today tasks widget");
    List<Widget> todayTasksWidgets = [];
    for (int i = 0;
        i < PlannerService.sharedInstance.user!.todayTasks.length;
        i++) {
      Widget taskWidget = CheckboxListTile(
        title:
            Text(PlannerService.sharedInstance.user!.todayTasks[i].description),
        value: PlannerService.sharedInstance.user!.todayTasks[i].isComplete,
        selected: PlannerService.sharedInstance.user!.todayTasks[i].isComplete,
        onChanged: (bool? value) {
          print(value);
          setState(() {
            PlannerService.sharedInstance.user!.todayTasks[i].isComplete =
                value;
            PlannerService.sharedInstance.user!.todayTasks[i].isComplete =
                value;
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

  List<Widget> buildStories() {
    List<Widget> stories = [];
    Widget addStoryWidget = GestureDetector(
      child: const Padding(
        child: CircleAvatar(
          child: Icon(Icons.add_circle),
          radius: 30,
        ),
        padding: EdgeInsets.all(5),
      ),
      onTap: () {
        //print("ready to recordx");
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => const VideoCapturer(
                      videoType: "story",
                    )));
      },
    );
    stories.add(addStoryWidget);

    List<Widget> currentStories = List.generate(
        PlannerService.sharedInstance.user!.stories.length, (int index) {
      return GestureDetector(
          child: Padding(
            child: CircleAvatar(
              backgroundImage: AssetImage(
                  PlannerService.sharedInstance.user!.stories[index].thumbnail),
              radius: 30,
            ),
            padding: EdgeInsets.all(5),
          ),
          onTap: () {
            _videoPlayerController = VideoPlayerController.network(
                PlannerService.sharedInstance.user!.stories[index].video)
              ..initialize().then((_) {
                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                setState(() {});

                // _controller.addListener(checkVideoEnded);
                showDialog(
                    barrierDismissible: false,
                    context: context, // user must tap button!

                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          builder: (context, setDialogState) {
                        return SimpleDialog(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      await _videoPlayerController.pause();
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.close)),
                                IconButton(
                                    onPressed: () {
                                      deleteStory(index);
                                    },
                                    icon: Icon(Icons.delete)),
                              ],
                            ),
                            Center(
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                child: AspectRatio(
                                  aspectRatio:
                                      _videoPlayerController.value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: <Widget>[
                                      VideoPlayer(_videoPlayerController),
                                      VideoProgressIndicator(
                                          _videoPlayerController,
                                          allowScrubbing: true),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                    });
                _videoPlayerController.play();
                _videoPlayerController.setLooping(true);
              });
          });
      // return Card(
      //   color: Colors.blue[index * 100],
      //   child: Container(
      //     width: 50.0,
      //     height: 50.0,
      //     child: Text("$index"),
      //   ),
      // );
    });

    stories.addAll(currentStories);
    return stories;
  }

  @override
  Widget build(BuildContext context) {
    //MaterialApp is a flutter class which has a constructor
    //List<Widget> todayTasksView = buildTodayTaskListView();
    //List<TableRow> habitTableRows = buildHabitsView();

    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
              onTap: () {
                openProfileView();
              },
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: PlannerService.sharedInstance.user!.profileImage ==
                        "assets/images/profile_pic_icon.png"
                    ? CircleAvatar(
                        // // backgroundImage: AssetImage(
                        //     PlannerService.sharedInstance.user!.profileImage),
                        backgroundImage: AssetImage(
                            PlannerService.sharedInstance.user!.profileImage),
                        radius: 40,
                      )
                    : CircleAvatar(
                        // // backgroundImage: AssetImage(
                        //     PlannerService.sharedInstance.user!.profileImage),
                        backgroundImage: NetworkImage(
                            PlannerService.sharedInstance.user!.profileImage),
                        radius: 40,
                      ),
              )),
          // IconButton(
          //   icon: Image.asset(
          //     PlannerService.sharedInstance.user!.profileImage,
          //     // height: 40,
          //     // width: 40,
          //   ),
          //   tooltip: 'Menu',
          //   onPressed: () {
          //     // handle the press
          //     openProfileView();
          //   },
          // ),
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
        automaticallyImplyLeading: false,
        title: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage(PlannerService.sharedInstance.user!.spaceImage),
                fit: BoxFit.cover,
              ),
            ),
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
                // Container(
                //   child: Column(
                //     children: [],
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    "PLANIT " + PlannerService.sharedInstance.user!.planitName,
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    //fontStyle: FontStyle.italic, color: Colors.white),
                    // textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          margin: EdgeInsets.all(15),
        ),
      ),
      body: Container(
        child: ListView(
          children: [
            Container(
              height: 80.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: buildStories(),
              ),
            ),
            Container(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "This Week's Habits...",
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  Container(
                    child: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                      },
                      children: [
                            TableRow(children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.fill,
                                child: Container(),
                              ),
                              TableCell(
                                  child: Container(
                                      child: const Text("S",
                                          textAlign: TextAlign.center))),
                              TableCell(
                                  child: const Text("M",
                                      textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("T", textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("W", textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("TH", textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("F", textAlign: TextAlign.center)),
                              TableCell(
                                  child:
                                      Text("S", textAlign: TextAlign.center)),
                            ])
                          ] +
                          List.generate(
                              PlannerService.sharedInstance.user!.habits.length,
                              (int i) {
                            return TableRow(children: [
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Container(
                                  child: TextButton(
                                    child: Text(
                                      PlannerService.sharedInstance.user!
                                          .habits[i].description,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      //style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      editHabitClicked(i);
                                    },
                                  ),
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user!
                                        .habits[i].habitTrackerMap["Sunday"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      //first create habit map
                                      Map<String, bool> habitMap = {
                                        "Sunday": value!,
                                        "Mon": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Mon"]!,
                                        "Tues": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Tues"]!,
                                        "Wed": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Wed"]!,
                                        "Thurs": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Thurs"]!,
                                        "Friday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Friday"]!,
                                        "Saturday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Saturday"]!,
                                      };
                                      editHabit(i, "dayUpdate", habitMap);
                                      // setState(() {
                                      //   PlannerService
                                      //       .sharedInstance
                                      //       .user!
                                      //       .habits[i]
                                      //       .habitTrackerMap["Sunday"] = value!;
                                      // });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user!
                                        .habits[i].habitTrackerMap["Mon"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      //first create habit map
                                      Map<String, bool> habitMap = {
                                        "Sunday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Sunday"]!,
                                        "Mon": value!,
                                        "Tues": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Tues"]!,
                                        "Wed": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Wed"]!,
                                        "Thurs": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Thurs"]!,
                                        "Friday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Friday"]!,
                                        "Saturday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Saturday"]!,
                                      };
                                      editHabit(i, "dayUpdate", habitMap);
                                      // setState(() {
                                      //   PlannerService
                                      //       .sharedInstance
                                      //       .user!
                                      //       .habits[i]
                                      //       .habitTrackerMap["Mon"] = value!;
                                      // });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user!
                                        .habits[i].habitTrackerMap["Tues"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      //first create habit map
                                      Map<String, bool> habitMap = {
                                        "Sunday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Sunday"]!,
                                        "Mon": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Mon"]!,
                                        "Tues": value!,
                                        "Wed": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Wed"]!,
                                        "Thurs": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Thurs"]!,
                                        "Friday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Friday"]!,
                                        "Saturday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Saturday"]!,
                                      };
                                      editHabit(i, "dayUpdate", habitMap);
                                      // setState(() {
                                      //   PlannerService
                                      //       .sharedInstance
                                      //       .user!
                                      //       .habits[i]
                                      //       .habitTrackerMap["Tues"] = value!;
                                      // });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user!
                                        .habits[i].habitTrackerMap["Wed"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      Map<String, bool> habitMap = {
                                        "Sunday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Sunday"]!,
                                        "Mon": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Mon"]!,
                                        "Tues": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Tues"]!,
                                        "Wed": value!,
                                        "Thurs": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Thurs"]!,
                                        "Friday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Friday"]!,
                                        "Saturday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Saturday"]!,
                                      };
                                      editHabit(i, "dayUpdate", habitMap);
                                      // setState(() {
                                      //   PlannerService
                                      //       .sharedInstance
                                      //       .user!
                                      //       .habits[i]
                                      //       .habitTrackerMap["Wed"] = value!;
                                      // });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user!
                                        .habits[i].habitTrackerMap["Thurs"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      Map<String, bool> habitMap = {
                                        "Sunday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Sunday"]!,
                                        "Mon": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Mon"]!,
                                        "Tues": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Tues"]!,
                                        "Wed": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Wed"]!,
                                        "Thurs": value!,
                                        "Friday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Friday"]!,
                                        "Saturday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Saturday"]!,
                                      };
                                      editHabit(i, "dayUpdate", habitMap);
                                      // setState(() {
                                      //   PlannerService
                                      //       .sharedInstance
                                      //       .user!
                                      //       .habits[i]
                                      //       .habitTrackerMap["Thurs"] = value!;
                                      // });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user!
                                        .habits[i].habitTrackerMap["Friday"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      Map<String, bool> habitMap = {
                                        "Sunday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Sunday"]!,
                                        "Mon": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Mon"]!,
                                        "Tues": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Tues"]!,
                                        "Wed": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Wed"]!,
                                        "Thurs": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Thurs"]!,
                                        "Friday": value!,
                                        "Saturday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Saturday"]!,
                                      };
                                      editHabit(i, "dayUpdate", habitMap);
                                      // setState(() {
                                      //   PlannerService
                                      //       .sharedInstance
                                      //       .user!
                                      //       .habits[i]
                                      //       .habitTrackerMap["Friday"] = value!;
                                      // });
                                    },
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    value: PlannerService.sharedInstance.user!
                                        .habits[i].habitTrackerMap["Saturday"]!,
                                    onChanged: (bool? value) {
                                      print(value);
                                      Map<String, bool> habitMap = {
                                        "Sunday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Sunday"]!,
                                        "Mon": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Mon"]!,
                                        "Tues": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Tues"]!,
                                        "Wed": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Wed"]!,
                                        "Thurs": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Thurs"]!,
                                        "Friday": PlannerService
                                            .sharedInstance
                                            .user!
                                            .habits[i]
                                            .habitTrackerMap["Friday"]!,
                                        "Saturday": value!,
                                      };
                                      editHabit(i, "dayUpdate", habitMap);
                                      // setState(() {
                                      //   PlannerService
                                      //           .sharedInstance
                                      //           .user!
                                      //           .habits[i]
                                      //           .habitTrackerMap["Saturday"] =
                                      //       value!;
                                      // });
                                    },
                                  ),
                                ),
                              ),
                            ]);
                          }),
                    ),
                    margin: EdgeInsets.only(top: 20),
                  ),
                  TextButton(
                      onPressed: addNewHabitClicked,
                      child: Text("Add New Habit"))
                ],
              ),
              margin: EdgeInsets.all(15),
            ),
            Container(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Upcoming Deadlines & Events",
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  //Column(children: [ListTile(leading: ,)],)
                  Container(
                    child: Container(
                      child: SfCalendar(
                        view: CalendarView.schedule,
                        dataSource: EventDataSource(PlannerService
                                .sharedInstance.user!.scheduledEvents +
                            PlannerService.sharedInstance.user!.goals),
                        scheduleViewSettings: const ScheduleViewSettings(
                            hideEmptyScheduleWeek: true,
                            monthHeaderSettings: MonthHeaderSettings(
                              monthFormat: 'MMMM, yyyy',
                              height: 60,
                              textAlign: TextAlign.center,
                              backgroundColor: Color(0xFF3700AD),
                            )),
                        // scheduleViewSettings: ScheduleViewSettings(
                        //   appointmentItemHeight: 70,
                        // ),
                      ),
                    ),
                    margin: EdgeInsets.only(top: 20),
                  ),
                ],
              ),
              margin: EdgeInsets.all(15),
            ),
          ],
        ),
        margin: EdgeInsets.all(15),
      ),
    );
  }

  addNewHabitClicked() {
    showDialog(
      context: context, // user must tap button!

      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            //insetPadding: EdgeInsets.symmetric(vertical: 200, horizontal: 100),
            //child: Expanded(
            //child: Container(
            title: const Text("New Habit"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: addNewHabitDialogContent(setDialogState),

            actions: <Widget>[
              TextButton(
                  child: const Text('save'),
                  onPressed: saveHabitBtnDisabled ? null : saveNewHabit),
              TextButton(
                child: const Text('cancel'),
                onPressed: () {
                  newHabitTextController.text = "";
                  Navigator.of(context).pop();
                },
              )
            ],
            // ),
            //),
          );
        });
      },
    );
  }

  addNewHabitDialogContent(StateSetter setDialogState) {
    return TextFormField(
      controller: newHabitTextController,
      onChanged: (text) {
        setDialogState(() {
          if (text != "") {
            setState(() {
              print("button enabled");
              saveHabitBtnDisabled = false;
            });
          } else {
            setState(() {
              saveHabitBtnDisabled = true;
            });
          }
        });
      },
      decoration: const InputDecoration(
        hintText: "Description",
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Future<void> saveNewHabit() async {
    //first make a call to the server with habit name, userId
    var body = {
      'userId': PlannerService.sharedInstance.user!.id,
      'description': newHabitTextController.text,
    };
    String bodyF = jsonEncode(body);
    print(bodyF);

    var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/habits');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      print(decodedBody);
      var id = decodedBody["insertId"];
      var newHabit = Habit(id: id, description: newHabitTextController.text);
      setState(() {
        PlannerService.sharedInstance.user!.habits.add(newHabit);
        newHabitTextController.text = "";
      });
      Navigator.of(context).pop();
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

  void setSaveHabitBtnState() {
    if (newHabitTextController.text != "") {
      setState(() {
        print("button enabled");
        saveHabitBtnDisabled = false;
      });
    } else {
      setState(() {
        saveHabitBtnDisabled = true;
      });
    }
  }

  /***************edit habit***********/

  editHabitClicked(int i) {
    print("Buttton was pressed");
    //habitClicked(i);
    //setEditHabitBtnState();
    editHabitTxtController.text =
        PlannerService.sharedInstance.user!.habits[i].description;
    showDialog(
      context: context, // user must tap button!

      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            //insetPadding: EdgeInsets.symmetric(vertical: 200, horizontal: 100),
            //child: Expanded(
            //child: Container(
            title: const Text("Edit Habit"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: editHabitDialogContent(setDialogState),

            actions: <Widget>[
              TextButton(
                  child: const Text('save'),
                  onPressed: editHabitBtnDisabled
                      ? null
                      : () {
                          print("pressed");
                          callEditHabit(i, "nameUpdate", null);
                        }),
              TextButton(
                  child: const Text('delete'),
                  onPressed: () {
                    print("delete button pressed");
                    deleteHabit(i);
                  }),
              TextButton(
                child: const Text('cancel'),
                onPressed: () {
                  newHabitTextController.text = "";
                  Navigator.of(context).pop();
                },
              )
            ],
            // ),
            //),
          );
        });
      },
    );
  }

  editHabitDialogContent(StateSetter setDialogState) {
    return TextFormField(
      controller: editHabitTxtController,
      onChanged: (text) {
        setDialogState(() {
          if (text != "") {
            setState(() {
              print("button enabled");
              editHabitBtnDisabled = false;
            });
          } else {
            setState(() {
              editHabitBtnDisabled = true;
            });
          }
        });
      },
      decoration: const InputDecoration(
        hintText: "Description",
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  void setEditHabitBtnState() {
    if (editHabitTxtController.text != "") {
      setState(() {
        print("button enabled");
        editHabitBtnDisabled = false;
      });
    } else {
      setState(() {
        editHabitBtnDisabled = true;
      });
    }
  }

  callEditHabit(int idx, String updateType, Map<String, bool>? habitMap) {
    editHabit(idx, updateType, habitMap);
  }

  Future<void> editHabit(
      int idx, String updateType, Map<String, bool>? habitMap) async {
    var body;
    if (updateType == "nameUpdate") {
      body = {
        'userId': PlannerService.sharedInstance.user!.id,
        'habitId': PlannerService.sharedInstance.user!.habits[idx].id,
        'description': editHabitTxtController.text,
        'sun': PlannerService
            .sharedInstance.user!.habits[idx].habitTrackerMap["Sunday"],
        'mon': PlannerService
            .sharedInstance.user!.habits[idx].habitTrackerMap["Mon"],
        'tues': PlannerService
            .sharedInstance.user!.habits[idx].habitTrackerMap["Tues"],
        'wed': PlannerService
            .sharedInstance.user!.habits[idx].habitTrackerMap["Wed"],
        'thurs': PlannerService
            .sharedInstance.user!.habits[idx].habitTrackerMap["Thurs"],
        'fri': PlannerService
            .sharedInstance.user!.habits[idx].habitTrackerMap["Friday"],
        'sat': PlannerService
            .sharedInstance.user!.habits[idx].habitTrackerMap["Saturday"]
      };
    } else {
      //dayUpdate
      body = {
        'userId': PlannerService.sharedInstance.user!.id,
        'habitId': PlannerService.sharedInstance.user!.habits[idx].id,
        'description':
            PlannerService.sharedInstance.user!.habits[idx].description,
        'sun': habitMap!["Sunday"],
        'mon': habitMap["Mon"],
        'tues': habitMap["Tues"],
        'wed': habitMap["Wed"],
        'thurs': habitMap["Thurs"],
        'fri': habitMap["Friday"],
        'sat': habitMap["Saturday"]
      };
    }
    //first make call to server
    String bodyF = jsonEncode(body);
    print(bodyF);

    var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/habits');
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (updateType == "nameUpdate") {
        setState(() {
          PlannerService.sharedInstance.user!.habits[idx].description =
              editHabitTxtController.text;
        });
        Navigator.of(context).pop();
      } else {
        //day update
        setState(() {
          PlannerService.sharedInstance.user!.habits[idx]
              .habitTrackerMap["Sunday"] = habitMap!["Sunday"]!;
          PlannerService.sharedInstance.user!.habits[idx]
              .habitTrackerMap["Mon"] = habitMap["Mon"]!;
          PlannerService.sharedInstance.user!.habits[idx]
              .habitTrackerMap["Tues"] = habitMap["Tues"]!;
          PlannerService.sharedInstance.user!.habits[idx]
              .habitTrackerMap["Wed"] = habitMap["Wed"]!;
          PlannerService.sharedInstance.user!.habits[idx]
              .habitTrackerMap["Thurs"] = habitMap["Thurs"]!;
          PlannerService.sharedInstance.user!.habits[idx]
              .habitTrackerMap["Friday"] = habitMap["Friday"]!;
          PlannerService.sharedInstance.user!.habits[idx]
              .habitTrackerMap["Saturday"] = habitMap["Saturday"]!;
        });
      }
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

  deleteHabit(i) {
    print("in delete habit");
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
                  var habitId =
                      PlannerService.sharedInstance.user!.habits[i].id;
                  //first call server
                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/habits/' +
                      habitId.toString());
                  var response = await http.delete(
                    url,
                  );
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    PlannerService.sharedInstance.user!.habits.removeAt(i);
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
}
