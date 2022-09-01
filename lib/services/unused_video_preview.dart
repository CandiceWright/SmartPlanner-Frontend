import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:practice_planner/models/inward_item.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../services/planner_service.dart';
import '../models/story.dart';
import '../views/navigation_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class VideoPreviewPage extends StatefulWidget {
  final String filePath;
  final String filename;

  final String videoType;
  // final Function updateView;

  const VideoPreviewPage(
      {Key? key,
      required this.filePath,
      required this.videoType,
      required this.filename})
      : super(key: key);

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

  saveStory() async {
    //upload video+thumbnail to firebase and get download url
    print("I am in save story");
    final thumbnail = await VideoCompress.getFileThumbnail(widget.filePath);
    String? result = await PlannerService.firebaseStorage
        .uploadStory(widget.filePath, widget.filename);

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

      //now save the thumbnail
      String? result2 = await PlannerService.firebaseStorage.uploadPicture(
          thumbnail.path, "thumbnails/" + p.basename(thumbnail.path));

      if (result2 == "error") {
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
        //successfully saved thumbnail and result2 has thumbnail url
        //save tto db now
        var url = Uri.parse(
            PlannerService.sharedInstance.serverUrl + '/user/stories');
        var body = {
          'userId': PlannerService.sharedInstance.user!.id,
          'date': DateTime.now().toString(),
          'url': result,
          //'thumbnail': PlannerService.sharedInstance.user!.profileImage
          'thumbnail': result2
        };
        String bodyF = jsonEncode(body);
        var response = await http.post(url,
            headers: {"Content-Type": "application/json"}, body: bodyF);

        print("server came back with a response after saving story");
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          var decodedBody = json.decode(response.body);
          print(decodedBody);
          var id = decodedBody["insertId"];
          // Story newStory = Story(id, result!, result2!, DateTime.now());
          // setState(() {
          //   // PlannerService.sharedInstance.user!.profileImage = path;
          //   PlannerService.sharedInstance.user!.stories.add(newStory);
          // });
          // Navigator.of(context).popUntil((route) {
          //   return route.settings.name == 'navigaionPage';
          // });
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
      }
    }

    // setState(() {
    //   PlannerService.sharedInstance.user!.stories.add(Story(
    //       File(widget.filePath),
    //       PlannerService.sharedInstance.user!.profileImage,
    //       DateTime.now()));
    // });

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
            // title: const Text(
            //   'Quick Thought or Reminder',
            //   style: TextStyle(color: Colors.white),
            // ),
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
                if (widget.videoType == "story") {
                  saveStory();
                }
              },
              child: Text("Save"),
            ),
          ],
        )
      ],
    );
  }
}
