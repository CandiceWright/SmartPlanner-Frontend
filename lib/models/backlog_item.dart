import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/models/life_category.dart';

class BacklogItem {
  int? id;
  String description = "";
  DateTime? completeBy;
  bool? isComplete = false;
  DateTime? scheduledDate;
  //this '?' says that the value can be null
  LifeCategory category;
  String location;
  String notes;
  Event? calendarItemRef;
  String? status = "notStarted"; //notStarted, incomplete, complete

  BacklogItem(
      {this.id,
      this.scheduledDate,
      this.calendarItemRef,
      required this.description,
      this.completeBy,
      this.isComplete,
      required this.category,
      this.location = "",
      this.notes = ""});
}
