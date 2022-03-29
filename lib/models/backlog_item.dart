import 'package:practice_planner/models/life_category.dart';

class BacklogItem {
  String description = "";
  DateTime? completeBy = DateTime.now();
  bool? isComplete = false;
  //this '?' says that the value can be null
  LifeCategory category;
  String location;
  String notes;

  BacklogItem(
      {required this.description,
      this.completeBy,
      this.isComplete,
      required this.category,
      this.location = "",
      this.notes = ""});
}
