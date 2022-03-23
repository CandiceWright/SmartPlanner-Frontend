import 'package:flutter/material.dart';
import 'custom_theme.dart';

class BlueTheme extends CustomTheme {
  final Map<int, Color> _blueMap = {
    50: Colors.blue.shade50,
    100: Colors.blue.shade100,
    200: Colors.blue.shade200,
    300: Colors.blue.shade300,
    400: Colors.blue.shade400,
    500: Colors.blue.shade500,
    600: Colors.blue.shade600,
    700: Colors.blue.shade700,
    800: Colors.blue.shade800,
    900: Colors.blue.shade900,
  };

  late MaterialColor bluePrimarySwatch =
      MaterialColor(Colors.blue[900]!.value, _blueMap);

  late MaterialColor blueAccentSwatch =
      MaterialColor(Colors.blue[50]!.value, _blueMap);

  BlueTheme()
      : super(
            themeId: "blue",
            goalsIcon: "assets/images/goal_icon.png",
            backlogIcon: "assets/images/backlog_icon.png",
            deadlineAlertIcon: "assets/images/goal_icon.png",
            calendarEventIcon: "assets/images/goal_icon.png") {
    primaryColor = bluePrimarySwatch;
    accentColor = blueAccentSwatch;
  }
}
