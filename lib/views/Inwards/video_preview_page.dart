import 'dart:io';

import 'package:flutter/material.dart';
import 'package:practice_planner/models/inward_item.dart';
import 'package:video_player/video_player.dart';

import '../../services/planner_service.dart';
import '../navigation_wrapper.dart';

class VideoPreviewPage extends StatefulWidget {
  final String filePath;

  const VideoPreviewPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _VideoPreviewPageState createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  late VideoPlayerController _videoPlayerController;
  var captionTextController = TextEditingController();
  bool saveThoughtBtnDisabled = true;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    print(widget.filePath);
    captionTextController.addListener(setSaveThoughtBtnState);
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
        // _controller.addListener(checkVideoEnded);
      });
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  saveThought() {
    var thought = InwardItem(
        0, captionTextController.text, DateTime.now(), widget.filePath);
    setState(() {
      PlannerService.sharedInstance.user!.inwardContent.add(thought);
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const NavigationWrapper();
      },
      settings: const RouteSettings(
        name: 'navigaionPage',
      ),
    ));
  }

  void setSaveThoughtBtnState() {
    if (captionTextController.text != "") {
      setState(() {
        print("button enabled");
        saveThoughtBtnDisabled = false;
      });
    } else {
      setState(() {
        saveThoughtBtnDisabled = true;
      });
    }
  }

  addDescriptiionClicked() {
    showDialog(
      context: context, // user must tap button!

      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            //insetPadding: EdgeInsets.symmetric(vertical: 200, horizontal: 100),
            //child: Expanded(
            //child: Container(
            title: const Text("New Thought"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: addDescripttionDialogContent(setDialogState),

            actions: <Widget>[
              TextButton(
                  child: const Text('save'),
                  onPressed: saveThoughtBtnDisabled ? null : saveThought),
              TextButton(
                child: const Text('cancel'),
                onPressed: () {
                  captionTextController.text = "";
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

  addDescripttionDialogContent(StateSetter setDialogState) {
    return TextFormField(
      controller: captionTextController,
      onChanged: (text) {
        setDialogState(() {
          if (text != "") {
            setState(() {
              print("button enabled");
              saveThoughtBtnDisabled = false;
            });
          } else {
            setState(() {
              saveThoughtBtnDisabled = true;
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

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: EdgeInsets.all(5),
              child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
            title: const Text(
              'Quick Thought or Reminder',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          //extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            //color: Colors.transparent,
            height: MediaQuery.of(context).size.height - // total height
                kToolbarHeight - // top AppBar height
                MediaQuery.of(context).padding.top - // top padding
                kBottomNavigationBarHeight,
            child: AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_videoPlayerController),
                  VideoProgressIndicator(_videoPlayerController,
                      allowScrubbing: true),
                ],
              ),
            ),
          ),

          // body: SingleChildScrollView(
          //   //body: Container(
          //   child: Column(
          //     children: <Widget>[
          //       Container(
          //         padding: const EdgeInsets.only(top: 20.0),
          //       ),
          //       Container(
          //         padding: const EdgeInsets.all(20),
          // child: AspectRatio(
          //   aspectRatio: _videoPlayerController.value.aspectRatio,
          //   child: Stack(
          //     alignment: Alignment.bottomCenter,
          //     children: <Widget>[
          //       VideoPlayer(_videoPlayerController),
          //       VideoProgressIndicator(_videoPlayerController,
          //           allowScrubbing: true),
          //     ],
          //   ),
          // ),
          //       ),
          //       TextFormField(
          //         controller: captionTextController,
          //         decoration: const InputDecoration(
          //           hintText: "Description (optional)",
          //           fillColor: Colors.white,
          //         ),
          //         validator: (String? value) {
          //           if (value == null || value.isEmpty) {
          //             return 'Please enter some text';
          //           }
          //           return null;
          //         },
          //         //maxLines: null,
          //         //minLines: 5,
          //       ),
          //       // ElevatedButton(
          //       //   onPressed: () {},
          //       //   child: Text("Save"),
          //       // ),
          //       // TextButton(
          //       //   onPressed: () {},
          //       //   child: Text("Cancel"),
          //       // ),
          //     ],
          //   ),
          // ),
          persistentFooterButtons: [
            ElevatedButton(
              onPressed: () {
                addDescriptiionClicked();
              },
              child: Text("Next"),
            ),
          ],

//working best
          // body: Center(
          //   child: Container(
          //     margin: const EdgeInsets.all(20),
          //     child: FutureBuilder(
          //       future: _initVideoPlayer(),
          //       builder: (context, state) {
          //         if (state.connectionState == ConnectionState.waiting) {
          //           return const Center(child: CircularProgressIndicator());
          //         } else {
          //           return VideoPlayer(_videoPlayerController);
          //         }
          //       },
          //     ),
          //   ),
          // ),
        )
      ],
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('New Thought'),
    //     elevation: 0,
    //     backgroundColor: Colors.black26,
    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.check),
    //         onPressed: () {
    //           print('do something with the file');
    //         },
    //       )
    //     ],
    //   ),
    //   extendBodyBehindAppBar: true,
    //   body: FutureBuilder(
    //     future: _initVideoPlayer(),
    //     builder: (context, state) {
    //       if (state.connectionState == ConnectionState.waiting) {
    //         return const Center(child: CircularProgressIndicator());
    //       } else {
    //         return VideoPlayer(_videoPlayerController);
    //       }
    //     },
    //   ),
    // );
  }
}
