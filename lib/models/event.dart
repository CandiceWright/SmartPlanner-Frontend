import 'package:flutter/material.dart';

class Event {
  String eventName;
  DateTime start;
  DateTime end;
  Color? background;
  String notes;
  String category;
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
      this.category = "Other",
      required this.type,
      this.location = ""});
}
