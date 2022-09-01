import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class EnterPlannerVideoPage extends StatefulWidget {
  final String fromPage;
  const EnterPlannerVideoPage({Key? key, required this.fromPage})
      : super(key: key);

  @override
  State<EnterPlannerVideoPage> createState() => _EnterPlannerVideoPageState();
}

class _EnterPlannerVideoPageState extends State<EnterPlannerVideoPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    // if (widget.fromPage == "signup") {
    // } else {}
  }

  Future setVideoController() async {
    print("I am setting video controller");
    if (widget.fromPage == "signup" ||
        !PlannerService.sharedInstance.user!.hasPlanitVideo) {
      _videoPlayerController = VideoPlayerController.asset(
          "assets/images/another_planit_animation_video.mp4");
      await _videoPlayerController.initialize();
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

      await _videoPlayerController.play();
      await _videoPlayerController.setLooping(false);
      _videoPlayerController.addListener(checkVideoEnded);
    } else {
      if (PlannerService.sharedInstance.user!.hasPlanitVideo) {
        print(PlannerService.sharedInstance.user!.planitVideoLocalPath);
        if (File(PlannerService.sharedInstance.user!.planitVideoLocalPath)
            .existsSync()) {
          print("file exists");
          //the file exists!
          //can use file
          _videoPlayerController = VideoPlayerController.file(
              File(PlannerService.sharedInstance.user!.planitVideoLocalPath));
          await _videoPlayerController.initialize();
          await _videoPlayerController.setLooping(false);
          await _videoPlayerController.play();
          _videoPlayerController.addListener(checkVideoEnded);
        } else {
          print("file does not exists");
          //need to get the video from s3
          //first get s3 get url, then store file locally and
          Object presignedUrl = await PlannerService.aws.getPresignedUrl(
              "get", PlannerService.sharedInstance.user!.planitVideo);
          if (presignedUrl != "error") {
            var url = Uri.parse(presignedUrl.toString());
            print(
                "this is the url i am trying to get in inwards page line 103");
            print(url);
            var response = await http.get(url);
            print('Response status: ${response.statusCode}');
            if (response.statusCode == 200) {
              //file is in resonse.body
              //need to save it to PlannerService.sharedInstant.user.planitVideoLocalPath
              print(PlannerService.sharedInstance.user!.planitVideoLocalPath);
              //String path = await lss.getlocalFilePath('hi');
              final directory = await getApplicationDocumentsDirectory();
              String path = directory.path;
              print("thiis is the path to local directtory");
              print(path);

              File file = File('$path/cover.mov');
              await file.writeAsBytes(response.bodyBytes);

              PlannerService.sharedInstance.user!.planitVideoLocalPath =
                  '$path/cover.mov';

              //update local path for cover in db
              //save new local path of story in db
              var body = {
                'userId': PlannerService.sharedInstance.user!.id,
                'inwardVideoUrl':
                    PlannerService.sharedInstance.user!.planitVideo,
                'coverVideoLocalPath': '$path/cover.mov',
              };
              String bodyF = jsonEncode(body);
              print(bodyF);

              var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                  '/user/inwardvideo');
              var response2 = await http.patch(url,
                  headers: {"Content-Type": "application/json"}, body: bodyF);
              print('Response status: ${response2.statusCode}');
              print('Response body: ${response2.body}');

              if (response2.statusCode == 200) {
                _videoPlayerController =
                    VideoPlayerController.file(File('$path/cover.mov'));
                await _videoPlayerController.initialize();
                await _videoPlayerController.setLooping(false);
                await _videoPlayerController.play();
                _videoPlayerController.addListener(checkVideoEnded);
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
                  },
                );
              }
            } else {
              //show error
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
            //show error
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
              },
            );
          }
        }
      }
    }
  }

  void checkVideoEnded() {
    print("in check video ended");
    if (_videoPlayerController.value.position ==
        _videoPlayerController.value.duration) {
      print("its true");
      print(_videoPlayerController.value.position);
      print(_videoPlayerController.value.duration);
      goToPlanner();
    }
  }

  goToPlanner() {
    _videoPlayerController.removeListener(checkVideoEnded);
    _videoPlayerController.pause();
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
                  child: FutureBuilder(
                    future: setVideoController(),
                    builder: (context, state) {
                      if (state.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        //return VideoPlayer(_videoPlayerController);
                        return Container(
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
                            ));
                      }
                    },
                  ),
                ),
              )
            ],
          ),
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
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }
}
