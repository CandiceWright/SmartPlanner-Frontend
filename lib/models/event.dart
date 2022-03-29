import 'package:flutter/material.dart';
import 'package:practice_planner/models/life_category.dart';

class Event {
  String eventName;
  DateTime start;
  DateTime end;
  Color? background;
  String notes;
  LifeCategory category;
  String location;
  bool isAllDay;
  int id;
  String type;
  Event(
      {required this.id,
      required this.eventName,
      required this.start,
      required this.end,
      this.background,
      this.isAllDay = false,
      this.notes = "",
      required this.category,
      required this.type,
      this.location = ""});
}
