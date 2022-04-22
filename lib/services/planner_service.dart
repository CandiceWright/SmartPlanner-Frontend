import 'package:flutter/material.dart';
import 'package:practice_planner/Themes/app_themes.dart';
import 'package:practice_planner/Themes/blue_theme.dart';
import 'package:practice_planner/Themes/pink_theme.dart';
import 'package:practice_planner/Themes/custom_theme.dart';
import 'package:practice_planner/models/life_category.dart';
import '/models/user.dart';
import '/models/goal.dart';

class PlannerService {
  static var sharedInstance = PlannerService();
  var user = User(
      name: "",
      email: "candicew@gmail.com",
      username: "Candicew",
      password: "hi",
      profileImage: "assets/images/profile_pic_icon.png",
      themeId: AppThemes.pink,
      theme: PinkTheme(),
      didStartTomorrowPlanning: false,
      lifeCategories: [
        LifeCategory("Other", const Color(0xFFFF80b1)),
      ]);

  Map<String, CustomTheme> themeColorMap = {
    "pink": PinkTheme(),
    "blue": BlueTheme(),
    "neutral": PinkTheme()
  };

  PlannerService() {}

  List<dynamic> getGoals() {
    /*Once you get server set up, this should  fetch goals from server*/
    return user.goals;
  }
}
