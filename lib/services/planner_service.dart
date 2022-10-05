import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:practice_planner/Themes/app_themes.dart';
import 'package:practice_planner/Themes/blue_theme.dart';
import 'package:practice_planner/Themes/pink_theme.dart';
import 'package:practice_planner/Themes/custom_theme.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/services/aws_storage_service.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import '/models/user.dart';
import '/models/goal.dart';
import 'firebase_storage_service.dart';

class PlannerService {
  static PlannerService sharedInstance = PlannerService();
  static FirebaseStorage firebaseStorage = FirebaseStorage();
  static AWSStorageService aws = AWSStorageService();
  static SubscriptionsProvider subscriptionProvider = SubscriptionsProvider();
  //var subscriptionProvider;
  //this is for prod
  //String serverUrl = "https://serve-anotherplanit.com:7343";

  //for dev (this is your ip. It changes sometimes so keep this up-to-date)
  String serverUrl = "http://192.168.1.158:7343";

  User? user;

  Map<String, CustomTheme> themeColorMap = {
    "pink": PinkTheme(),
    "blue": BlueTheme(),
    "neutral": PinkTheme()
  };

  PlannerService();

  storeCoverVideo(String tempPath, String localPath, String name) async {
    //with aws

    Object presignedUrl =
        await PlannerService.aws.getPresignedUrl("put", "covers/$name");
    if (presignedUrl != "error") {
      File file = File(tempPath);
      var url = Uri.parse(presignedUrl.toString());
      //print("this is the url i am trying to put");
      //print(url);
      var response = await http.put(url,
          headers: {
            //"Content-Type": "text/plain",
            //"Key": "stories/" + filename
          },
          body: file.readAsBytesSync());
      //print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        //print("video saved to s3");
        //save tto db now
        var url = Uri.parse(
            PlannerService.sharedInstance.serverUrl + '/user/inwardvideo');
        var body = {
          'userId': PlannerService.sharedInstance.user!.id,
          'inwardVideoUrl': 'covers/$name',
          'coverVideoLocalPath': localPath
          //'thumbnail': PlannerService.sharedInstance.user!.profileImage
        };
        String bodyF = jsonEncode(body);
        var response = await http.patch(url,
            headers: {"Content-Type": "application/json"}, body: bodyF);

        //print("server came back with a response after saving video");
        //print('Response status: ${response.statusCode}');
        //print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          //print("success saving to db");
        } else {
          //maybe create a listening variable in navigation wrapper to show some error
          //print("error saving to db");
        }
      } else {
        //should create listening variable for error in navigation wrapper to show an error dialog if this error occurs
        //print("error in planner service line 82");
      }
    } else {
      //should create listening variable for error in navigation wrapper to show an error dialog if this error occurs
      //print("error in planner service line 85");
    }
  }

  uploadStoryVideotoS3(String tempPath, String localPath, String name) async {
    //with aws

    Object presignedUrl =
        await PlannerService.aws.getPresignedUrl("put", "stories/$name");
    if (presignedUrl != "error") {
      File file = File(tempPath);
      var url = Uri.parse(presignedUrl.toString());
      //print("this is the url i am trying to put");
      //print(url);
      var response = await http.put(url,
          headers: {
            //"Content-Type": "text/plain",
            //"Key": "stories/" + filename
          },
          body: file.readAsBytesSync());
      //print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        //print("video saved to s3");
      } else {
        //should create listening variable for error in navigation wrapper to show an error dialog if this error occurs
        //print("error in planner service line 113");
      }
    } else {
      //should create listening variable for error in navigation wrapper to show an error dialog if this error occurs
      //print("error in planner service line 116");
    }
  }
}
