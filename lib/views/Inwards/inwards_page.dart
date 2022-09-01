import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice_planner/services/capture_video_with_imagepicker.dart';
import 'package:practice_planner/services/local_storage_service.dart';

import 'package:video_player/video_player.dart';
import '/services/planner_service.dart';
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
  LocalStorageService lss = LocalStorageService();
  late XFile fileMedia;

  //ConfettiController _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
    //print("I am about to show video on inwards page");
    //print(PlannerService.sharedInstance.user!.planitVideo);
    // if (PlannerService.sharedInstance.user!.hasPlanitVideo) {
    //   setVideoController();
    // }
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

  // setVideoController() {
  //   setState(() {
  //     _videoPlayerController = VideoPlayerController.network(
  //         PlannerService.sharedInstance.user!.planitVideo)
  //       ..initialize().then((_) {
  //         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
  //         setState(() {});
  //         _videoPlayerController.play();
  //         _videoPlayerController.setLooping(true);
  //       });
  //   });
  // }
  Future setVideoController() async {
    print("I am setting video controller");
    if (File(PlannerService.sharedInstance.user!.planitVideoLocalPath)
        .existsSync()) {
      print("file exists");
      //the file exists!
      //can use file
      _videoPlayerController = VideoPlayerController.file(
          File(PlannerService.sharedInstance.user!.planitVideoLocalPath));
      await _videoPlayerController.initialize();
      await _videoPlayerController.setLooping(true);
      await _videoPlayerController.play();
    } else {
      print("file does not exists");
      //need to get the video from s3
      //first get s3 get url, then store file locally and
      Object presignedUrl = await PlannerService.aws.getPresignedUrl(
          "get", PlannerService.sharedInstance.user!.planitVideo);
      if (presignedUrl != "error") {
        var url = Uri.parse(presignedUrl.toString());
        print("this is the url i am trying to get in inwards page line 103");
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
            'inwardVideoUrl': PlannerService.sharedInstance.user!.planitVideo,
            'coverVideoLocalPath': '$path/cover.mov',
          };
          String bodyF = jsonEncode(body);
          print(bodyF);

          var url = Uri.parse(
              PlannerService.sharedInstance.serverUrl + '/user/inwardvideo');
          var response2 = await http.patch(url,
              headers: {"Content-Type": "application/json"}, body: bodyF);
          print('Response status: ${response2.statusCode}');
          print('Response body: ${response2.body}');

          if (response2.statusCode == 200) {
            _videoPlayerController =
                VideoPlayerController.file(File('$path/cover.mov'));
            await _videoPlayerController.initialize();
            await _videoPlayerController.setLooping(true);
            await _videoPlayerController.play();
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

  setInwardVideo(XFile? video) async {
    //using local
    if (video != null) {
      String path = video.path;
      String name = video.name;
      print("I am in save inward video");

      //save video locally

      //String videolocation = await lss.writeFile(video, name);
      String videolocation = await lss.writeFile(video, 'cover.mov');
      setState(() {
        PlannerService.sharedInstance.user!.planitVideoLocalPath =
            videolocation;

        PlannerService.sharedInstance.user!.hasPlanitVideo = true;
        setVideoController();
      });
      //PlannerService.sharedInstance.storeCoverVideo(path, videolocation, name);
      // PlannerService.sharedInstance
      //     .storeCoverVideo(path, videolocation, 'cover.mov');
      var userId = PlannerService.sharedInstance.user!.id.toString();
      PlannerService.sharedInstance
          .storeCoverVideo(path, videolocation, 'cover$userId.mov');
    } else {
      return;
    }
  }

  // createInwardVideo(XFile? video) async {
  //   if (video != null) {
  //     String path = video.path;
  //     String name = video.name;
  //     print("I am in save inward video");
  //     //final thumbnail = await VideoCompress.getFileThumbnail(path);
  //     String? result =
  //         await PlannerService.firebaseStorage.uploadStory(path, name);

  //     //store story in db then add story object to the list of stories
  //     print("result is ready");
  //     print(result);
  //     if (result == "error") {
  //       //error message
  //       showDialog(
  //           context: context,
  //           builder: (context) {
  //             return AlertDialog(
  //               title: Text(
  //                   'Oops! Looks like something went wrong. Please try again.'),
  //               actions: <Widget>[
  //                 TextButton(
  //                   child: Text('OK'),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 )
  //               ],
  //             );
  //           });
  //     } else {
  //       //success and result holds url
  //       print("success getting video url");
  //       print(result);

  //       //successfully saved thumbnail and result2 has thumbnail url
  //       //save tto db now
  //       var url = Uri.parse(
  //           PlannerService.sharedInstance.serverUrl + '/user/inwardvideo');
  //       var body = {
  //         'userId': PlannerService.sharedInstance.user!.id,
  //         'inwardVideo': result,
  //         //'thumbnail': PlannerService.sharedInstance.user!.profileImage
  //       };
  //       String bodyF = jsonEncode(body);
  //       var response = await http.patch(url,
  //           headers: {"Content-Type": "application/json"}, body: bodyF);

  //       print("server came back with a response after saving story");
  //       print('Response status: ${response.statusCode}');
  //       print('Response body: ${response.body}');

  //       if (response.statusCode == 200) {
  //         print("success saving to db");
  //         // var decodedBody = json.decode(response.body);
  //         // print(decodedBody);
  //         // var id = decodedBody["insertId"];
  //         // PlannerService.sharedInstance.user!.planitVideo = result!;
  //         //Story newStory = Story(id, result!, result2!, DateTime.now());
  //         setState(() {
  //           // PlannerService.sharedInstance.user!.profileImage = path;
  //           PlannerService.sharedInstance.user!.planitVideo = result!;

  //           PlannerService.sharedInstance.user!.hasPlanitVideo = true;
  //           setVideoController();
  //         });
  //       } else {
  //         showDialog(
  //             context: context,
  //             builder: (context) {
  //               return AlertDialog(
  //                 title: Text(
  //                     'Oops! Looks like something went wrong. Please try again.'),
  //                 actions: <Widget>[
  //                   TextButton(
  //                     child: Text('OK'),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                   )
  //                 ],
  //               );
  //             });
  //       }
  //       //}
  //     }
  //   } else {
  //     return;
  //   }
  // }

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
                  child: PlannerService.sharedInstance.user!.hasPlanitVideo
                      ? (FutureBuilder(
                          future: setVideoController(),
                          builder: (context, state) {
                            if (state.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              //return VideoPlayer(_videoPlayerController);
                              return Container(
                                  margin: EdgeInsets.all(20),
                                  child: AspectRatio(
                                    aspectRatio: _videoPlayerController
                                        .value.aspectRatio,
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
                        ))
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
                                    "This is your cover video, 1-2 minutes. Whenever you enter your planit, you'll see it. Add whatever makes you happy in this cover video. You can record a video or upload one. ",
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
                                          setInwardVideo(video);
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
                                      _videoPlayerController.pause();
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
                                      _videoPlayerController.pause();
                                      Navigator.pop(context);
                                      final XFile? video =
                                          await _picker.pickVideo(
                                              source: ImageSource.gallery,
                                              maxDuration:
                                                  const Duration(minutes: 2));
                                      setInwardVideo(video);
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
