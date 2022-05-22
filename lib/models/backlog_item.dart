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
  int? calendarItemRef;

  BacklogItem(
      {this.id,
      this.calendarItemRef,
      required this.description,
      this.completeBy,
      this.isComplete,
      required this.category,
      this.location = "",
      this.notes = ""});
}
