import 'package:flutter/material.dart';
import 'custom_theme.dart';

class PinkTheme extends CustomTheme {
  final Map<int, Color> _pinkMap = {
    50: Colors.pink.shade50,
    100: Colors.pink.shade100,
    200: Colors.pink.shade200,
    300: Colors.pink.shade300,
    400: Colors.pink.shade400,
    500: Colors.pink.shade500,
    600: Colors.pink.shade600,
    700: Colors.pink.shade700,
    800: Colors.pink.shade800,
    900: Colors.pink.shade900,
  };

  late MaterialColor pinkPrimarySwatch =
      MaterialColor(Colors.pink[400]!.value, _pinkMap);

  late MaterialColor pinkAccentSwatch =
      MaterialColor(Colors.pink[50]!.value, _pinkMap);

  PinkTheme()
      : super(
            themeId: "pink",
            goalsIcon: "assets/images/goal_icon.png",
            backlogIcon: "assets/images/backlog_icon.png",
            deadlineAlertIcon: "assets/images/goal_icon.png",
            calendarEventIcon: "assets/images/goal_icon.png") {
    primaryColor = pinkPrimarySwatch;
    accentColor = pinkAccentSwatch;
  }
}
