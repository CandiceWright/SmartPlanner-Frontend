import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:practice_planner/views/Inwards/video_preview_page.dart';

import '../../services/planner_service.dart';

class VideoCapturePage extends StatefulWidget {
  const VideoCapturePage({Key? key}) : super(key: key);

  @override
  _VideoCapturePageState createState() => _VideoCapturePageState();
}

class _VideoCapturePageState extends State<VideoCapturePage> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;
  //late CameraController _frontCameraController;
  String camera = "back";
  late List<CameraDescription> cameras;

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
    cameras = await availableCameras();
    // final front = cameras.firstWhere(
    //     (camera) => camera.lensDirection == CameraLensDirection.front);
    final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(back, ResolutionPreset.max);
    //_frontCameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    //await _frontCameraController.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPreviewPage(filePath: file.path),
      );
      Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
    // if (camera == "back") {
    //   if (_isRecording) {
    //     final file = await _cameraController.stopVideoRecording();
    //     setState(() => _isRecording = false);
    //     final route = MaterialPageRoute(
    //       fullscreenDialog: true,
    //       builder: (_) => VideoPage(filePath: file.path),
    //     );
    //     Navigator.push(context, route);
    //   } else {
    //     await _cameraController.prepareForVideoRecording();
    //     await _cameraController.startVideoRecording();
    //     setState(() => _isRecording = true);
    //   }
    // } else {
    //   if (_isRecording) {
    //     final file = await _frontCameraController.stopVideoRecording();
    //     setState(() => _isRecording = false);
    //     final route = MaterialPageRoute(
    //       fullscreenDialog: true,
    //       builder: (_) => VideoPage(filePath: file.path),
    //     );
    //     Navigator.push(context, route);
    //   } else {
    //     await _frontCameraController.prepareForVideoRecording();
    //     await _frontCameraController.startVideoRecording();
    //     setState(() => _isRecording = true);
    //   }
    // }
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
        // body: _cameraController.value.isInitialized
        //     ? AspectRatio(
        //         aspectRatio: _cameraController.value.aspectRatio,
        //         child: CameraPreview(_cameraController),
        //       )
        //     : Container(),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Theme.of(context).primaryColor,
        //   child: Icon(_isRecording ? Icons.stop : Icons.play_circle),
        //   onPressed: () => _recordVideo(),
        // ),
      );

      // return Center(
      //   child: Stack(
      //     alignment: Alignment.bottomCenter,
      //     children: [
      //       CameraPreview(_cameraController),
      //       Padding(
      //         padding: const EdgeInsets.all(25),
      //         child: FloatingActionButton(
      //           backgroundColor: Theme.of(context).primaryColor,
      //           child: Icon(_isRecording ? Icons.stop : Icons.play_circle),
      //           onPressed: () => _recordVideo(),
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.all(25),
      //         child: FloatingActionButton(
      //           backgroundColor: Theme.of(context).primaryColor,
      //           child: Icon(Icons.flip_camera_ios),
      //           onPressed: () {
      //             () async {
      //               print("switching camera");
      //               if (camera == "back") {
      //                 camera = "front";
      //                 var front = cameras.firstWhere((camera) =>
      //                     camera.lensDirection == CameraLensDirection.front);
      //                 _cameraController =
      //                     CameraController(front, ResolutionPreset.max);
      //                 try {
      //                   await _cameraController.initialize();
      //                   // to notify the widgets that camera has been initialized and now camera preview can be done
      //                   setState(() {});
      //                 } catch (e) {
      //                   print(e);
      //                 }
      //               } else {
      //                 camera = "back";
      //                 var back = cameras.firstWhere((camera) =>
      //                     camera.lensDirection == CameraLensDirection.back);
      //                 _cameraController =
      //                     CameraController(back, ResolutionPreset.max);
      //                 try {
      //                   await _cameraController.initialize();
      //                   // to notify the widgets that camera has been initialized and now camera preview can be done
      //                   setState(() {});
      //                 } catch (e) {
      //                   print(e);
      //                 }
      //               }
      //             };
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // );

      // return Stack(
      //   children: [
      //     Image.asset(
      //       PlannerService.sharedInstance.user!.spaceImage,
      //       height: MediaQuery.of(context).size.height,
      //       width: MediaQuery.of(context).size.width,
      //       fit: BoxFit.cover,
      //     ),
      //     Scaffold(
      //       backgroundColor: Colors.transparent,
      //       appBar: AppBar(
      //         backgroundColor: Colors.transparent,
      //         centerTitle: true,
      //         title: const Text(
      //           "New Thought",
      //           style: TextStyle(color: Colors.white),
      //         ),
      //         actions: [
      // GestureDetector(
      //   child: const Padding(
      //     padding: EdgeInsets.all(4),
      //     child: Icon(
      //       Icons.flip_camera_ios,
      //       size: 34,
      //     ),
      //   ),
      // onTap: () async {
      //   print("switching camera");
      //   if (camera == "back") {
      //     camera = "front";
      //     var front = cameras.firstWhere((camera) =>
      //         camera.lensDirection == CameraLensDirection.front);
      //     _cameraController =
      //         CameraController(front, ResolutionPreset.max);
      //     try {
      //       await _cameraController.initialize();
      //       // to notify the widgets that camera has been initialized and now camera preview can be done
      //       setState(() {});
      //     } catch (e) {
      //       print(e);
      //     }
      //   } else {
      //     camera = "back";
      //     var back = cameras.firstWhere((camera) =>
      //         camera.lensDirection == CameraLensDirection.back);
      //     _cameraController =
      //         CameraController(back, ResolutionPreset.max);
      //     try {
      //       await _cameraController.initialize();
      //       // to notify the widgets that camera has been initialized and now camera preview can be done
      //       setState(() {});
      //     } catch (e) {
      //       print(e);
      //     }
      //   }
      // },
      // )
      //         ],
      //       ),
      //       //body: Container(
      //       //child: Stack(
      //       body: Stack(
      //         alignment: Alignment.bottomCenter,
      //         children: [
      //           CameraPreview(_cameraController),
      //           Padding(
      //             padding: const EdgeInsets.all(25),
      //             child: FloatingActionButton(
      //               backgroundColor: Theme.of(context).primaryColor,
      //               child: Icon(_isRecording ? Icons.stop : Icons.play_circle),
      //               onPressed: () => _recordVideo(),
      //             ),
      //           ),
      //         ],
      //       ),
      //       //),
      //     )
      //   ],
      // );

    }
  }
}
