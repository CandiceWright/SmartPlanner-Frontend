import 'package:flutter/material.dart';
import 'package:practice_planner/Themes/app_themes.dart';
import 'package:practice_planner/Themes/blue_theme.dart';
import 'package:practice_planner/Themes/pink_theme.dart';
import 'package:practice_planner/Themes/custom_theme.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import '/models/user.dart';
import '/models/goal.dart';
import 'firebase_storage_service.dart';

class PlannerService {
  static PlannerService sharedInstance = PlannerService();
  static FirebaseStorage firebaseStorage = FirebaseStorage();
  //static SubscriptionsProvider subscriptionProvider = SubscriptionsProvider();
  //this is for prod
  //String serverUrl = "https://serve-anotherplanit.com:7343";

  //for dev (this is your ip. It changes sometimes so keep this up-to-date)
  String serverUrl = "http://192.168.0.101:7343";

  User? user;

  Map<String, CustomTheme> themeColorMap = {
    "pink": PinkTheme(),
    "blue": BlueTheme(),
    "neutral": PinkTheme()
  };

  PlannerService();
}
