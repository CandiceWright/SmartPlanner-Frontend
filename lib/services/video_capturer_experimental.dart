import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:practice_planner/models/story.dart';
import 'package:practice_planner/services/video_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import 'package:video_compress/video_compress.dart';

import '../../services/planner_service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class VideoCapturer extends StatefulWidget {
  final String videoType;
  const VideoCapturer({Key? key, required this.videoType}) : super(key: key);

  @override
  _VideoCapturerState createState() => _VideoCapturerState();
}

class _VideoCapturerState extends State<VideoCapturer> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;
  //late CameraController _frontCameraController;
  String camera = "back";
  late List<CameraDescription> cameras;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _initCamera() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    saveStory(video!.path, video.name);
    // final route = MaterialPageRoute(
    //   fullscreenDialog: true,
    //   builder: (_) => VideoPreviewPage(
    //     filePath: video!.path,
    //     filename: video.name,
    //     videoType: widget.videoType,
    //   ),
    // );
    // Navigator.push(context, route);
    // cameras = await availableCameras();
    // // final front = cameras.firstWhere(
    // //     (camera) => camera.lensDirection == CameraLensDirection.front);
    // final front = cameras.firstWhere(
    //     (camera) => camera.lensDirection == CameraLensDirection.back);
    // _cameraController = CameraController(front, ResolutionPreset.high);
    // //_frontCameraController = CameraController(front, ResolutionPreset.max);
    // await _cameraController.initialize();
    // // await _cameraController.prepareForVideoRecording();

    // //await _frontCameraController.initialize();
    // setState(() => _isLoading = false);
    // await _cameraController.prepareForVideoRecording();
  }

  saveStory(String path, String name) async {
    //upload video+thumbnail to firebase and get download url
    print("I am in save story");
    final thumbnail = await VideoCompress.getFileThumbnail(path);
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
          Story newStory = Story(id, result!, result2!, DateTime.now());
          setState(() {
            // PlannerService.sharedInstance.user!.profileImage = path;
            PlannerService.sharedInstance.user!.stories.add(newStory);
          });

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
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPreviewPage(
          filePath: file.path,
          filename: file.name,
          videoType: widget.videoType,
        ),
      );
      Navigator.push(context, route);
    } else {
      // await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.black,
          elevation: 0.0,
          actions: [
            IconButton(
              icon: Icon(Icons.flip_camera_ios),
              onPressed: () async {
                print("switching camera");
                if (camera == "back") {
                  camera = "front";
                  var front = cameras.firstWhere((camera) =>
                      camera.lensDirection == CameraLensDirection.front);
                  _cameraController =
                      CameraController(front, ResolutionPreset.max);
                  try {
                    await _cameraController.initialize();
                    // to notify the widgets that camera has been initialized and now camera preview can be done
                    setState(() {});
                  } catch (e) {
                    print(e);
                  }
                } else {
                  camera = "back";
                  var back = cameras.firstWhere((camera) =>
                      camera.lensDirection == CameraLensDirection.back);
                  _cameraController =
                      CameraController(back, ResolutionPreset.max);
                  try {
                    await _cameraController.initialize();
                    // to notify the widgets that camera has been initialized and now camera preview can be done
                    setState(() {});
                  } catch (e) {
                    print(e);
                  }
                }
              },
            )
          ],
        ),
        body: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CameraPreview(_cameraController),
              // Padding(
              //   padding: const EdgeInsets.all(25),
              //child: FloatingActionButton(
              FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(_isRecording ? Icons.stop : Icons.play_circle),
                onPressed: () => _recordVideo(),
              ),
              //),
            ],
          ),
        ),
      );
    }
  }
}
