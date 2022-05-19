import 'package:flutter/material.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/models/life_category.dart';

class Event {
  String description;
  DateTime? date;
  DateTime start;
  DateTime end;
  Color background;
  String notes;
  LifeCategory category;
  String? location;
  bool isAllDay;
  int? id;
  String type;
  BacklogMapRef?
      backlogMapRef; //if a backlog item is scheduled on the calendar, this reference will link the backlog item to its calendar event
  Event(
      {this.id,
      required this.description,
      required this.start,
      required this.end,
      required this.background,
      this.isAllDay = false,
      this.notes = "",
      required this.category,
      required this.type,
      this.location = "",
      this.backlogMapRef});
}
