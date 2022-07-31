import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice_planner/models/definition.dart';
import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/services/capture_video_with_imagepicker.dart';
import 'package:practice_planner/views/Dictionary/edit_definition_page.dart';
import 'package:practice_planner/views/Dictionary/new_definition_page.dart';
import 'package:practice_planner/views/Goals/accomplished_goals_page.dart';
import 'package:video_player/video_player.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;

class InwardsPage extends StatefulWidget {
  const InwardsPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<InwardsPage> createState() => _InwardsPageState();
}

class _InwardsPageState extends State<InwardsPage> {
  late VideoPlayerController _videoPlayerController;
  final ImagePicker _picker = ImagePicker();
  late XFile fileMedia;

  //ConfettiController _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
    print("I am about to show video on inwards page");
    print(PlannerService.sharedInstance.user!.planitVideo);
    //if (PlannerService.sharedInstance.user!.hasPlanitVideo) {
    _videoPlayerController = VideoPlayerController.network(
        PlannerService.sharedInstance.user!.planitVideo)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
      });
    //}
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void updateState() {
    setState(() {
      setVideoController();
    });
  }

  void _updateContent() {
    setState(() {});
  }

  setVideoController() {
    setState(() {
      _videoPlayerController = VideoPlayerController.network(
          PlannerService.sharedInstance.user!.planitVideo)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
        });
    });
  }

  createInwardVideo(XFile? video) async {
    if (video != null) {
      String path = video.path;
      String name = video.name;
      print("I am in save inward video");
      //final thumbnail = await VideoCompress.getFileThumbnail(path);
      String? result =
          await PlannerService.firebaseStorage.uploadStory(path, name);

      //store story in db then add story object to the list of stories
      print("result is ready");
      print(result);
      if (result == "error") {
        //error message
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
        //success and result holds url
        print("success getting video url");
        print(result);

        //successfully saved thumbnail and result2 has thumbnail url
        //save tto db now
        var url = Uri.parse(
            PlannerService.sharedInstance.serverUrl + '/user/inwardvideo');
        var body = {
          'userId': PlannerService.sharedInstance.user!.id,
          'inwardVideo': result,
          //'thumbnail': PlannerService.sharedInstance.user!.profileImage
        };
        String bodyF = jsonEncode(body);
        var response = await http.patch(url,
            headers: {"Content-Type": "application/json"}, body: bodyF);

        print("server came back with a response after saving story");
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          print("success saving to db");
          // var decodedBody = json.decode(response.body);
          // print(decodedBody);
          // var id = decodedBody["insertId"];
          // PlannerService.sharedInstance.user!.planitVideo = result!;
          //Story newStory = Story(id, result!, result2!, DateTime.now());
          setState(() {
            // PlannerService.sharedInstance.user!.profileImage = path;
            PlannerService.sharedInstance.user!.planitVideo = result!;

            PlannerService.sharedInstance.user!.hasPlanitVideo = true;
            setVideoController();
          });
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
        //}
      }
    } else {
      return;
    }
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
            title: const Text("Another Planit",
                style: TextStyle(color: Colors.white)),
            centerTitle: true,
            bottom: const PreferredSize(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "My Personal Space",
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
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  //color: Colors.transparent,
                  //     _controller.value.isInitialized
                  // ? AspectRatio(
                  //     aspectRatio: _controller.value.aspectRatio,
                  //     child: VideoPlayer(_controller),
                  //   )
                  // : Container(),
                  child: PlannerService.sharedInstance.user!.hasPlanitVideo
                      ? (_videoPlayerController.value.isInitialized
                          ? Container(
                              margin: EdgeInsets.all(20),
                              child: AspectRatio(
                                aspectRatio:
                                    _videoPlayerController.value.aspectRatio,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
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
                              ))
                          : Container())
                      : Card(
                          margin: EdgeInsets.all(15),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "This is your cover video, 1-2 minutes. Whenever you enter your planit, you'll see it. Think of it as a positive video message to yourself that you can watch and reflect on whenever you want. Tip: Add whatever makes you 'YOU' in this cover video. You can record a video or upload one. ",
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CaptureVideoWithImagePicker(
                                                prevPage: "inward",
                                                updateState: updateState,
                                              ),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          child: const Icon(
                                            Icons.video_camera_front,
                                            color: Colors.white,
                                          ),
                                          radius: 25,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          final XFile? video =
                                              await _picker.pickVideo(
                                                  source: ImageSource.gallery,
                                                  maxDuration: const Duration(
                                                      minutes: 2));
                                          createInwardVideo(video);
                                        },
                                        child: CircleAvatar(
                                          child: const Icon(
                                            Icons.upload,
                                            color: Colors.white,
                                          ),
                                          radius: 25,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              )
            ],
          ),

          floatingActionButton: PlannerService
                  .sharedInstance.user!.hasPlanitVideo
              ? FloatingActionButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Change Cover Video"),
                            content: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CaptureVideoWithImagePicker(
                                            prevPage: "inward",
                                            updateState: updateState,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      child: const Icon(
                                        Icons.video_camera_front,
                                        color: Colors.white,
                                      ),
                                      radius: 50,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final XFile? video =
                                          await _picker.pickVideo(
                                              source: ImageSource.gallery,
                                              maxDuration:
                                                  const Duration(minutes: 2));
                                      createInwardVideo(video);
                                    },
                                    child: CircleAvatar(
                                      child: const Icon(
                                        Icons.upload,
                                        color: Colors.white,
                                      ),
                                      radius: 50,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                  tooltip: 'New video',
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                )
              : null, // This trailing comma makes auto-formatting nicer for build methods.
        )
      ],
    );
  }
}
