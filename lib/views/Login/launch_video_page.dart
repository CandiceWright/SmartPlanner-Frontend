import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/Login/welcome_page.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:localstorage/localstorage.dart';

class LaunchVideoPage extends StatefulWidget {
  const LaunchVideoPage({Key? key}) : super(key: key);

  @override
  State<LaunchVideoPage> createState() => _LaunchVideoPageState();
}

class _LaunchVideoPageState extends State<LaunchVideoPage> {
  late VideoPlayerController _videoPlayerController;
  //final LocalStorage storage = LocalStorage('planner_app');
  final Future<SharedPreferences> storage = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
  }

  void checkVideoEnded() {
    //print("in check video ended");
    if (_videoPlayerController.value.position ==
        _videoPlayerController.value.duration) {
      goToWelcomePage();
    }
  }

  getVideoStatus() async {
    // await storage.then((SharedPreferences prefs) {
    //   print("I am clearing shared storage");
    //   prefs.clear();
    // });
    await storage.then((SharedPreferences prefs) {
      print("I am printing video status in local storage");

      print(prefs.getBool('videoShown'));
      if (prefs.getBool("videoShown") != null) {
        print("I am in does not equal not video shown");
        //video already shown
        _videoPlayerController =
            VideoPlayerController.asset("assets/images/launch_video.mp4")
              ..initialize().then((_) {
                _videoPlayerController.addListener(checkVideoEnded);
                skipToWelcomePage();
              });
      } else {
        _videoPlayerController =
            VideoPlayerController.asset("assets/images/launch_video.mp4")
              ..initialize().then((_) {
                _videoPlayerController.play();
                _videoPlayerController.setLooping(false);
                _videoPlayerController.addListener(checkVideoEnded);
              });
      }
    });
  }

  skipToWelcomePage() {
    _videoPlayerController.removeListener(checkVideoEnded);
    _videoPlayerController.dispose();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const WelcomePage();
      },
    ));
  }

  goToWelcomePage() async {
    _videoPlayerController.removeListener(checkVideoEnded);
    _videoPlayerController.pause();
    _videoPlayerController.dispose();
    //await storage.setItem('videoShown', true);
    await storage.then((SharedPreferences prefs) {
      prefs.setBool('videoShown', true);
      print(prefs.getBool("videoShown"));
    });

    //print("I am printing videoshown status");
    //print(storage.getItem('videoShown'));

    // Navigator.push(
    //     context, CupertinoPageRoute(builder: (context) => WelcomePage()));
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const WelcomePage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getVideoStatus(),
        builder: (context, state) {
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

                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  elevation: 0.0,
                ),

                // body: FutureBuilder(
                //   future: getVideoStatus(),
                //   builder: (context, state) {
                //     if (state.connectionState == ConnectionState.waiting) {
                //       return const Center(child: CircularProgressIndicator());
                //     } else {
                //       return
                body: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_videoPlayerController),
                      // VideoProgressIndicator(_videoPlayerController,
                      //     allowScrubbing: true),
                    ],
                  ),
                ),
                //     }
                //   },
                // ),

                persistentFooterButtons: [
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      onPressed: goToWelcomePage,
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: const BorderSide(
                                          color: Color(0xffffffff))))),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    print("I am in dispose in launch video");
    super.dispose();
    // _videoPlayerController.dispose();
  }
}
