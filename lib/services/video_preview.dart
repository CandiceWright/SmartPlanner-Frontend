import 'dart:io';

import 'package:flutter/material.dart';
import 'package:practice_planner/models/inward_item.dart';
import 'package:video_player/video_player.dart';

import '../../services/planner_service.dart';
import '../models/story.dart';
import '../views/navigation_wrapper.dart';

class VideoPreviewPage extends StatefulWidget {
  final String filePath;
  // final Function updateView;

  const VideoPreviewPage({
    Key? key,
    required this.filePath,
  }) : super(key: key);

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
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
        // _controller.addListener(checkVideoEnded);
      });
  }

  saveStory() {
    setState(() {
      PlannerService.sharedInstance.user!.stories.add(Story(
          File(widget.filePath),
          PlannerService.sharedInstance.user!.profileImage,
          DateTime.now()));
    });
    Navigator.of(context).popUntil((route) {
      return route.settings.name == 'navigaionPage';
    });

    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) {
    //     return const NavigationWrapper();
    //   },
    //   settings: const RouteSettings(
    //     name: 'navigaionPage',
    //   ),
    // ));
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
          persistentFooterButtons: [
            ElevatedButton(
              onPressed: () {
                saveStory();
              },
              child: Text("Save"),
            ),
          ],
        )
      ],
    );
  }
}
