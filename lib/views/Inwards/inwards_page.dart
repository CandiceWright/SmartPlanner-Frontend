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

import 'new_inward_item_page.dart';

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
    if (PlannerService.sharedInstance.user!.hasPlanitVideo) {
      _videoPlayerController = VideoPlayerController.file(
          File(PlannerService.sharedInstance.user!.planitVideo))
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
        });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void updateState() {
    setState(() {});
  }

  void _openNewInwardItemPage() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                NewInwardItemPage(updateContent: _updateContent)));
  }

  void _updateContent() {
    setState(() {});
  }

  setVideoController(XFile video) {
    setState(() {
      _videoPlayerController = VideoPlayerController.file(File(video.path))
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
        });
    });
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
            title:
                const Text("The Cover", style: TextStyle(color: Colors.white)),
            centerTitle: true,
            bottom: const PreferredSize(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "This is Me...",
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
                                    "Every now and then we have to think about and remind ourselves who we are. This is it! Record a short video for your planit that you can always look back and reflect on. You can update this video as much as you'd like. So what do you say?",
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      XFile? video =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CaptureVideoWithImagePicker(
                                            prevPage: "inward",
                                            updateState: updateState,
                                          ),
                                        ),
                                      );

                                      // print("about to start cameera to record");
                                      // final XFile? video =
                                      //     await _picker.pickVideo(
                                      //         source: ImageSource.camera,
                                      //         maxDuration:
                                      //             const Duration(minutes: 7));

                                      // print("video has been recorded");
                                      //print(video!.path);
                                      if (video != null) {
                                        //await video.saveTo(video.path);
                                        setVideoController(video);
                                        setState(() {
                                          fileMedia = video;
                                          PlannerService.sharedInstance.user!
                                              .planitVideo = video.path;
                                          PlannerService.sharedInstance.user!
                                              .hasPlanitVideo = true;
                                        });
                                      } else {
                                        print("Something is wrong");
                                        return;
                                      }
                                    },
                                    child: Text("Record Video"))
                              ],
                            ),
                          ),
                        ),
                  // child: _videoPlayerController.value.isInitialized &&
                  //         PlannerService.sharedInstance.user!.hasPlanitVideo
                  //     ? Container(
                  //         margin: EdgeInsets.all(20),
                  //         child: AspectRatio(
                  //           aspectRatio:
                  //               _videoPlayerController.value.aspectRatio,
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(15),
                  //             child: Stack(
                  //               alignment: Alignment.bottomCenter,
                  //               children: <Widget>[
                  //                 VideoPlayer(_videoPlayerController),
                  //                 VideoProgressIndicator(_videoPlayerController,
                  //                     allowScrubbing: true),
                  //               ],
                  //             ),
                  //           ),
                  //         ))
                  //     : Card(
                  //         child: Column(
                  //           mainAxisSize: MainAxisSize.min,
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text("This is your space, so what do you say?"),
                  //             ElevatedButton(
                  //                 onPressed: () async {
                  //                   XFile? video =
                  //                       await Navigator.of(context).push(
                  //                     MaterialPageRoute(
                  //                       builder: (context) =>
                  //                           const CaptureVideoWithImagePicker(),
                  //                     ),
                  //                   );

                  //                   // print("about to start cameera to record");
                  //                   // final XFile? video =
                  //                   //     await _picker.pickVideo(
                  //                   //         source: ImageSource.camera,
                  //                   //         maxDuration:
                  //                   //             const Duration(minutes: 7));

                  //                   // print("video has been recorded");
                  //                   //print(video!.path);
                  //                   if (video != null) {
                  //                     //await video.saveTo(video.path);
                  //                     setVideoController(video);
                  //                     setState(() {
                  //                       fileMedia = video;
                  //                       PlannerService.sharedInstance.user!
                  //                           .planitVideo = video.path;
                  //                       PlannerService.sharedInstance.user!
                  //                           .hasPlanitVideo = true;
                  //                     });
                  //                   } else {
                  //                     print("Something is wrong");
                  //                     return;
                  //                   }
                  //                 },
                  //                 child: Text("Record Video"))
                  //           ],
                  //         ),
                  //       ),
                ),
              )
            ],
          ),

          floatingActionButton: PlannerService
                  .sharedInstance.user!.hasPlanitVideo
              ? FloatingActionButton(
                  onPressed: _openNewInwardItemPage,
                  tooltip: 'Record new video',
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
