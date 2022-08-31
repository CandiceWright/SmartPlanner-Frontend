import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/models/story.dart';
import 'package:practice_planner/services/local_storage_service.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class CaptureVideoWithImagePicker extends StatefulWidget {
  final String prevPage;
  final Function updateState;
  const CaptureVideoWithImagePicker(
      {Key? key, required this.prevPage, required this.updateState})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<CaptureVideoWithImagePicker> createState() =>
      _CaptureVideoWithImagePickerState();
}

class _CaptureVideoWithImagePickerState
    extends State<CaptureVideoWithImagePicker> {
  final ImagePicker _picker = ImagePicker();
  LocalStorageService lss = LocalStorageService();

  //ConfettiController _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

  @override
  void initState() {
    _initVideo();
  }

  _initVideo() async {
    // final XFile? video = await _picker.pickVideo(
    //     source: ImageSource.camera, maxDuration: const Duration(minutes: 7));

    // print("video has been recorded");
    // print(video!.path);
    // Navigator.of(context).pop(video);

    final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera, maxDuration: const Duration(minutes: 2));

    print("video has been recorded");
    //print(video!.path);
    if (widget.prevPage == "home") {
      createStory(video);
    } else {
      createInwardVideo(video);
      //Navigator.of(context).pop(video);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    //List<Widget> goalsListView = buildGoalsListView();
    //if (_isLoading) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
    //}
    //return Container();
  }

  createInwardVideo(XFile? video) async {
    //usinng local storage
    if (video != null) {
      String path = video.path;
      String name = video.name;
      print("I am in save inward video");

      //save video locally

      String videolocation = await lss.writeFile(video, name);
      setState(() {
        // PlannerService.sharedInstance.user!.profileImage = path;
        PlannerService.sharedInstance.user!.planitVideoLocalPath =
            videolocation;

        PlannerService.sharedInstance.user!.hasPlanitVideo = true;
        widget.updateState();
        PlannerService.sharedInstance
            .storeCoverVideo(path, videolocation, name);
        Navigator.of(context).pop();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  // createInwardVideo(XFile? video) async { //just using firebase
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
  //         });
  //         widget.updateState();
  //         Navigator.of(context).pop();

  //         // Navigator.of(context).push(MaterialPageRoute(
  //         //   builder: (context) {
  //         //     return const NavigationWrapper();
  //         //   },
  //         //   settings: const RouteSettings(
  //         //     name: 'navigaionPage',
  //         //   ),
  //         // ));
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
  //     Navigator.of(context).pop();
  //   }
  // }

  // createStory(XFile? video) async { //just using firebase
  //   //final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
  //   if (video != null) {
  //     String path = video.path;
  //     String name = video.name;
  //     print("I am in save story in capture video");
  //     final thumbnail = await VideoCompress.getFileThumbnail(path);
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

  //       //now save the thumbnail
  //       String? result2 = await PlannerService.firebaseStorage.uploadPicture(
  //           thumbnail.path, "thumbnails/" + p.basename(thumbnail.path));

  //       if (result2 == "error") {
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
  //       } else {
  //         //successfully saved thumbnail and result2 has thumbnail url
  //         //save tto db now
  //         var url = Uri.parse(
  //             PlannerService.sharedInstance.serverUrl + '/user/stories');
  //         var body = {
  //           'userId': PlannerService.sharedInstance.user!.id,
  //           'date': DateTime.now().toString(),
  //           'url': result,
  //           //'thumbnail': PlannerService.sharedInstance.user!.profileImage
  //           'thumbnail': result2
  //         };
  //         String bodyF = jsonEncode(body);
  //         var response = await http.post(url,
  //             headers: {"Content-Type": "application/json"}, body: bodyF);

  //         print("server came back with a response after saving story");
  //         print('Response status: ${response.statusCode}');
  //         print('Response body: ${response.body}');

  //         if (response.statusCode == 200) {
  //           var decodedBody = json.decode(response.body);
  //           print(decodedBody);
  //           var id = decodedBody["insertId"];
  //           Story newStory = Story(id, result!, result2!, DateTime.now());
  //           setState(() {
  //             // PlannerService.sharedInstance.user!.profileImage = path;
  //             PlannerService.sharedInstance.user!.stories.add(newStory);
  //           });
  //           widget.updateState();
  //           Navigator.of(context).pop();

  //           // Navigator.of(context).push(MaterialPageRoute(
  //           //   builder: (context) {
  //           //     return const NavigationWrapper();
  //           //   },
  //           //   settings: const RouteSettings(
  //           //     name: 'navigaionPage',
  //           //   ),
  //           // ));
  //         } else {
  //           showDialog(
  //               context: context,
  //               builder: (context) {
  //                 return AlertDialog(
  //                   title: Text(
  //                       'Oops! Looks like something went wrong. Please try again.'),
  //                   actions: <Widget>[
  //                     TextButton(
  //                       child: Text('OK'),
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                     )
  //                   ],
  //                 );
  //               });
  //         }
  //       }
  //     }
  //   } else {
  //     Navigator.of(context).pop();
  //   }
  // }

  createStory(XFile? video) async {
    //using aws and local storage
    //final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      print("I am in save story in capture video");
      String path = video.path;
      String filename = video.name;
      //first save story locally
      String videolocation = await lss.writeFile(video, filename);

      //now save the thumbnail
      final thumbnail = await VideoCompress.getFileThumbnail(path);
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
        //save story to db now
        var url = Uri.parse(
            PlannerService.sharedInstance.serverUrl + '/user/stories');
        var body = {
          'userId': PlannerService.sharedInstance.user!.id,
          'date': DateTime.now().toString(),
          'url': "stories/" + filename,
          'localPath': videolocation,
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
          Story newStory =
              Story(id, "stories/" + filename, result2!, DateTime.now());
          setState(() {
            // PlannerService.sharedInstance.user!.profileImage = path;
            PlannerService.sharedInstance.user!.stories.add(newStory);
          });
          widget.updateState();
          PlannerService.sharedInstance
              .uploadStoryVideotoS3(path, videolocation, filename);

          Navigator.of(context).pop();
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
      }
    } else {
      //error
      Navigator.of(context).pop();
    }
  }
}
