import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/models/life_category.dart';

class Goal {
  String description = "";
  DateTime date = DateTime.now();
  //this '?' says that the value can be null
  LifeCategory category;
  String notes = "";

  Goal(this.description, this.date, this.category, this.notes);
}
