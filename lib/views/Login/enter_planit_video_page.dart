import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class EnterPlannerVideoPage extends StatefulWidget {
  final String fromPage;
  const EnterPlannerVideoPage({Key? key, required this.fromPage})
      : super(key: key);

  @override
  State<EnterPlannerVideoPage> createState() => _EnterPlannerVideoPageState();
}

class _EnterPlannerVideoPageState extends State<EnterPlannerVideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.fromPage == "signup") {
      _controller = VideoPlayerController.asset(
          "assets/images/another_planit_animation_video.mp4")
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          _controller.play();
          _controller.setLooping(false);
          _controller.addListener(checkVideoEnded);
        });
    } else {
      _controller = VideoPlayerController.network(
          PlannerService.sharedInstance.user!.planitVideo)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          _controller.play();
          _controller.setLooping(false);
          _controller.addListener(checkVideoEnded);
        });
    }
  }

  void checkVideoEnded() {
    print("in check video ended");
    if (_controller.value.position == _controller.value.duration) {
      print("its true");
      print(_controller.value.position);
      print(_controller.value.duration);
      goToPlanner();
    }
  }

  goToPlanner() {
    _controller.removeListener(checkVideoEnded);
    _controller.pause();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const NavigationWrapper();
      },
      settings: const RouteSettings(
        name: 'navigaionPage',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/black_stars_background.jpeg",
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
            elevation: 0.0,
          ),
          body: _controller.value.isInitialized
              ? Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(_controller),
                          VideoProgressIndicator(_controller,
                              allowScrubbing: true),
                        ],
                      ),
                    ),
                  ))
              : Container(),
          persistentFooterButtons: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //FractionallySizedBox(
                //widthFactor: 0.5,
                //child: ElevatedButton(
                ElevatedButton(
                  onPressed: goToPlanner,
                  child: Text(
                    "Skip & Go to my Planit",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ButtonStyle(
                    // backgroundColor: MaterialStateProperty.all<Color>(
                    //     const Color(0xffef41a8)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor),
                  ),
                ),
                //),
              ],
            ),
          ],
        ),
      ],
    );
    // return MaterialApp(
    //   title: 'Video Demo',
    //   home: Scaffold(
    //     body: Center(
    //       child: _controller.value.isInitialized
    //           ? AspectRatio(
    //               aspectRatio: _controller.value.aspectRatio,
    //               child: VideoPlayer(_controller),
    //             )
    //           : Container(),
    //     ),
    //     floatingActionButton: FloatingActionButton(
    //       onPressed: () {
    //         setState(() {
    //           _controller.value.isPlaying
    //               ? _controller.pause()
    //               : _controller.play();
    //         });
    //       },
    //       child: Icon(
    //         _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
    //       ),
    //     ),
    //   ),
    // );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
