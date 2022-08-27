import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/definition.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/models/story.dart';
//import 'package:video_thumbnail/video_thumbnail.dart';
import 'backlog_item.dart';
import 'habit.dart';
import 'event.dart';
import 'package:flutter/material.dart';

import 'inward_item.dart';

class User {
  var planitName;
  int id;
  String profileImage;
  String receipt;
  var email;
  int themeId;
  String spaceImage;
  bool hasPlanitVideo = false;
  //String planitVideo = "assets/images/another_planit_animation_video.mp4";
  String planitVideo = "";
  var goals = <Event>[];
  var scheduledEvents = <Event>[];
  var habits = <Habit>[];
  var dictionaryMap = <String, Definition>{};
  var dictionaryArr = <Definition>[];
  var accomplishedGoals = <Event>[];
  var backlogItems = <BacklogItem>[];
  var inwardContent = <InwardItem>[];
  //var stories = <Story>[];
  var stories = <Story>[
    // Story(File("assets/images/another_planit_animation_video.mp4"),
    //     "assets/images/profile_pic_icon.png", DateTime.now()),
    // Story(File("assets/images/another_planit_animation_video.mp4"),
    //     "assets/images/profile_pic_icon.png", DateTime.now())
  ];

  Map<String, List<BacklogItem>> backlogMap = {};
  var todayTasks = [];
  bool didStartTomorrowPlanning;
  var lifeCategories = <LifeCategory>[];
  Map<int, LifeCategory>? lifeCategoriesMap;
  Map<String, Color> LifeCategoriesColorMap = {
    // "Other": const Color(0xFFFF80b1)
  };

  User(
      {required this.id,
      required this.planitName,
      required this.receipt,
      //required this.username,
      required this.email,
      //required this.theme,
      required this.themeId,
      required this.spaceImage,
      required this.profileImage,
      required this.didStartTomorrowPlanning,
      required this.lifeCategories}) {
    //buildStories();
  }

  // Future<String?> createStoryThumbnail(String videoPath) async {
  //   print("I am creating a thumbnail");
  //   final fileName = await VideoThumbnail.thumbnailFile(
  //     video: videoPath,
  //     //thumbnailPath: (await getTemporaryDirectory()).path,
  //     imageFormat: ImageFormat.WEBP,
  //     maxHeight:
  //         64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
  //     quality: 75,
  //   );
  //   print(fileName);
  //   return fileName;
  // }

  // buildStories() async {
  //   for (int i = 0; i < 3; i++) {
  //     String? storyThumbnail = await createStoryThumbnail(
  //         "assets/images/another_planit_animation_video.mp4");
  //     var story = Story(
  //         File("assets/images/another_planit_animation_video.mp4"),
  //         storyThumbnail!,
  //         DateTime.now());
  //     stories.add(story);
  //   }
  // }
}
