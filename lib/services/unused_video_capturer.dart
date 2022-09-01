import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:practice_planner/services/unused_video_preview.dart';

import '../../services/planner_service.dart';

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
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(front, ResolutionPreset.high);
    //_frontCameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    // await _cameraController.prepareForVideoRecording();

    //await _frontCameraController.initialize();
    setState(() => _isLoading = false);
    await _cameraController.prepareForVideoRecording();
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
