import 'package:flutter/material.dart';

class Event {
  Event(
      {required this.id,
      required this.eventName,
      this.from,
      this.to,
      this.background,
      this.isAllDay = false,
      required this.type});

  String eventName;
  DateTime? from;
  DateTime? to;
  Color? background;
  bool isAllDay;
  int id;
  String type;
}
