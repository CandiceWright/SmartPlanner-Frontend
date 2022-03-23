import 'package:flutter/material.dart';

class CustomTheme {
  MaterialColor? primaryColor;
  String themeId;
  Color? accentColor;
  String goalsIcon;
  String backlogIcon;
  String calendarEventIcon;
  String deadlineAlertIcon;

  CustomTheme({
    required this.themeId,
    this.primaryColor,
    this.accentColor,
    required this.goalsIcon,
    required this.backlogIcon,
    required this.calendarEventIcon,
    required this.deadlineAlertIcon,
  });
}
