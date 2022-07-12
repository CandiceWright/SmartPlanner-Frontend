import 'package:practice_planner/views/navigation_wrapper.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class EnterPlannerVideoPage extends StatefulWidget {
  const EnterPlannerVideoPage({Key? key}) : super(key: key);

  @override
  State<EnterPlannerVideoPage> createState() => _EnterPlannerVideoPageState();
}

class _EnterPlannerVideoPageState extends State<EnterPlannerVideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
        "assets/images/another_planit_animation_video.mp4")
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.play();
        _controller.setLooping(false);
      });
  }

  goToPlanner() {
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
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
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
                    "Go to my Planit!",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xffef41a8)),
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
